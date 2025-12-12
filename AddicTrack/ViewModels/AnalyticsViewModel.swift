//
//  AnalyticsViewModel.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import Foundation
import SwiftData
import SwiftUI

struct EntryDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct AddictionStats {
    let addiction: Addiction
    let totalEntries: Int
    let entriesThisWeek: Int
    let entriesThisMonth: Int
    let averagePerWeek: Double
    let daysSinceLastEntry: Int?
    let longestStreak: Int // Days without entry
    let recentTrend: TrendDirection
}

enum TrendDirection {
    case increasing
    case decreasing
    case stable
}

@Observable
final class AnalyticsViewModel {
    var allAddictions: [Addiction] = []
    var isLoading = false
    var errorMessage: String?
    
    private var modelContext: ModelContext?
    private var currentUser: User?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func setCurrentUser(_ user: User?) {
        self.currentUser = user
        loadData()
    }
    
    func loadData() {
        guard let modelContext = modelContext else { return }
        guard let currentUser = currentUser else {
            allAddictions = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Fetch all addictions for the current user
        let descriptor = FetchDescriptor<Addiction>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            let allAddictions = try modelContext.fetch(descriptor)
            self.allAddictions = allAddictions.filter { $0.user?.id == currentUser.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Statistics
    
    func getAddictionStats(_ addiction: Addiction) -> AddictionStats {
        let entries = addiction.entries ?? []
        let totalEntries = entries.count
        
        let calendar = Calendar.current
        let now = Date()
        
        // This week
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let entriesThisWeek = entries.filter { $0.timestamp >= weekAgo }.count
        
        // This month
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let entriesThisMonth = entries.filter { $0.timestamp >= monthAgo }.count
        
        // Average per week (based on last 4 weeks)
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: now) ?? now
        let recentEntries = entries.filter { $0.timestamp >= fourWeeksAgo }
        let weeks = max(1, calendar.dateComponents([.weekOfYear], from: fourWeeksAgo, to: now).weekOfYear ?? 4)
        let averagePerWeek = Double(recentEntries.count) / Double(weeks)
        
        // Days since last entry
        let sortedEntries = entries.sorted { $0.timestamp > $1.timestamp }
        let daysSinceLastEntry: Int? = sortedEntries.first.map { entry in
            calendar.dateComponents([.day], from: entry.timestamp, to: now).day ?? 0
        }
        
        // Longest streak (days without entry)
        let longestStreak = calculateLongestStreak(entries: entries)
        
        // Recent trend
        let recentTrend = calculateTrend(entries: entries)
        
        return AddictionStats(
            addiction: addiction,
            totalEntries: totalEntries,
            entriesThisWeek: entriesThisWeek,
            entriesThisMonth: entriesThisMonth,
            averagePerWeek: averagePerWeek,
            daysSinceLastEntry: daysSinceLastEntry,
            longestStreak: longestStreak,
            recentTrend: recentTrend
        )
    }
    
    // MARK: - Chart Data
    
    func getEntriesOverTime(for addiction: Addiction, days: Int = 30) -> [EntryDataPoint] {
        let entries = addiction.entries ?? []
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: now) ?? now
        
        let filteredEntries = entries.filter { $0.timestamp >= startDate }
        
        // Group by day
        let grouped = Dictionary(grouping: filteredEntries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        
        // Create data points
        var dataPoints: [EntryDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= now {
            let dayStart = calendar.startOfDay(for: currentDate)
            let count = grouped[dayStart]?.count ?? 0
            dataPoints.append(EntryDataPoint(date: dayStart, count: count))
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return dataPoints
    }
    
    func getWeeklySummary() -> [String: Int] {
        var summary: [String: Int] = [:]
        let calendar = Calendar.current
        
        for addiction in allAddictions {
            let entries = addiction.entries ?? []
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let recentEntries = entries.filter { $0.timestamp >= weekAgo }
            summary[addiction.name] = recentEntries.count
        }
        
        return summary
    }
    
    // MARK: - Helper Methods
    
    private func calculateLongestStreak(entries: [AddictionEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }
        
        var longestStreak = 0
        var currentStreak = 0
        var lastEntryDate: Date?
        
        for entry in sortedEntries {
            if let lastDate = lastEntryDate {
                let daysBetween = calendar.dateComponents([.day], from: lastDate, to: entry.timestamp).day ?? 0
                if daysBetween > 1 {
                    // Streak broken, reset
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 0
                } else {
                    currentStreak += daysBetween
                }
            }
            lastEntryDate = entry.timestamp
        }
        
        // Check final streak
        longestStreak = max(longestStreak, currentStreak)
        
        // Calculate days since last entry if applicable
        if let lastEntry = sortedEntries.last {
            let daysSince = calendar.dateComponents([.day], from: lastEntry.timestamp, to: Date()).day ?? 0
            if daysSince > 0 {
                currentStreak = daysSince
                longestStreak = max(longestStreak, currentStreak)
            }
        }
        
        return longestStreak
    }
    
    private func calculateTrend(entries: [AddictionEntry]) -> TrendDirection {
        guard entries.count >= 4 else { return .stable }
        
        let calendar = Calendar.current
        let now = Date()
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        let firstWeek = entries.filter { $0.timestamp >= twoWeeksAgo && $0.timestamp < oneWeekAgo }.count
        let secondWeek = entries.filter { $0.timestamp >= oneWeekAgo }.count
        
        if secondWeek > firstWeek {
            return .increasing
        } else if secondWeek < firstWeek {
            return .decreasing
        } else {
            return .stable
        }
    }
    
    // MARK: - Overall Statistics
    
    var totalEntriesAcrossAll: Int {
        allAddictions.reduce(0) { $0 + ($1.entries?.count ?? 0) }
    }
    
    var totalAddictions: Int {
        allAddictions.count
    }
    
    var entriesThisWeek: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return allAddictions.reduce(0) { total, addiction in
            let entries = addiction.entries ?? []
            return total + entries.filter { $0.timestamp >= weekAgo }.count
        }
    }
}


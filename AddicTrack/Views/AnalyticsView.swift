//
//  AnalyticsView.swift
//  AddicTrack
//
//  Created by AceGreen on 2025-12-12.
//

import SwiftUI
import SwiftData
// import Inject

#if canImport(Charts)
import Charts
#endif

struct AnalyticsView: View {
    // @ObserveInjection var inject
    @Environment(\.modelContext) private var modelContext
    @Bindable var settingsViewModel: SettingsViewModel
    @State private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: TimeRange = .month
    @State private var selectedAddiction: Addiction?
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            if !settingsViewModel.isSignedIn {
                SignInRequiredView()
            } else if viewModel.isLoading {
                ProgressView("Loading analytics...")
            } else if viewModel.allAddictions.isEmpty {
                EmptyAnalyticsView()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Overall Summary
                        OverallSummarySection(viewModel: viewModel)
                        
                        // Time Range Selector
                        TimeRangeSelector(selectedRange: $selectedTimeRange)
                        
                        // Chart Section
                        if let addiction = selectedAddiction ?? viewModel.allAddictions.first {
                            ChartSection(
                                addiction: addiction,
                                viewModel: viewModel,
                                days: selectedTimeRange.days
                            )
                        }
                        
                        // Individual Addiction Stats
                        IndividualStatsSection(
                            viewModel: viewModel,
                            selectedAddiction: $selectedAddiction
                        )
                    }
                    .padding()
                }
                .navigationTitle("Analytics")
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.setCurrentUser(settingsViewModel.currentUser)
        }
        .onChange(of: settingsViewModel.currentUser) { oldValue, newValue in
            viewModel.setCurrentUser(newValue)
        }
        // .enableInjection()
    }
}

struct OverallSummarySection: View {
    let viewModel: AnalyticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            HStack(spacing: 16) {
                SummaryCard(
                    title: "Total Addictions",
                    value: "\(viewModel.totalAddictions)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Total Entries",
                    value: "\(viewModel.totalEntriesAcrossAll)",
                    icon: "chart.bar",
                    color: .green
                )
                
                SummaryCard(
                    title: "This Week",
                    value: "\(viewModel.entriesThisWeek)",
                    icon: "calendar",
                    color: .orange
                )
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TimeRangeSelector: View {
    @Binding var selectedRange: AnalyticsView.TimeRange
    
    var body: some View {
        Picker("Time Range", selection: $selectedRange) {
            ForEach(AnalyticsView.TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ChartSection: View {
    let addiction: Addiction
    let viewModel: AnalyticsViewModel
    let days: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trend: \(addiction.name)")
                .font(.headline)
            
            let data = viewModel.getEntriesOverTime(for: addiction, days: days)
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart(data) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Count", dataPoint.count)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Count", dataPoint.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, days / 5))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                } else {
                    // Fallback for iOS 15
                    SimpleBarChart(data: data)
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            #else
            // Fallback when Charts is not available
            SimpleBarChart(data: data)
                .frame(height: 200)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            #endif
        }
    }
}

struct SimpleBarChart: View {
    let data: [EntryDataPoint]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(data) { point in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(
                            width: max(2, geometry.size.width / CGFloat(data.count) - 2),
                            height: max(4, CGFloat(point.count) * 10)
                        )
                }
            }
        }
    }
}

struct IndividualStatsSection: View {
    let viewModel: AnalyticsViewModel
    @Binding var selectedAddiction: Addiction?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("By Addiction")
                .font(.headline)
            
            ForEach(viewModel.allAddictions) { addiction in
                let stats = viewModel.getAddictionStats(addiction)
                
                AddictionStatCard(
                    stats: stats,
                    isSelected: selectedAddiction?.id == addiction.id
                ) {
                    selectedAddiction = addiction
                }
            }
        }
    }
}

struct AddictionStatCard: View {
    let stats: AddictionStats
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: stats.addiction.iconName)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text(stats.addiction.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    TrendIndicator(trend: stats.recentTrend)
                }
                
                HStack(spacing: 20) {
                    StatItem(label: "Total", value: "\(stats.totalEntries)")
                    StatItem(label: "This Week", value: "\(stats.entriesThisWeek)")
                    StatItem(label: "This Month", value: "\(stats.entriesThisMonth)")
                }
                
                if let daysSince = stats.daysSinceLastEntry {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("\(daysSince) days since last entry")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Longest streak: \(stats.longestStreak) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct TrendIndicator: View {
    let trend: TrendDirection
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trendIcon)
                .foregroundColor(trendColor)
            Text(trendText)
                .font(.caption)
                .foregroundColor(trendColor)
        }
    }
    
    private var trendIcon: String {
        switch trend {
        case .increasing: return "arrow.up.right"
        case .decreasing: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .increasing: return .red
        case .decreasing: return .green
        case .stable: return .gray
        }
    }
    
    private var trendText: String {
        switch trend {
        case .increasing: return "Up"
        case .decreasing: return "Down"
        case .stable: return "Stable"
        }
    }
}

struct EmptyAnalyticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Data Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start tracking addictions to see your analytics and trends")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    AnalyticsView(settingsViewModel: SettingsViewModel())
        .modelContainer(for: [User.self, Addiction.self, AddictionEntry.self], inMemory: true)
}


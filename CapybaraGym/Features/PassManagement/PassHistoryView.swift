//
//  PassHistoryView.swift
//  CapybaraGym
//
//  Pass usage history
//

import SwiftUI

struct PassHistoryView: View {
    @StateObject private var viewModel = PassHistoryViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Summary Cards
                summarySection
                
                // Usage Chart
                usageChartSection
                
                // History List
                historyListSection
            }
            .padding()
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Summary Section
    private var summarySection: some View {
        HStack(spacing: 12) {
            SummaryCard(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.totalVisits)",
                label: "Total Visits",
                color: .occupancyLow
            )
            
            SummaryCard(
                icon: "clock.fill",
                value: viewModel.totalHours,
                label: "Total Hours",
                color: .primaryBrown
            )
            
            SummaryCard(
                icon: "flame.fill",
                value: "\(viewModel.totalCalories)",
                label: "Calories",
                color: .occupancyMedium
            )
        }
    }
    
    // MARK: - Usage Chart Section
    private var usageChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Monthly Usage")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(PassHistoryViewModel.Period.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.menu)
                .tint(.primaryBrown)
            }
            
            // Bar Chart
            VStack(spacing: 16) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(viewModel.monthlyData) { month in
                        VStack(spacing: 8) {
                            // Value Label
                            Text("\(month.visits)")
                                .font(.captionMedium)
                                .foregroundColor(.secondaryText)
                            
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(month.isCurrent ? Color.primaryBrown : Color.primaryBrown.opacity(0.4))
                                .frame(height: CGFloat(month.visits) * 8)
                            
                            // Month Label
                            Text(month.shortName)
                                .font(.caption)
                                .foregroundColor(month.isCurrent ? .primaryBrown : .tertiaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 150)
                .padding(.vertical, 8)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
    
    // MARK: - History List Section
    private var historyListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Menu {
                    Button("All Time") { viewModel.filter = .all }
                    Button("This Month") { viewModel.filter = .thisMonth }
                    Button("This Week") { viewModel.filter = .thisWeek }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.caption)
                        Text("Filter")
                            .font(.bodySmall)
                    }
                    .foregroundColor(.primaryBrown)
                }
            }
            
            if viewModel.historyItems.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No History Yet",
                    message: "Your gym visit history will appear here"
                )
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.groupedHistory.keys.sorted(by: >), id: \.self) { date in
                        VStack(alignment: .leading, spacing: 12) {
                            // Date Header
                            Text(date)
                                .font(.captionMedium)
                                .foregroundColor(.secondaryText)
                                .padding(.horizontal, 4)
                            
                            // Items for this date
                            VStack(spacing: 8) {
                                ForEach(viewModel.groupedHistory[date] ?? []) { item in
                                    HistoryItemRow(item: item)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: PassHistoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(item.typeColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.typeIcon)
                    .font(.system(size: 18))
                    .foregroundColor(item.typeColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.gymName)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                
                HStack(spacing: 8) {
                    Text(item.time)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                    
                    Text(item.duration)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            // Status
            HStack(spacing: 4) {
                Image(systemName: item.statusIcon)
                    .font(.caption2)
                Text(item.status)
                    .font(.caption)
            }
            .foregroundColor(item.statusColor)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusMedium)
    }
}

// MARK: - Monthly Data Model
struct MonthlyData: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let visits: Int
    let isCurrent: Bool
}

// MARK: - Pass History Item Model
struct PassHistoryItem: Identifiable {
    let id: String
    let gymName: String
    let date: Date
    let time: String
    let duration: String
    let type: ActivityType
    let status: String
    
    var typeIcon: String {
        switch type {
        case .checkIn: return "checkmark.circle.fill"
        case .classBooking: return "calendar.badge.checkmark"
        case .personalTraining: return "person.fill"
        }
    }
    
    var typeColor: Color {
        switch type {
        case .checkIn: return .occupancyLow
        case .classBooking: return .primaryBrown
        case .personalTraining: return .occupancyMedium
        }
    }
    
    var statusIcon: String {
        switch status {
        case "Completed": return "checkmark.circle.fill"
        case "Cancelled": return "xmark.circle.fill"
        default: return "clock"
        }
    }
    
    var statusColor: Color {
        switch status {
        case "Completed": return .occupancyLow
        case "Cancelled": return .errorRed
        default: return .warningOrange
        }
    }
    
    enum ActivityType {
        case checkIn
        case classBooking
        case personalTraining
    }
    
    static let samples = [
        PassHistoryItem(
            id: "1",
            gymName: "Capybara Fitness Center",
            date: Date(),
            time: "8:30 AM",
            duration: "1h 30m",
            type: .checkIn,
            status: "Completed"
        ),
        PassHistoryItem(
            id: "2",
            gymName: "Iron Pump Gym",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            time: "6:00 PM",
            duration: "45m",
            type: .classBooking,
            status: "Completed"
        ),
        PassHistoryItem(
            id: "3",
            gymName: "Capybara Fitness Center",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            time: "7:00 AM",
            duration: "1h",
            type: .checkIn,
            status: "Completed"
        ),
        PassHistoryItem(
            id: "4",
            gymName: "Zen Wellness Studio",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            time: "9:00 AM",
            duration: "1h",
            type: .classBooking,
            status: "Cancelled"
        ),
        PassHistoryItem(
            id: "5",
            gymName: "Capybara Fitness Center",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            time: "5:30 PM",
            duration: "2h",
            type: .checkIn,
            status: "Completed"
        )
    ]
}

// MARK: - ViewModel
@MainActor
class PassHistoryViewModel: ObservableObject {
    enum Period: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var id: String { rawValue }
    }
    
    enum Filter: String, CaseIterable {
        case all = "All Time"
        case thisMonth = "This Month"
        case thisWeek = "This Week"
    }
    
    @Published var selectedPeriod: Period = .month
    @Published var filter: Filter = .all
    @Published var totalVisits = 47
    @Published var totalHours = "68h"
    @Published var totalCalories = 12450
    
    @Published var monthlyData: [MonthlyData] = [
        MonthlyData(name: "January", shortName: "Jan", visits: 8, isCurrent: false),
        MonthlyData(name: "February", shortName: "Feb", visits: 12, isCurrent: false),
        MonthlyData(name: "March", shortName: "Mar", visits: 10, isCurrent: false),
        MonthlyData(name: "April", shortName: "Apr", visits: 15, isCurrent: false),
        MonthlyData(name: "May", shortName: "May", visits: 18, isCurrent: false),
        MonthlyData(name: "June", shortName: "Jun", visits: 14, isCurrent: true)
    ]
    
    @Published var historyItems: [PassHistoryItem] = PassHistoryItem.samples
    
    var groupedHistory: [String: [PassHistoryItem]] {
        Dictionary(grouping: historyItems) { item in
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: item.date, relativeTo: Date())
        }
    }
}

// MARK: - Preview
#Preview("Pass History View") {
    PassHistoryView()
}

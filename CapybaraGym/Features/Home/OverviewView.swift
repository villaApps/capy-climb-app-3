//
//  OverviewView.swift
//  CapybaraGym
//
//  Dashboard overview with stats and quick info
//

import SwiftUI

struct OverviewView: View {
    @StateObject private var viewModel = OverviewViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Welcome Card
                welcomeCard
                
                // Today's Stats
                todayStatsSection
                
                // Weekly Progress
                weeklyProgressSection
                
                // Active Pass
                if let activePass = viewModel.activePass {
                    activePassSection(pass: activePass)
                }
                
                // Upcoming Classes
                upcomingClassesSection
                
                // Recommended Gyms
                recommendedGymsSection
            }
            .padding()
            .padding(.bottom, 32)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Welcome Card
    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.bodyMedium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(viewModel.userName)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Streak Badge
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                    Text("\(viewModel.currentStreak)")
                        .font(.captionMedium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
            }
            
            Text("Ready to crush your fitness goals today?")
                .font(.bodySmall)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBrown, Color.primaryBrownLight]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.elevated)
    }
    
    // MARK: - Today Stats Section
    private var todayStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Activity")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(spacing: 12) {
                StatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.todayCalories)",
                    label: "Calories",
                    color: .occupancyMedium
                )
                
                StatCard(
                    icon: "clock.fill",
                    value: "\(viewModel.todayMinutes)m",
                    label: "Active Time",
                    color: .primaryBrown
                )
                
                StatCard(
                    icon: "figure.walk",
                    value: "\(viewModel.todaySteps)",
                    label: "Steps",
                    color: .occupancyLow
                )
            }
        }
    }
    
    // MARK: - Weekly Progress Section
    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            // Bar Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.weeklyData) { day in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(day.isToday ? Color.primaryBrown : Color.primaryBrown.opacity(0.3))
                            .frame(height: CGFloat(day.value) * 1.5)
                        
                        // Day Label
                        Text(day.shortName)
                            .font(.caption)
                            .foregroundColor(day.isToday ? .primaryBrown : .tertiaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
            .padding(.vertical, 8)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
    }
    
    // MARK: - Active Pass Section
    private func activePassSection(pass: GymPass) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Pass")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                NavigationLink(destination: PassManagementView()) {
                    Text("View All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            PassCard(pass: pass, showQRCode: false)
        }
    }
    
    // MARK: - Upcoming Classes Section
    private var upcomingClassesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Upcoming Classes")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            if viewModel.upcomingClasses.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    title: "No Upcoming Classes",
                    message: "Book a class to see it here"
                )
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.upcomingClasses.prefix(2)) { gymClass in
                        ClassRow(gymClass: gymClass)
                    }
                }
            }
        }
    }
    
    // MARK: - Recommended Gyms Section
    private var recommendedGymsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended For You")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                NavigationLink(destination: FacilitiesView()) {
                    Text("See All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recommendedGyms) { gym in
                        CompactGymRecommendation(gym: gym)
                    }
                }
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
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
        .cornerRadius(Layout.radiusMedium)
    }
}

// MARK: - Class Row
struct ClassRow: View {
    let gymClass: GymClass
    
    var body: some View {
        HStack(spacing: 12) {
            // Time
            VStack(spacing: 2) {
                Text(gymClass.startTime)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                Text(gymClass.duration)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .frame(width: 50)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 2)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gymClass.name)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                
                Text(gymClass.instructor)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption2)
                    Text(gymClass.location)
                        .font(.caption)
                }
                .foregroundColor(.tertiaryText)
            }
            
            Spacer()
            
            // Spots
            VStack(spacing: 4) {
                Text("\(gymClass.spotsLeft)")
                    .font(.headline)
                    .foregroundColor(gymClass.spotsLeft < 5 ? .errorRed : .occupancyLow)
                Text("spots")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusMedium)
    }
}

// MARK: - Compact Gym Recommendation
struct CompactGymRecommendation: View {
    let gym: Gym
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 140, height: 100)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(.tertiaryText)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(gym.name)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.warningOrange)
                    Text(String(format: "%.1f", gym.rating))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Text("\(String(format: "%.1f", gym.distance)) km away")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
        }
        .frame(width: 140)
    }
}

// MARK: - Weekly Data Model
struct WeeklyData: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let value: Int
    let isToday: Bool
}

// MARK: - Gym Class Model
struct GymClass: Identifiable {
    let id: String
    let name: String
    let instructor: String
    let location: String
    let startTime: String
    let duration: String
    let spotsLeft: Int
    
    static let samples = [
        GymClass(
            id: "1",
            name: "Morning Yoga",
            instructor: "Sarah Chen",
            location: "Studio A",
            startTime: "8:00",
            duration: "60 min",
            spotsLeft: 5
        ),
        GymClass(
            id: "2",
            name: "HIIT Blast",
            instructor: "Mike Ross",
            location: "Main Floor",
            startTime: "18:00",
            duration: "45 min",
            spotsLeft: 12
        )
    ]
}

// MARK: - ViewModel
@MainActor
class OverviewViewModel: ObservableObject {
    @Published var userName = "Alex"
    @Published var greeting = "Good Morning"
    @Published var currentStreak = 5
    @Published var todayCalories = 320
    @Published var todayMinutes = 45
    @Published var todaySteps = "6,240"
    
    @Published var weeklyData: [WeeklyData] = [
        WeeklyData(name: "Monday", shortName: "M", value: 45, isToday: false),
        WeeklyData(name: "Tuesday", shortName: "T", value: 60, isToday: false),
        WeeklyData(name: "Wednesday", shortName: "W", value: 30, isToday: false),
        WeeklyData(name: "Thursday", shortName: "T", value: 75, isToday: true),
        WeeklyData(name: "Friday", shortName: "F", value: 0, isToday: false),
        WeeklyData(name: "Saturday", shortName: "S", value: 0, isToday: false),
        WeeklyData(name: "Sunday", shortName: "S", value: 0, isToday: false)
    ]
    
    @Published var activePass: GymPass? = .sample
    @Published var upcomingClasses: [GymClass] = GymClass.samples
    @Published var recommendedGyms: [Gym] = Gym.samples
}

// MARK: - Preview
#Preview("Overview View") {
    OverviewView()
}

//
//  HomeView.swift
//  CapybaraGym
//
//  Home screen with featured gyms and overview
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header
                        headerSection
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Search Bar
                        searchBarSection
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        // Quick Actions
                        quickActionsSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Featured Gyms
                        featuredGymsSection
                            .padding(.top, 24)
                        
                        // Nearby Gyms
                        nearbyGymsSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Recent Activity
                        recentActivitySection
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .padding(.bottom, 32)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("Capybara Gym")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showNotifications() }) {
                        ZStack {
                            Image(systemName: "bell")
                                .font(.headline)
                                .foregroundColor(.primaryText)
                            
                            if viewModel.hasUnreadNotifications {
                                Circle()
                                    .fill(Color.errorRed)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good Morning,")
                    .font(.bodyMedium)
                    .foregroundColor(.secondaryText)
                Text(viewModel.userName)
                    .font(.title2)
                    .foregroundColor(.primaryText)
            }
            
            Spacer()
            
            // Profile Image
            NavigationLink(destination: ProfileView()) {
                ZStack {
                    Circle()
                        .fill(Color.primaryBrown.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primaryBrown)
                }
            }
        }
    }
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.bodyMedium)
                    .foregroundColor(.tertiaryText)
                
                TextField("Search gyms, classes...", text: $viewModel.searchText)
                    .font(.bodyMedium)
            }
            .padding(.horizontal, Layout.spacingM)
            .frame(height: 48)
            .background(Color.inputBackground)
            .cornerRadius(Layout.radiusMedium)
            
            // Filter Button
            Button(action: { viewModel.showFilters() }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.headline)
                    .foregroundColor(.primaryBrown)
                    .frame(width: 48, height: 48)
                    .background(Color.inputBackground)
                    .cornerRadius(Layout.radiusMedium)
            }
        }
    }
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                icon: "ticket.fill",
                title: "My Passes",
                color: .primaryBrown,
                action: { viewModel.navigateToPasses() }
            )
            
            QuickActionButton(
                icon: "cart.fill",
                title: "Shop",
                color: .occupancyMedium,
                action: { viewModel.navigateToShop() }
            )
            
            QuickActionButton(
                icon: "calendar",
                title: "Book",
                color: .occupancyLow,
                action: { viewModel.navigateToBooking() }
            )
        }
    }
    
    // MARK: - Featured Gyms Section
    private var featuredGymsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Featured Gyms")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                NavigationLink(destination: FacilitiesView()) {
                    Text("See All")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            .padding(.horizontal)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.featuredGyms) { gym in
                        GymCard(
                            gym: gym,
                            onTap: { viewModel.selectGym(gym) },
                            onFavoriteTap: { viewModel.toggleFavorite(gym) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Nearby Gyms Section
    private var nearbyGymsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Nearby Gyms")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                NavigationLink(destination: GymMapView()) {
                    Text("View Map")
                        .font(.bodySmall)
                        .foregroundColor(.primaryBrown)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.nearbyGyms.prefix(3)) { gym in
                    NearbyGymRow(gym: gym, onTap: { viewModel.selectGym(gym) })
                }
            }
        }
    }
    
    // MARK: - Recent Activity Section
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            if viewModel.recentActivities.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No Recent Activity",
                    message: "Your recent gym visits and bookings will appear here"
                )
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.recentActivities.prefix(3)) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.captionMedium)
                    .foregroundColor(.primaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Nearby Gym Row
struct NearbyGymRow: View {
    let gym: Gym
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Image
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.tertiaryText)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(gym.name)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                    
                    Text(gym.location)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        LiveOccupancyBadge(occupancy: gym.occupancy, capacity: gym.capacity)
                        
                        Text("\(String(format: "%.1f", gym.distance)) km")
                            .font(.caption)
                            .foregroundColor(.tertiaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(activity.iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 18))
                    .foregroundColor(activity.iconColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                
                Text(activity.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
            
            // Time
            Text(activity.timeAgo)
                .font(.caption)
                .foregroundColor(.tertiaryText)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusMedium)
    }
}

// MARK: - Activity Model
struct Activity: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let subtitle: String
    let timeAgo: String
    
    var icon: String {
        switch type {
        case .checkIn: return "checkmark.circle.fill"
        case .booking: return "calendar.badge.checkmark"
        case .purchase: return "cart.fill"
        case .review: return "star.fill"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .checkIn: return .occupancyLow
        case .booking: return .primaryBrown
        case .purchase: return .occupancyMedium
        case .review: return .warningOrange
        }
    }
    
    enum ActivityType {
        case checkIn
        case booking
        case purchase
        case review
    }
}

// MARK: - ViewModel
@MainActor
class HomeViewModel: ObservableObject {
    @Published var userName = "Alex Johnson"
    @Published var searchText = ""
    @Published var hasUnreadNotifications = true
    @Published var featuredGyms: [Gym] = Gym.samples
    @Published var nearbyGyms: [Gym] = Gym.samples
    @Published var recentActivities: [Activity] = []
    
    func refresh() async {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    func showNotifications() {
        // Navigate to notifications
    }
    
    func showFilters() {
        // Show filter sheet
    }
    
    func navigateToPasses() {
        // Navigate to passes
    }
    
    func navigateToShop() {
        // Navigate to shop
    }
    
    func navigateToBooking() {
        // Navigate to booking
    }
    
    func selectGym(_ gym: Gym) {
        // Navigate to gym detail
    }
    
    func toggleFavorite(_ gym: Gym) {
        // Toggle favorite
    }
}

// MARK: - Preview
#Preview("Home View") {
    HomeView()
}

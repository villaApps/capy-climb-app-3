//
//  HomeView.swift
//  CapybaraGym
//
//  Home dashboard screen
//

import SwiftUI

public struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab = "home"
    
    public init() {}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: CapySpacing.large) {
                // Header
                headerSection
                
                // Quick Actions
                quickActionsSection
                
                // Active Pass
                if let activePass = viewModel.activePass {
                    activePassSection(pass: activePass)
                }
                
                // Stats
                statsSection
                
                // Nearby Gyms
                nearbyGymsSection
                
                // Recent Activity
                recentActivitySection
            }
            .padding(.vertical, CapySpacing.medium)
        }
        .background(CapyColors.background)
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                Text("Good \(viewModel.greeting),")
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textSecondary)
                
                Text(viewModel.userName)
                    .font(CapyTypography.heading2)
                    .foregroundColor(CapyColors.textPrimary)
            }
            
            Spacer()
            
            // Profile Button
            NavigationLink(destination: ProfileView()) {
                ZStack {
                    Circle()
                        .fill(CapyColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Text(viewModel.userInitials)
                        .font(CapyTypography.labelMedium)
                        .foregroundColor(CapyColors.primary)
                }
            }
        }
        .padding(.horizontal, CapySpacing.large)
    }
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CapySpacing.medium) {
                QuickActionButton(
                    title: "Scan QR",
                    icon: "qrcode",
                    color: CapyColors.primary
                ) {
                    // Navigate to QR scanner
                }
                
                QuickActionButton(
                    title: "Find Gym",
                    icon: "mappin.and.ellipse",
                    color: CapyColors.info
                ) {
                    // Navigate to map
                }
                
                QuickActionButton(
                    title: "My Passes",
                    icon: "ticket.fill",
                    color: CapyColors.success
                ) {
                    // Navigate to passes
                }
                
                QuickActionButton(
                    title: "Shop",
                    icon: "bag.fill",
                    color: CapyColors.warning
                ) {
                    // Navigate to shop
                }
            }
            .padding(.horizontal, CapySpacing.large)
        }
    }
    
    private func activePassSection(pass: Pass) -> some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Active Pass")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            PassCard(pass: pass)
                .padding(.horizontal, CapySpacing.large)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("This Month")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CapySpacing.medium) {
                    CapyStatCard(
                        title: "Workouts",
                        value: "\(viewModel.monthlyWorkouts)",
                        subtitle: "Total sessions",
                        icon: "flame.fill",
                        iconColor: CapyColors.primary,
                        trend: .up("+12%")
                    )
                    .frame(width: 160)
                    
                    CapyStatCard(
                        title: "Calories",
                        value: "\(viewModel.monthlyCalories)",
                        subtitle: "Kcal burned",
                        icon: "bolt.fill",
                        iconColor: CapyColors.warning,
                        trend: .up("+8%")
                    )
                    .frame(width: 160)
                    
                    CapyStatCard(
                        title: "Active Days",
                        value: "\(viewModel.activeDays)",
                        subtitle: "Days this month",
                        icon: "calendar",
                        iconColor: CapyColors.info,
                        trend: .neutral("On track")
                    )
                    .frame(width: 160)
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
    
    private var nearbyGymsSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            HStack {
                Text("Nearby Gyms")
                    .font(CapyTypography.heading4)
                    .foregroundColor(CapyColors.textPrimary)
                
                Spacer()
                
                NavigationLink("See All") {
                    GymMapView()
                }
                .font(CapyTypography.labelMedium)
                .foregroundColor(CapyColors.primary)
            }
            .padding(.horizontal, CapySpacing.large)
            
            if viewModel.isLoadingGyms {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.nearbyGyms.isEmpty {
                EmptyStateView(
                    icon: "mappin.slash",
                    title: "No gyms found",
                    message: "We couldn't find any gyms near you."
                )
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CapySpacing.medium) {
                        ForEach(viewModel.nearbyGyms.prefix(5)) { gym in
                            GymCard(gym: gym)
                        }
                    }
                    .padding(.horizontal, CapySpacing.large)
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Recent Activity")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            if viewModel.recentActivities.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No recent activity",
                    message: "Your workout history will appear here."
                )
                .padding()
            } else {
                VStack(spacing: CapySpacing.small) {
                    ForEach(viewModel.recentActivities.prefix(5)) { activity in
                        ActivityRow(activity: activity)
                    }
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CapySpacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: CapyRadius.large)
                        .fill(color.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(CapyTypography.labelSmall)
                    .foregroundColor(CapyColors.textPrimary)
            }
        }
    }
}

// MARK: - Pass Card
struct PassCard: View {
    let pass: Pass
    
    var body: some View {
        CapyCard(style: .elevated, padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Text(pass.name)
                            .font(CapyTypography.heading4)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text(pass.type.displayName)
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // QR Code
                    Image(systemName: "qrcode")
                        .font(.system(size: 40))
                        .foregroundColor(CapyColors.primary)
                }
                .padding(CapySpacing.medium)
                .background(CapyColors.primary.opacity(0.05))
                
                // Details
                HStack {
                    VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                        Label("\(pass.remainingVisits) visits left", systemImage: "number")
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textSecondary)
                        
                        if let expiryDate = pass.expiryDate {
                            Label("Expires \(expiryDate.shortDate)", systemImage: "calendar")
                                .font(CapyTypography.bodySmall)
                                .foregroundColor(CapyColors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(CapyColors.textTertiary)
                }
                .padding(CapySpacing.medium)
            }
        }
    }
}

// MARK: - Gym Card
struct GymCard: View {
    let gym: GymLocation
    
    var body: some View {
        CapyCard(style: .elevated, padding: 0) {
            VStack(alignment: .leading, spacing: CapySpacing.small) {
                // Image placeholder
                ZStack {
                    Rectangle()
                        .fill(CapyColors.cardBackground)
                        .frame(width: 200, height: 120)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 40))
                        .foregroundColor(CapyColors.primary.opacity(0.5))
                }
                
                // Info
                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                    Text(gym.name)
                        .font(CapyTypography.labelLarge)
                        .foregroundColor(CapyColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(gym.address)
                        .font(CapyTypography.bodySmall)
                        .foregroundColor(CapyColors.textSecondary)
                        .lineLimit(1)
                    
                    HStack {
                        Label("4.5", systemImage: "star.fill")
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.warning)
                        
                        Text("• 2.3 km")
                            .font(CapyTypography.caption)
                            .foregroundColor(CapyColors.textTertiary)
                        
                        if gym.isOpen == true {
                            Text("• Open")
                                .font(CapyTypography.caption)
                                .foregroundColor(CapyColors.success)
                        }
                    }
                }
                .padding(CapySpacing.small)
            }
        }
        .frame(width: 200)
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        CapyListCard(
            title: activity.title,
            subtitle: activity.subtitle,
            leading: {
                ZStack {
                    Circle()
                        .fill(activity.iconColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: activity.icon)
                        .font(.system(size: 20))
                        .foregroundColor(activity.iconColor)
                }
            },
            trailing: {
                Text(activity.timeAgo)
                    .font(CapyTypography.caption)
                    .foregroundColor(CapyColors.textTertiary)
            }
        )
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: CapySpacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(CapyColors.textTertiary)
            
            Text(title)
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
            
            Text(message)
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

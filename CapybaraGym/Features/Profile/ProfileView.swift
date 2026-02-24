//
//  ProfileView.swift
//  CapybaraGym
//
//  User profile screen
//

import SwiftUI

public struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showSettings = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CapySpacing.large) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Section
                    statsSection
                    
                    // Achievements Section
                    achievementsSection
                    
                    // Menu Section
                    menuSection
                    
                    // Sign Out Button
                    CapyButton(
                        title: "Sign Out",
                        style: .outline,
                        action: {
                            Task {
                                await viewModel.signOut()
                            }
                        }
                    )
                    .padding(.horizontal, CapySpacing.large)
                    .padding(.top, CapySpacing.large)
                }
                .padding(.vertical, CapySpacing.medium)
            }
            .background(CapyColors.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: CapySpacing.medium) {
            // Avatar
            ZStack {
                Circle()
                    .fill(CapyColors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text(viewModel.userInitials)
                    .font(CapyTypography.displaySmall)
                    .foregroundColor(CapyColors.primary)
                
                // Edit button
                Button(action: {
                    showEditProfile = true
                }) {
                    ZStack {
                        Circle()
                            .fill(CapyColors.primary)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: 35, y: 35)
            }
            
            // Name
            Text(viewModel.userName)
                .font(CapyTypography.heading1)
                .foregroundColor(CapyColors.textPrimary)
            
            // Email
            Text(viewModel.userEmail)
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textSecondary)
            
            // Member since
            Text("Member since \(viewModel.memberSince)")
                .font(CapyTypography.caption)
                .foregroundColor(CapyColors.textTertiary)
        }
        .padding(.horizontal, CapySpacing.large)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: CapySpacing.medium) {
            ProfileStatItem(
                value: "\(viewModel.totalWorkouts)",
                label: "Workouts"
            )
            
            Divider()
                .frame(height: 50)
            
            ProfileStatItem(
                value: "\(viewModel.totalCalories)",
                label: "Calories"
            )
            
            Divider()
                .frame(height: 50)
            
            ProfileStatItem(
                value: "\(viewModel.streakDays)",
                label: "Day Streak"
            )
        }
        .padding(CapySpacing.medium)
        .background(CapyColors.cardElevated)
        .cornerRadius(CapyRadius.xLarge)
        .shadow(color: CapyColors.shadow, radius: 8, x: 0, y: 4)
        .padding(.horizontal, CapySpacing.large)
    }
    
    // MARK: - Achievements Section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Achievements")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CapySpacing.medium) {
                    ForEach(viewModel.achievements) { achievement in
                        AchievementBadge(achievement: achievement)
                    }
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: CapySpacing.small) {
            MenuItem(
                icon: "gearshape.fill",
                title: "Settings",
                color: CapyColors.primary
            ) {
                showSettings = true
            }
            
            MenuItem(
                icon: "creditcard.fill",
                title: "Payment Methods",
                color: CapyColors.success
            ) {}
            
            MenuItem(
                icon: "bell.fill",
                title: "Notifications",
                color: CapyColors.warning
            ) {}
            
            MenuItem(
                icon: "shield.fill",
                title: "Privacy & Security",
                color: CapyColors.info
            ) {}
            
            MenuItem(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                color: CapyColors.accentSecondary
            ) {}
            
            MenuItem(
                icon: "doc.text.fill",
                title: "Terms & Privacy",
                color: CapyColors.accentTertiary
            ) {}
        }
        .padding(.horizontal, CapySpacing.large)
    }
}

// MARK: - Profile Stat Item
struct ProfileStatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: CapySpacing.xxSmall) {
            Text(value)
                .font(CapyTypography.heading2)
                .foregroundColor(CapyColors.primary)
            
            Text(label)
                .font(CapyTypography.bodySmall)
                .foregroundColor(CapyColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievement Badge
struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: CapySpacing.small) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.2) : CapyColors.cardBackground)
                    .frame(width: 72, height: 72)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundColor(achievement.isUnlocked ? achievement.color : CapyColors.textTertiary)
                
                if achievement.isUnlocked {
                    ZStack {
                        Circle()
                            .fill(CapyColors.success)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: 25, y: 25)
                }
            }
            
            Text(achievement.name)
                .font(CapyTypography.caption)
                .foregroundColor(achievement.isUnlocked ? CapyColors.textPrimary : CapyColors.textTertiary)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

// MARK: - Menu Item
struct MenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            CapyListCard(
                title: title,
                leading: {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                    }
                },
                trailing: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(CapyColors.textTertiary)
                }
            )
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phoneNumber = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section("Profile Photo") {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(CapyColors.primary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Text(viewModel.userInitials)
                                .font(CapyTypography.heading2)
                                .foregroundColor(CapyColors.primary)
                        }
                        
                        Spacer()
                    }
                    
                    Button("Change Photo") {
                        // Show photo picker
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(CapyColors.primary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile(
                                firstName: firstName,
                                lastName: lastName,
                                phoneNumber: phoneNumber
                            )
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                // Load current values
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var biometricEnabled = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("General") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Location Services", isOn: $locationEnabled)
                    Toggle("Biometric Authentication", isOn: $biometricEnabled)
                }
                
                Section("Account") {
                    NavigationLink("Change Password") {}
                    NavigationLink("Email Preferences") {}
                    NavigationLink("Linked Accounts") {}
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(AppConstants.fullVersion)
                            .foregroundColor(CapyColors.textSecondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://capybaragym.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://capybaragym.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Models
struct Achievement: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
}

// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

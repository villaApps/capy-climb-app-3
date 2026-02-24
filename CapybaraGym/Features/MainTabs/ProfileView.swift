//
//  ProfileView.swift
//  CapybaraGym
//
//  User profile screen
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Profile Header
                        profileHeader
                        
                        // Stats Section
                        statsSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Membership Section
                        membershipSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Menu Section
                        menuSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Support Section
                        supportSection
                            .padding(.horizontal)
                            .padding(.top, 20)
                        
                        // Logout Button
                        logoutButton
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: EditProfileView()) {
                        Image(systemName: "pencil")
                            .font(.headline)
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.primaryBrown.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.primaryBrown)
                
                // Edit Badge
                Circle()
                    .fill(Color.primaryBrown)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                    .offset(x: 35, y: 35)
            }
            
            // Name and Email
            VStack(spacing: 4) {
                Text(viewModel.user.name)
                    .font(.title2)
                    .foregroundColor(.primaryText)
                
                Text(viewModel.user.email)
                    .font(.bodyMedium)
                    .foregroundColor(.secondaryText)
            }
            
            // Location
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
                Text(viewModel.user.location)
                    .font(.bodySmall)
                    .foregroundColor(.tertiaryText)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(value: "\(viewModel.user.workouts)", label: "Workouts")
            
            Divider()
                .frame(height: 40)
            
            StatItem(value: "\(viewModel.user.hours)", label: "Hours")
            
            Divider()
                .frame(height: 40)
            
            StatItem(value: "\(viewModel.user.streak)", label: "Day Streak")
        }
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
    }
    
    // MARK: - Membership Section
    private var membershipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Membership")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.primaryBrown.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.primaryBrown)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user.membershipType)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                    
                    Text("Valid until \(viewModel.user.membershipExpiry)")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Button(action: { viewModel.upgradeMembership() }) {
                    Text("Upgrade")
                        .font(.captionMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryBrown)
                        .cornerRadius(Layout.radiusFull)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(Layout.radiusLarge)
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                MenuRow(icon: "ticket.fill", title: "My Passes", action: { viewModel.navigateToPasses() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "creditcard.fill", title: "Payment Methods", action: { viewModel.navigateToPayments() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "bell.fill", title: "Notifications", action: { viewModel.navigateToNotifications() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "lock.fill", title: "Privacy & Security", action: { viewModel.navigateToPrivacy() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "gearshape.fill", title: "App Settings", action: { viewModel.navigateToSettings() })
            }
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
    
    // MARK: - Support Section
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                MenuRow(icon: "questionmark.circle.fill", title: "Help Center", action: { viewModel.navigateToHelp() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "message.fill", title: "Contact Us", action: { viewModel.navigateToContact() })
                Divider().padding(.leading, 50)
                MenuRow(icon: "doc.text.fill", title: "Terms & Privacy", action: { viewModel.navigateToTerms() })
            }
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
    
    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: { viewModel.logout() }) {
            HStack {
                Image(systemName: "arrow.right.square.fill")
                    .font(.bodyMedium)
                Text("Log Out")
                    .font(.bodyMedium)
            }
            .foregroundColor(.errorRed)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.errorRed.opacity(0.1))
            .cornerRadius(Layout.radiusMedium)
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .foregroundColor(.primaryBrown)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primaryBrown)
                    .frame(width: 24)
                
                Text(title)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Alex Johnson"
    @State private var email = "alex@example.com"
    @State private var phone = "+1 234 567 890"
    @State private var location = "San Francisco, CA"
    
    var body: some View {
        Form {
            Section("Profile Photo") {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color.primaryBrown.opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.primaryBrown)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                
                Button("Change Photo") {}
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primaryBrown)
            }
            
            Section("Personal Information") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Phone", text: $phone)
                TextField("Location", text: $location)
            }
            
            Section {
                Button("Save Changes") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primaryBrown)
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
        }
    }
}

// MARK: - User Model
struct User {
    let id: String
    let name: String
    let email: String
    let location: String
    let avatar: String?
    let workouts: Int
    let hours: Int
    let streak: Int
    let membershipType: String
    let membershipExpiry: String
}

// MARK: - ViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user = User(
        id: "1",
        name: "Alex Johnson",
        email: "alex@example.com",
        location: "San Francisco, CA",
        avatar: nil,
        workouts: 47,
        hours: 86,
        streak: 5,
        membershipType: "Premium Member",
        membershipExpiry: "Dec 31, 2024"
    )
    
    func upgradeMembership() {
        // Navigate to upgrade
    }
    
    func navigateToPasses() {}
    func navigateToPayments() {}
    func navigateToNotifications() {}
    func navigateToPrivacy() {}
    func navigateToSettings() {}
    func navigateToHelp() {}
    func navigateToContact() {}
    func navigateToTerms() {}
    
    func logout() {
        // Handle logout
    }
}

// MARK: - Preview
#Preview("Profile View") {
    ProfileView()
}

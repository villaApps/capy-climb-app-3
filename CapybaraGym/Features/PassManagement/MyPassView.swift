//
//  MyPassView.swift
//  CapybaraGym
//
//  Active pass with QR code display
//

import SwiftUI

struct MyPassView: View {
    let pass: GymPass
    @StateObject private var viewModel = MyPassViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Pass Card with QR
                        passCardSection
                        
                        // Pass Details
                        passDetailsSection
                        
                        // Usage Info
                        usageInfoSection
                        
                        // Actions
                        actionsSection
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Pass Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.sharePass() }) {
                            Label("Share Pass", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { viewModel.addToWallet() }) {
                            Label("Add to Wallet", systemImage: "wallet.pass")
                        }
                        Button(role: .destructive, action: { viewModel.reportIssue() }) {
                            Label("Report Issue", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.headline)
                            .foregroundColor(.primaryBrown)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                ShareSheet(items: ["Check out my Capybara Gym pass!"])
            }
        }
    }
    
    // MARK: - Pass Card Section
    private var passCardSection: some View {
        VStack(spacing: 20) {
            // Pass Card
            PassCard(pass: pass, showQRCode: true)
            
            // QR Code Hint
            Text("Show this QR code at the entrance")
                .font(.bodySmall)
                .foregroundColor(.secondaryText)
        }
    }
    
    // MARK: - Pass Details Section
    private var passDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pass Information")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                DetailInfoRow(icon: "building.2", title: "Gym", value: pass.gymName)
                Divider().padding(.leading, 44)
                DetailInfoRow(icon: "ticket", title: "Pass Type", value: pass.passType)
                Divider().padding(.leading, 44)
                DetailInfoRow(icon: "number", title: "Pass ID", value: pass.id)
                Divider().padding(.leading, 44)
                DetailInfoRow(icon: "calendar", title: "Purchase Date", value: pass.formattedPurchaseDate)
                Divider().padding(.leading, 44)
                DetailInfoRow(icon: "calendar.badge.clock", title: "Valid Until", value: pass.formattedExpiryDate)
                
                if let visits = pass.visitsRemaining {
                    Divider().padding(.leading, 44)
                    DetailInfoRow(icon: "person.2", title: "Visits Remaining", value: "\(visits)")
                }
            }
            .padding(.vertical, 8)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
    
    // MARK: - Usage Info Section
    private var usageInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage Information")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(spacing: 12) {
                UsageStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.totalCheckIns)",
                    label: "Total Check-ins",
                    color: .occupancyLow
                )
                
                UsageStatCard(
                    icon: "clock.arrow.circlepath",
                    value: viewModel.lastUsed,
                    label: "Last Used",
                    color: .primaryBrown
                )
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { viewModel.renewPass() }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.bodyMedium)
                    Text("Renew Pass")
                        .font(.button)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.primaryButtonHeight)
                .background(Color.primaryBrown)
                .cornerRadius(Layout.radiusFull)
            }
            
            Button(action: { viewModel.giftPass() }) {
                HStack(spacing: 8) {
                    Image(systemName: "gift")
                        .font(.bodyMedium)
                    Text("Gift to Friend")
                        .font(.button)
                }
                .foregroundColor(.primaryBrown)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.primaryButtonHeight)
                .background(Color.primaryBrown.opacity(0.1))
                .cornerRadius(Layout.radiusFull)
            }
        }
    }
}

// MARK: - Detail Info Row
struct DetailInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.primaryBrown)
                .frame(width: 32)
            
            Text(title)
                .font(.bodySmall)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.bodyMedium)
                .foregroundColor(.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Usage Stat Card
struct UsageStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
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

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ViewModel
@MainActor
class MyPassViewModel: ObservableObject {
    @Published var showShareSheet = false
    @Published var totalCheckIns = 12
    @Published var lastUsed = "Yesterday"
    
    func sharePass() {
        showShareSheet = true
    }
    
    func addToWallet() {
        // Add to Apple Wallet
    }
    
    func reportIssue() {
        // Report issue
    }
    
    func renewPass() {
        // Renew pass
    }
    
    func giftPass() {
        // Gift pass
    }
}

// MARK: - Preview
#Preview("My Pass View") {
    MyPassView(pass: .sample)
}

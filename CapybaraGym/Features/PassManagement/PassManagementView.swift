//
//  PassManagementView.swift
//  CapybaraGym
//
//  Pass management screen
//

import SwiftUI

public struct PassManagementView: View {
    
    @StateObject private var viewModel = PassManagementViewModel()
    @State private var selectedPass: Pass?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                CapyColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: CapySpacing.large) {
                        // Active Pass Section
                        if let activePass = viewModel.activePass {
                            ActivePassSection(pass: activePass) {
                                selectedPass = activePass
                            }
                        }
                        
                        // Pass History
                        PassHistorySection(passes: viewModel.passHistory)
                        
                        // Quick Purchase
                        QuickPurchaseSection()
                    }
                    .padding(.vertical, CapySpacing.medium)
                }
            }
            .navigationTitle("My Passes")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedPass) { pass in
                PassDetailView(pass: pass)
            }
        }
    }
}

// MARK: - Active Pass Section
struct ActivePassSection: View {
    let pass: Pass
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Active Pass")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            Button(action: onTap) {
                CapyCard(style: .elevated, padding: 0) {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                                Text(pass.name)
                                    .font(CapyTypography.heading3)
                                    .foregroundColor(CapyColors.textPrimary)
                                
                                Text(pass.type.displayName)
                                    .font(CapyTypography.bodyMedium)
                                    .foregroundColor(CapyColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Status Badge
                            Text("Active")
                                .font(CapyTypography.labelSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, CapySpacing.small)
                                .padding(.vertical, CapySpacing.xxSmall)
                                .background(CapyColors.success)
                                .cornerRadius(CapyRadius.small)
                        }
                        .padding(CapySpacing.medium)
                        .background(CapyColors.primary)
                        .foregroundColor(.white)
                        
                        // Details
                        HStack(spacing: CapySpacing.large) {
                            StatItem(
                                value: "\(pass.remainingVisits)",
                                label: "Visits Left"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatItem(
                                value: pass.expiryDate?.shortDate ?? "N/A",
                                label: "Expires"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatItem(
                                value: "\(pass.totalVisits - pass.remainingVisits)",
                                label: "Used"
                            )
                        }
                        .padding(CapySpacing.medium)
                        
                        // QR Code Preview
                        HStack {
                            Spacer()
                            
                            VStack(spacing: CapySpacing.small) {
                                Image(systemName: "qrcode")
                                    .font(.system(size: 80))
                                    .foregroundColor(CapyColors.textPrimary)
                                
                                Text("Tap to show QR code")
                                    .font(CapyTypography.caption)
                                    .foregroundColor(CapyColors.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(CapySpacing.medium)
                        .background(CapyColors.background)
                    }
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: CapySpacing.xxSmall) {
            Text(value)
                .font(CapyTypography.heading3)
                .foregroundColor(CapyColors.textPrimary)
            
            Text(label)
                .font(CapyTypography.caption)
                .foregroundColor(CapyColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Pass History Section
struct PassHistorySection: View {
    let passes: [Pass]
    
    var body: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Pass History")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            if passes.isEmpty {
                EmptyStateView(
                    icon: "ticket",
                    title: "No pass history",
                    message: "Your purchased passes will appear here."
                )
                .padding()
            } else {
                LazyVStack(spacing: CapySpacing.small) {
                    ForEach(passes) { pass in
                        HistoryPassRow(pass: pass)
                    }
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
}

// MARK: - History Pass Row
struct HistoryPassRow: View {
    let pass: Pass
    
    var body: some View {
        CapyListCard(
            title: pass.name,
            subtitle: "Purchased on \(pass.purchaseDate.shortDate)",
            leading: {
                ZStack {
                    Circle()
                        .fill(pass.isActive ? CapyColors.success.opacity(0.1) : CapyColors.textTertiary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 20))
                        .foregroundColor(pass.isActive ? CapyColors.success : CapyColors.textTertiary)
                }
            },
            trailing: {
                if pass.isActive {
                    Text("Active")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.success)
                } else {
                    Text("Expired")
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.textTertiary)
                }
            }
        )
    }
}

// MARK: - Quick Purchase Section
struct QuickPurchaseSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: CapySpacing.small) {
            Text("Quick Purchase")
                .font(CapyTypography.heading4)
                .foregroundColor(CapyColors.textPrimary)
                .padding(.horizontal, CapySpacing.large)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CapySpacing.medium) {
                    PurchaseCard(
                        title: "Day Pass",
                        price: "$15",
                        description: "24-hour access",
                        color: CapyColors.info
                    )
                    
                    PurchaseCard(
                        title: "Weekly Pass",
                        price: "$49",
                        description: "7-day access",
                        color: CapyColors.warning
                    )
                    
                    PurchaseCard(
                        title: "Monthly Pass",
                        price: "$99",
                        description: "30-day access",
                        color: CapyColors.success
                    )
                }
                .padding(.horizontal, CapySpacing.large)
            }
        }
    }
}

// MARK: - Purchase Card
struct PurchaseCard: View {
    let title: String
    let price: String
    let description: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            CapyCard(style: .elevated, padding: CapySpacing.medium) {
                VStack(alignment: .leading, spacing: CapySpacing.small) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.1))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "ticket.fill")
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    }
                    
                    Text(title)
                        .font(CapyTypography.heading5)
                        .foregroundColor(CapyColors.textPrimary)
                    
                    Text(price)
                        .font(CapyTypography.heading3)
                        .foregroundColor(color)
                    
                    Text(description)
                        .font(CapyTypography.caption)
                        .foregroundColor(CapyColors.textSecondary)
                }
                .frame(width: 140)
            }
        }
    }
}

// MARK: - Pass Detail View
struct PassDetailView: View {
    let pass: Pass
    @State private var qrCodeImage: UIImage?
    @State private var isGeneratingQR = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CapySpacing.large) {
                    // Pass Info
                    CapyCard(style: .elevated, padding: CapySpacing.large) {
                        VStack(spacing: CapySpacing.medium) {
                            // Header
                            HStack {
                                VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
                                    Text(pass.name)
                                        .font(CapyTypography.heading2)
                                        .foregroundColor(CapyColors.textPrimary)
                                    
                                    Text(pass.type.displayName)
                                        .font(CapyTypography.bodyMedium)
                                        .foregroundColor(CapyColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text("Active")
                                    .font(CapyTypography.labelMedium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, CapySpacing.small)
                                    .padding(.vertical, CapySpacing.xxSmall)
                                    .background(CapyColors.success)
                                    .cornerRadius(CapyRadius.small)
                            }
                            
                            Divider()
                            
                            // Stats
                            HStack(spacing: CapySpacing.large) {
                                DetailStatItem(
                                    value: "\(pass.remainingVisits)",
                                    label: "Visits Left"
                                )
                                
                                DetailStatItem(
                                    value: "\(pass.totalVisits - pass.remainingVisits)",
                                    label: "Used"
                                )
                                
                                DetailStatItem(
                                    value: pass.expiryDate?.shortDate ?? "N/A",
                                    label: "Expires"
                                )
                            }
                        }
                    }
                    .padding(.horizontal, CapySpacing.large)
                    
                    // QR Code
                    VStack(spacing: CapySpacing.medium) {
                        Text("Show this QR code at the gym")
                            .font(CapyTypography.bodyMedium)
                            .foregroundColor(CapyColors.textSecondary)
                        
                        if isGeneratingQR {
                            ProgressView()
                                .frame(width: 250, height: 250)
                        } else if let qrImage = qrCodeImage {
                            Image(uiImage: qrImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .padding(CapySpacing.large)
                                .background(CapyColors.cardElevated)
                                .cornerRadius(CapyRadius.xLarge)
                                .shadow(color: CapyColors.shadow, radius: 8, x: 0, y: 4)
                        }
                        
                        // Timer
                        QRTimerView()
                    }
                    
                    Spacer()
                }
                .padding(.vertical, CapySpacing.large)
            }
            .background(CapyColors.background)
            .navigationTitle("Pass Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateQRCode()
            }
        }
    }
    
    private func generateQRCode() {
        Task {
            isGeneratingQR = true
            defer { isGeneratingQR = false }
            
            do {
                let qrService = QRCodeService.shared
                qrCodeImage = try await qrService.generatePassQRCode(
                    passId: pass.id,
                    userId: AuthService.shared.currentUser?.id ?? ""
                )
            } catch {
                Logger.error("Failed to generate QR code: \(error)")
            }
        }
    }
}

// MARK: - Detail Stat Item
struct DetailStatItem: View {
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

// MARK: - QR Timer View
struct QRTimerView: View {
    @State private var timeRemaining = 60
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: CapySpacing.xxSmall) {
            Image(systemName: "clock")
                .font(.system(size: 14))
                .foregroundColor(CapyColors.textSecondary)
            
            Text("Refreshes in \(timeRemaining)s")
                .font(CapyTypography.caption)
                .foregroundColor(CapyColors.textSecondary)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timeRemaining = 60
                // Refresh QR code
            }
        }
    }
}

// MARK: - Preview
struct PassManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PassManagementView()
    }
}

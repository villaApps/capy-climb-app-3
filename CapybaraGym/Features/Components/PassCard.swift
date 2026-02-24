//
//  PassCard.swift
//  CapybaraGym
//
//  Pass display card component
//

import SwiftUI

struct PassCard: View {
    let pass: GymPass
    let onTap: (() -> Void)?
    let showQRCode: Bool
    
    init(pass: GymPass, onTap: (() -> Void)? = nil, showQRCode: Bool = false) {
        self.pass = pass
        self.onTap = onTap
        self.showQRCode = showQRCode
    }
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pass.gymName)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(pass.passType)
                            .font(.bodySmall)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    StatusBadge(status: pass.status)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                
                // Pass Details
                HStack(spacing: 24) {
                    PassDetailItem(
                        icon: "calendar",
                        title: "Valid Until",
                        value: pass.formattedExpiryDate
                    )
                    
                    PassDetailItem(
                        icon: "clock",
                        title: "Time Left",
                        value: pass.timeRemaining
                    )
                    
                    if pass.visitsRemaining != nil {
                        PassDetailItem(
                            icon: "number",
                            title: "Visits",
                            value: "\(pass.visitsRemaining!) left"
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // QR Code Section
                if showQRCode {
                    VStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        
                        QRCodeView(data: pass.qrCodeData, size: 120)
                            .padding(.bottom, 20)
                    }
                } else {
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .frame(width: Layout.gymCardWidth)
        .passCardStyle()
    }
}

// MARK: - Pass Detail Item
struct PassDetailItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.captionMedium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: PassStatus
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            
            Text(status.rawValue)
                .font(.captionMedium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var statusColor: Color {
        switch status {
        case .active:
            return .occupancyLow
        case .expired:
            return .errorRed
        case .pending:
            return .warningOrange
        }
    }
}

// MARK: - Pass Model
struct GymPass: Identifiable {
    let id: String
    let gymName: String
    let passType: String
    let status: PassStatus
    let expiryDate: Date
    let visitsRemaining: Int?
    let qrCodeData: String
    let purchaseDate: Date
    let price: Double
    
    var formattedExpiryDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: expiryDate)
    }
    
    var timeRemaining: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: Date(), to: expiryDate)
        
        if let days = components.day, days > 0 {
            return "\(days)d left"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h left"
        } else {
            return "Expiring"
        }
    }
    
    static let sample = GymPass(
        id: "pass-1",
        gymName: "Capybara Fitness Center",
        passType: "Monthly Unlimited",
        status: .active,
        expiryDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
        visitsRemaining: nil,
        qrCodeData: "CAPYBARA-GYM-PASS-12345",
        purchaseDate: Date(),
        price: 49.99
    )
    
    static let samples = [
        sample,
        GymPass(
            id: "pass-2",
            gymName: "Iron Pump Gym",
            passType: "10 Visit Pass",
            status: .active,
            expiryDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())!,
            visitsRemaining: 7,
            qrCodeData: "CAPYBARA-GYM-PASS-67890",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            price: 99.99
        ),
        GymPass(
            id: "pass-3",
            gymName: "Zen Wellness Studio",
            passType: "Day Pass",
            status: .expired,
            expiryDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            visitsRemaining: 0,
            qrCodeData: "CAPYBARA-GYM-PASS-11111",
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            price: 20.00
        )
    ]
}

enum PassStatus: String {
    case active = "Active"
    case expired = "Expired"
    case pending = "Pending"
}

// MARK: - Preview
#Preview("Pass Card") {
    ScrollView {
        VStack(spacing: 20) {
            PassCard(pass: .sample, showQRCode: true)
            PassCard(pass: GymPass.samples[1], showQRCode: false)
            PassCard(pass: GymPass.samples[2], showQRCode: false)
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}

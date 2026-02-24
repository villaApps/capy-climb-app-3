//
//  QRCodeView.swift
//  CapybaraGym
//
//  QR code display component
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    let data: String
    var size: CGFloat = 200
    var correctionLevel: QRCodeCorrectionLevel = .high
    
    enum QRCodeCorrectionLevel: String {
        case low = "L"
        case medium = "M"
        case quarter = "Q"
        case high = "H"
    }
    
    var body: some View {
        if let qrImage = generateQRCode(from: data) {
            Image(uiImage: qrImage)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: size, height: size)
                .background(Color.white)
                .cornerRadius(12)
                .padding(12)
                .background(Color.white)
                .cornerRadius(16)
        } else {
            // Fallback view
            VStack(spacing: 8) {
                Image(systemName: "qrcode")
                    .font(.system(size: 40))
                    .foregroundColor(.tertiaryText)
                Text("QR Code")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            .frame(width: size, height: size)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        guard let data = string.data(using: .utf8) else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale up the image for better quality
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Animated QR Code View
struct AnimatedQRCodeView: View {
    let data: String
    var size: CGFloat = 200
    
    @State private var isScanning = false
    
    var body: some View {
        ZStack {
            QRCodeView(data: data, size: size)
            
            // Scanning animation overlay
            GeometryReader { geometry in
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.primaryBrown.opacity(0),
                                    Color.primaryBrown.opacity(0.3),
                                    Color.primaryBrown.opacity(0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 4)
                        .offset(y: isScanning ? geometry.size.height : 0)
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                isScanning = true
            }
        }
    }
}

// MARK: - QR Scanner Overlay
struct QRScannerOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .overlay(
                        // Cutout for scanner
                        Rectangle()
                            .frame(width: 250, height: 250)
                            .blendMode(.destinationOut)
                    )
                
                // Scanner frame
                ZStack {
                    // Corner brackets
                    VStack {
                        HStack {
                            CornerBracket(position: .topLeft)
                            Spacer()
                            CornerBracket(position: .topRight)
                        }
                        Spacer()
                        HStack {
                            CornerBracket(position: .bottomLeft)
                            Spacer()
                            CornerBracket(position: .bottomRight)
                        }
                    }
                    .frame(width: 270, height: 270)
                    
                    // Scan line
                    ScanLine()
                        .frame(width: 230, height: 2)
                }
            }
            .compositingGroup()
        }
    }
}

// MARK: - Corner Bracket
struct CornerBracket: View {
    enum Position {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    let position: Position
    
    var body: some View {
        ZStack {
            // Horizontal line
            Rectangle()
                .fill(Color.primaryBrown)
                .frame(width: 30, height: 4)
                .offset(x: horizontalOffset, y: 0)
            
            // Vertical line
            Rectangle()
                .fill(Color.primaryBrown)
                .frame(width: 4, height: 30)
                .offset(x: 0, y: verticalOffset)
        }
        .frame(width: 34, height: 34)
    }
    
    private var horizontalOffset: CGFloat {
        switch position {
        case .topLeft, .bottomLeft:
            return 8
        case .topRight, .bottomRight:
            return -8
        }
    }
    
    private var verticalOffset: CGFloat {
        switch position {
        case .topLeft, .topRight:
            return 8
        case .bottomLeft, .bottomRight:
            return -8
        }
    }
}

// MARK: - Scan Line
struct ScanLine: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.primaryBrown.opacity(0),
                        Color.primaryBrown,
                        Color.primaryBrown.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(y: isAnimating ? -125 : 125)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - QR Code Result View
struct QRCodeResultView: View {
    let result: QRScanResult
    let onDismiss: () -> Void
    let onAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(result.isValid ? Color.occupancyLow.opacity(0.2) : Color.errorRed.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: result.isValid ? "checkmark" : "xmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(result.isValid ? .occupancyLow : .errorRed)
            }
            
            // Title
            Text(result.isValid ? "Valid Pass" : "Invalid Pass")
                .font(.title2)
                .foregroundColor(.primaryText)
            
            // Details
            VStack(spacing: 12) {
                DetailRow(icon: "person", label: "User", value: result.userName)
                DetailRow(icon: "building", label: "Gym", value: result.gymName)
                DetailRow(icon: "ticket", label: "Pass Type", value: result.passType)
                DetailRow(icon: "clock", label: "Scanned At", value: result.scanTime)
            }
            .padding(.horizontal)
            
            // Buttons
            VStack(spacing: 12) {
                if result.isValid {
                    Button(action: onAction) {
                        Text("Check In")
                            .font(.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Layout.primaryButtonHeight)
                            .background(Color.primaryBrown)
                            .cornerRadius(Layout.radiusFull)
                    }
                }
                
                Button(action: onDismiss) {
                    Text("Scan Another")
                        .font(.button)
                        .foregroundColor(.primaryBrown)
                        .frame(maxWidth: .infinity)
                        .frame(height: Layout.primaryButtonHeight)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.radiusFull)
                                .stroke(Color.primaryBrown, lineWidth: 1.5)
                        )
                        .cornerRadius(Layout.radiusFull)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(Layout.radiusLarge)
        .customShadow(ShadowStyle.elevated)
        .padding(.horizontal, 32)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.bodySmall)
                .foregroundColor(.secondaryText)
                .frame(width: 24)
            
            Text(label)
                .font(.bodySmall)
                .foregroundColor(.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.bodyMedium)
                .foregroundColor(.primaryText)
        }
    }
}

// MARK: - QR Scan Result Model
struct QRScanResult {
    let isValid: Bool
    let userName: String
    let gymName: String
    let passType: String
    let scanTime: String
    
    static let sampleValid = QRScanResult(
        isValid: true,
        userName: "John Doe",
        gymName: "Capybara Fitness Center",
        passType: "Monthly Unlimited",
        scanTime: "Today, 2:30 PM"
    )
    
    static let sampleInvalid = QRScanResult(
        isValid: false,
        userName: "Unknown",
        gymName: "-",
        passType: "-",
        scanTime: "Today, 2:31 PM"
    )
}

// MARK: - Preview
#Preview("QR Code Views") {
    ScrollView {
        VStack(spacing: 32) {
            Group {
                Text("Standard QR Code")
                    .font(.headline)
                QRCodeView(data: "CAPYBARA-GYM-PASS-12345", size: 150)
            }
            
            Group {
                Text("Animated QR Code")
                    .font(.headline)
                AnimatedQRCodeView(data: "CAPYBARA-GYM-PASS-12345", size: 150)
            }
            
            Group {
                Text("Scanner Overlay")
                    .font(.headline)
                QRScannerOverlay()
                    .frame(height: 300)
            }
            
            Group {
                Text("Valid Result")
                    .font(.headline)
                QRCodeResultView(
                    result: .sampleValid,
                    onDismiss: {},
                    onAction: {}
                )
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}

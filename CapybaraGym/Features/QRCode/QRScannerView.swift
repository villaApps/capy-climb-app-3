//
//  QRScannerView.swift
//  CapybaraGym
//
//  QR Code scanner screen
//

import SwiftUI
import AVFoundation

public struct QRScannerView: View {
    
    @StateObject private var viewModel = QRScannerViewModel()
    @State private var showResult = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()
                
                // Overlay
                scannerOverlay
                
                // Bottom Controls
                VStack {
                    Spacer()
                    
                    bottomControls
                        .padding(.bottom, CapySpacing.xHuge)
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleFlash()
                    }) {
                        Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(viewModel.isFlashOn ? .yellow : .white)
                    }
                }
            }
            .onAppear {
                viewModel.startScanning()
            }
            .onDisappear {
                viewModel.stopScanning()
            }
            .sheet(isPresented: $showResult) {
                if let result = viewModel.scanResult {
                    ScanResultView(result: result)
                }
            }
            .alert("Camera Access Required", isPresented: $viewModel.showCameraAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable camera access in Settings to scan QR codes.")
            }
        }
    }
    
    // MARK: - Scanner Overlay
    private var scannerOverlay: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.7
            
            ZStack {
                // Dark overlay
                Color.black.opacity(0.5)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: size, height: size)
                                    .blendMode(.destinationOut)
                            )
                    )
                
                // Corner brackets
                ZStack {
                    // Top left
                    HStack {
                        VStack {
                            cornerBracket
                                .rotationEffect(.degrees(0))
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // Top right
                    HStack {
                        Spacer()
                        VStack {
                            cornerBracket
                                .rotationEffect(.degrees(90))
                            Spacer()
                        }
                    }
                    
                    // Bottom right
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            cornerBracket
                                .rotationEffect(.degrees(180))
                        }
                    }
                    
                    // Bottom left
                    HStack {
                        VStack {
                            Spacer()
                            cornerBracket
                                .rotationEffect(.degrees(270))
                        }
                        Spacer()
                    }
                }
                .frame(width: size + 20, height: size + 20)
                
                // Scan line
                RoundedRectangle(cornerRadius: 2)
                    .fill(CapyColors.primary)
                    .frame(width: size - 20, height: 2)
                    .offset(y: viewModel.isScanning ? size / 2 - 10 : -size / 2 + 10)
                    .animation(
                        Animation.linear(duration: 2)
                            .repeatForever(autoreverses: true),
                        value: viewModel.isScanning
                    )
            }
        }
    }
    
    private var cornerBracket: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(CapyColors.primary)
                .frame(width: 30, height: 4)
            
            Rectangle()
                .fill(CapyColors.primary)
                .frame(width: 4, height: 30)
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: CapySpacing.medium) {
            Text("Align QR code within the frame")
                .font(CapyTypography.bodyMedium)
                .foregroundColor(.white)
            
            HStack(spacing: CapySpacing.large) {
                // Gallery Button
                Button(action: {
                    viewModel.showPhotoPicker = true
                }) {
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                        Text("Gallery")
                            .font(CapyTypography.caption)
                    }
                    .foregroundColor(.white)
                }
                
                // Manual Entry Button
                Button(action: {
                    viewModel.showManualEntry = true
                }) {
                    VStack {
                        Image(systemName: "keyboard")
                            .font(.system(size: 24))
                        Text("Manual")
                            .font(CapyTypography.caption)
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(CapyRadius.xLarge)
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}

// MARK: - Scan Result View
struct ScanResultView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CapySpacing.large) {
                Spacer()
                
                // Status Icon
                ZStack {
                    Circle()
                        .fill(result.success ? CapyColors.success.opacity(0.1) : CapyColors.error.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: result.success ? "checkmark" : "xmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(result.success ? CapyColors.success : CapyColors.error)
                }
                
                // Status Text
                VStack(spacing: CapySpacing.small) {
                    Text(result.success ? "Check-in Successful!" : "Check-in Failed")
                        .font(CapyTypography.heading1)
                        .foregroundColor(result.success ? CapyColors.success : CapyColors.error)
                    
                    Text(result.message)
                        .font(CapyTypography.bodyLarge)
                        .foregroundColor(CapyColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Details
                if result.success, let gymName = result.gymName, let time = result.checkInTime {
                    VStack(spacing: CapySpacing.medium) {
                        DetailRow(icon: "building.2", text: gymName)
                        DetailRow(icon: "clock", text: time.shortTime)
                    }
                    .padding()
                    .background(CapyColors.cardBackground)
                    .cornerRadius(CapyRadius.xLarge)
                }
                
                Spacer()
                
                // Action Button
                CapyButton(
                    title: "Done",
                    action: {
                        dismiss()
                    }
                )
                .padding(.horizontal, CapySpacing.large)
            }
            .padding()
            .background(CapyColors.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: CapySpacing.small) {
            Image(systemName: icon)
                .foregroundColor(CapyColors.primary)
            
            Text(text)
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textPrimary)
        }
    }
}

// MARK: - Scan Result Model
struct ScanResult: Identifiable {
    let id = UUID()
    let success: Bool
    let message: String
    let gymName: String?
    let checkInTime: Date?
}

// MARK: - Preview
struct QRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRScannerView()
    }
}

//
//  QRScannerView.swift
//  CapybaraGym
//
//  QR code scanner for gym check-in
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @StateObject private var viewModel = QRScannerViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera Preview
                if viewModel.hasCameraPermission {
                    CameraPreviewView(session: viewModel.captureSession)
                        .ignoresSafeArea()
                } else {
                    // No Permission View
                    noPermissionView
                }
                
                // Scanner Overlay
                if viewModel.hasCameraPermission && viewModel.scannedCode == nil {
                    QRScannerOverlay()
                        .ignoresSafeArea()
                }
                
                // UI Overlay
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding()
                    
                    Spacer()
                    
                    // Bottom Content
                    if let scannedCode = viewModel.scannedCode {
                        // Scan Result
                        QRCodeResultView(
                            result: scannedCode,
                            onDismiss: { viewModel.resetScan() },
                            onAction: { viewModel.processCheckIn() }
                        )
                        .padding(.bottom, 32)
                    } else {
                        // Instructions
                        instructionsSection
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Scan QR Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showFlashlight.toggle() }) {
                        Image(systemName: viewModel.showFlashlight ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.headline)
                            .foregroundColor(viewModel.showFlashlight ? .warningOrange : .white)
                    }
                }
            }
            .onAppear {
                viewModel.checkCameraPermission()
            }
            .alert("Camera Access Required", isPresented: $viewModel.showPermissionAlert) {
                Button("Settings", role: .none) {
                    viewModel.openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to scan QR codes.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Scan to Check In")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Point camera at gym QR code")
                    .font(.bodySmall)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(Layout.radiusMedium)
    }
    
    // MARK: - No Permission View
    private var noPermissionView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "camera.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.tertiaryText)
            }
            
            VStack(spacing: 8) {
                Text("Camera Access Required")
                    .font(.title3)
                    .foregroundColor(.primaryText)
                
                Text("Please allow camera access to scan QR codes for gym check-in.")
                    .font(.bodyMedium)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { viewModel.requestCameraPermission() }) {
                Text("Allow Camera Access")
                    .font(.button)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .background(Color.appBackground)
    }
    
    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(spacing: 16) {
            // Torch Toggle (if available)
            if viewModel.hasTorch {
                Button(action: { viewModel.toggleTorch() }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.isTorchOn ? "lightbulb.fill" : "lightbulb")
                            .font(.bodyMedium)
                        Text(viewModel.isTorchOn ? "Flashlight On" : "Flashlight Off")
                            .font(.bodyMedium)
                    }
                    .foregroundColor(viewModel.isTorchOn ? .warningOrange : .white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(Layout.radiusFull)
                }
            }
            
            // My Pass Button
            NavigationLink(destination: MyPassView()) {
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                        .font(.bodyMedium)
                    Text("Show My Pass")
                        .font(.bodyMedium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.primaryBrown)
                .cornerRadius(Layout.radiusFull)
            }
        }
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

// MARK: - ViewModel
@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var hasCameraPermission = false
    @Published var showPermissionAlert = false
    @Published var scannedCode: QRScanResult?
    @Published var showFlashlight = false
    @Published var isTorchOn = false
    @Published var hasTorch = false
    
    let captureSession = AVCaptureSession()
    private var videoDevice: AVCaptureDevice?
    
    init() {
        setupCamera()
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            hasCameraPermission = true
            startSession()
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            hasCameraPermission = false
            showPermissionAlert = true
        @unknown default:
            hasCameraPermission = false
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasCameraPermission = granted
                if granted {
                    self?.startSession()
                } else {
                    self?.showPermissionAlert = true
                }
            }
        }
    }
    
    private func setupCamera() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        self.videoDevice = videoDevice
        hasTorch = videoDevice.hasTorch
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(makeCoordinator(), queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
        } catch {
            print("Camera setup error: \(error)")
        }
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    func toggleTorch() {
        guard let device = videoDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isTorchOn ? .off : .on
            isTorchOn.toggle()
            device.unlockForConfiguration()
        } catch {
            print("Torch error: \(error)")
        }
    }
    
    func resetScan() {
        scannedCode = nil
        startSession()
    }
    
    func processCheckIn() {
        // Process check-in
        stopSession()
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func makeCoordinator() -> QRMetadataDelegate {
        QRMetadataDelegate { [weak self] code in
            self?.handleScannedCode(code)
        }
    }
    
    private func handleScannedCode(_ code: String) {
        stopSession()
        
        // Validate and create result
        let isValid = code.hasPrefix("CAPYBARA-GYM")
        scannedCode = QRScanResult(
            isValid: isValid,
            userName: isValid ? "John Doe" : "Unknown",
            gymName: isValid ? "Capybara Fitness Center" : "-",
            passType: isValid ? "Monthly Unlimited" : "-",
            scanTime: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        )
    }
}

// MARK: - QR Metadata Delegate
class QRMetadataDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    let onCodeScanned: (String) -> Void
    
    init(onCodeScanned: @escaping (String) -> Void) {
        self.onCodeScanned = onCodeScanned
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            onCodeScanned(stringValue)
        }
    }
}

// MARK: - Preview
#Preview("QR Scanner View") {
    QRScannerView()
}

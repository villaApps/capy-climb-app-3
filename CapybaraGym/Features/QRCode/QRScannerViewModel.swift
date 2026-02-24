//
//  QRScannerViewModel.swift
//  CapybaraGym
//
//  QR scanner ViewModel
//

import SwiftUI
import AVFoundation
import Combine

@MainActor
public final class QRScannerViewModel: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published public var isScanning = false
    @Published public var isFlashOn = false
    @Published public var scanResult: ScanResult?
    @Published public var showCameraAlert = false
    @Published public var showPhotoPicker = false
    @Published public var showManualEntry = false
    @Published public var scannedCode: String?
    
    // MARK: - Properties
    public let session = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Initialization
    public override init() {
        super.init()
        setupCamera()
    }
    
    // MARK: - Public Methods
    
    public func startScanning() {
        checkPermissions()
    }
    
    public func stopScanning() {
        session.stopRunning()
        isScanning = false
    }
    
    public func toggleFlash() {
        guard let device = captureDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isFlashOn ? .off : .on
            isFlashOn.toggle()
            device.unlockForConfiguration()
        } catch {
            Logger.error("Failed to toggle flash: \(error)")
        }
    }
    
    public func processScannedCode(_ code: String) {
        Task {
            do {
                let qrService = QRCodeService.shared
                let result = try await qrService.processScannedCode(code)
                
                await MainActor.run {
                    self.scanResult = ScanResult(
                        success: result.success,
                        message: result.message,
                        gymName: result.gymName,
                        checkInTime: result.checkInTime
                    )
                    
                    if result.success {
                        NotificationCenter.default.post(
                            name: NotificationNames.checkInCompleted,
                            object: result
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.scanResult = ScanResult(
                        success: false,
                        message: error.localizedDescription,
                        gymName: nil,
                        checkInTime: nil
                    )
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            Logger.error("Failed to get camera device")
            return
        }
        
        self.captureDevice = captureDevice
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddInput(input) && session.canAddOutput(metadataOutput) {
                session.addInput(input)
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
        } catch {
            Logger.error("Failed to setup camera: \(error)")
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.startSession()
                    } else {
                        self?.showCameraAlert = true
                    }
                }
            }
            
        case .denied, .restricted:
            showCameraAlert = true
            
        @unknown default:
            showCameraAlert = true
        }
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    
    nonisolated public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        
        // Stop scanning
        session.stopRunning()
        
        DispatchQueue.main.async { [weak self] in
            self?.isScanning = false
            self?.scannedCode = stringValue
            self?.processScannedCode(stringValue)
        }
    }
}

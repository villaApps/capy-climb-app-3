import Foundation
import UIKit
import CoreImage.CIFilterBuiltins

/**
 * GymPass App - QR Code Service
 * 
 * Handles QR code generation and validation:
 * - Generate QR codes for passes
 * - Validate QR codes
 * - Display QR codes for check-in
 */

@MainActor
public final class QRCodeService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var currentQRCode: UIImage?
    @Published public var isGenerating: Bool = false
    @Published public var error: Error?
    
    // MARK: - Singleton
    
    public static let shared = QRCodeService()
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private init() {}
    
    // MARK: - QR Code Generation
    
    /// Generate QR code image from string data
    public func generateQRCode(
        from string: String,
        size: CGFloat = 300,
        correctionLevel: String = "M"
    ) -> UIImage? {
        isGenerating = true
        defer { isGenerating = false }
        
        guard let data = string.data(using: .utf8) else {
            self.error = QRError.invalidData
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else {
            self.error = QRError.generationFailed
            return nil
        }
        
        // Scale the image to desired size
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to UIImage
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            self.error = QREnder.renderingFailed
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Generate QR code for a user pass
    public func generatePassQRCode(
        userPass: UserPass,
        size: CGFloat = 300
    ) -> UIImage? {
        // QR code data format: "GYM:PASS:{userPassId}:{timestamp}:{signature}"
        let timestamp = Int(Date().timeIntervalSince1970)
        let qrData = "GYM:PASS:\(userPass.id):\(timestamp)"
        
        return generateQRCode(from: qrData, size: size)
    }
    
    /// Generate styled QR code with logo
    public func generateStyledQRCode(
        from string: String,
        size: CGFloat = 300,
        logo: UIImage? = nil,
        logoSize: CGFloat = 60,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = .white
    ) -> UIImage? {
        guard let qrImage = generateQRCode(from: string, size: size) else {
            return nil
        }
        
        // If no logo, return plain QR code
        guard let logo = logo else {
            return qrImage
        }
        
        // Create canvas
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { context in
            // Draw background
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: CGSize(width: size, height: size)))
            
            // Draw QR code
            qrImage.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
            
            // Draw logo in center
            let logoRect = CGRect(
                x: (size - logoSize) / 2,
                y: (size - logoSize) / 2,
                width: logoSize,
                height: logoSize
            )
            
            // White background for logo area
            UIColor.white.setFill()
            UIBezierPath(roundedRect: logoRect.insetBy(dx: -8, dy: -8), cornerRadius: 8).fill()
            
            // Draw logo
            logo.draw(in: logoRect)
        }
    }
    
    // MARK: - QR Code Validation
    
    /// Parse QR code data
    public func parseQRCodeData(_ data: String) -> QRCodeData? {
        let components = data.split(separator: ":")
        
        guard components.count >= 3,
              components[0] == "GYM",
              components[1] == "PASS" else {
            return nil
        }
        
        let userPassId = String(components[2])
        let timestamp = components.count > 3 ? Int(components[3]) : nil
        
        return QRCodeData(
            type: .pass,
            userPassId: userPassId,
            timestamp: timestamp,
            rawData: data
        )
    }
    
    /// Validate QR code data
    public func validateQRCodeData(_ data: String) -> QRValidationResult {
        guard let parsed = parseQRCodeData(data) else {
            return .invalid(.invalidFormat)
        }
        
        // Check timestamp (QR codes expire after 5 minutes)
        if let timestamp = parsed.timestamp {
            let codeDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let expirationDate = codeDate.addingTimeInterval(5 * 60) // 5 minutes
            
            if Date() > expirationDate {
                return .invalid(.expired)
            }
        }
        
        return .valid(parsed)
    }
    
    // MARK: - Check-in Operations
    
    /// Display QR code for check-in
    public func displayCheckInQRCode(for userPass: UserPass) async -> UIImage? {
        // Generate fresh QR code
        let qrImage = generatePassQRCode(userPass: userPass, size: 300)
        
        await MainActor.run {
            self.currentQRCode = qrImage
        }
        
        return qrImage
    }
    
    /// Refresh QR code (for periodic updates)
    public func refreshQRCode(for userPass: UserPass) async -> UIImage? {
        return await displayCheckInQRCode(for: userPass)
    }
    
    /// Clear current QR code
    public func clearQRCode() {
        currentQRCode = nil
    }
}

// MARK: - QR Code Data Types

public struct QRCodeData {
    public let type: QRCodeType
    public let userPassId: String
    public let timestamp: Int?
    public let rawData: String
}

public enum QRCodeType {
    case pass
    case checkIn
    checkOut
    case guest
}

public enum QRValidationResult {
    case valid(QRCodeData)
    case invalid(QRValidationError)
}

public enum QRValidationError {
    case invalidFormat
    case expired
    case alreadyUsed
    case revoked
    case invalidSignature
}

public enum QRError: LocalizedError {
    case invalidData
    case generationFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data for QR code generation"
        case .generationFailed:
            return "Failed to generate QR code"
        }
    }
}

// MARK: - QR Code Scanner (for staff)

#if canImport(AVFoundation)
import AVFoundation

public protocol QRCodeScannerDelegate: AnyObject {
    func qrCodeScanner(_ scanner: QRCodeScanner, didScan code: String)
    func qrCodeScanner(_ scanner: QRCodeScanner, didFailWithError error: Error)
}

public class QRCodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    public weak var delegate: QRCodeScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    public var isRunning: Bool {
        captureSession?.isRunning ?? false
    }
    
    public override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        let session = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.qrCodeScanner(self, didFailWithError: ScannerError.noCamera)
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            }
            
            captureSession = session
            
        } catch {
            delegate?.qrCodeScanner(self, didFailWithError: error)
        }
    }
    
    public func startScanning(in view: UIView) {
        guard let session = captureSession else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        
        if let layer = previewLayer {
            view.layer.addSublayer(layer)
        }
        
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    public func stopScanning() {
        captureSession?.stopRunning()
        previewLayer?.removeFromSuperlayer()
    }
    
    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }
        
        delegate?.qrCodeScanner(self, didScan: stringValue)
    }
}

public enum ScannerError: LocalizedError {
    case noCamera
    case setupFailed
    
    public var errorDescription: String? {
        switch self {
        case .noCamera:
            return "No camera available"
        case .setupFailed:
            return "Failed to setup camera"
        }
    }
}

#endif

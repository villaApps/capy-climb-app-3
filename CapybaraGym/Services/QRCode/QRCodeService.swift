//
//  QRCodeService.swift
//  CapybaraGym
//
//  QR Code generation and scanning service
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - QR Code Errors
public enum QRCodeError: LocalizedError {
    case generationFailed
    case invalidData
    case invalidQRCode
    case cameraAccessDenied
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .generationFailed:
            return "Failed to generate QR code"
        case .invalidData:
            return "Invalid data for QR code"
        case .invalidQRCode:
            return "Invalid QR code scanned"
        case .cameraAccessDenied:
            return "Camera access denied. Please enable in Settings."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - QR Code Data Model
public struct QRCodeData: Codable {
    public let type: QRCodeType
    public let payload: String
    public let timestamp: Date
    public let expiresAt: Date?
    
    public enum QRCodeType: String, Codable {
        case checkIn = "check_in"
        case pass = "pass"
        case promotion = "promotion"
        case referral = "referral"
        case unknown = "unknown"
    }
    
    public var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }
    
    public var isValid: Bool {
        !isExpired
    }
}

// MARK: - Check In Result
public struct CheckInResult: Codable {
    public let success: Bool
    public let message: String
    public let gymId: String?
    public let gymName: String?
    public let checkInTime: Date?
    public let errorCode: String?
}

// MARK: - QR Code Service Protocol
public protocol QRCodeServiceProtocol {
    func generateQRCode(from data: QRCodeData, size: CGSize) async throws -> UIImage
    func generatePassQRCode(passId: String, userId: String) async throws -> UIImage
    func generateCheckInQRCode(gymId: String, userId: String) async throws -> UIImage
    func parseQRCode(_ string: String) -> QRCodeData?
    func validateQRCode(_ data: QRCodeData) async throws -> CheckInResult
}

// MARK: - QR Code Service Implementation
public final class QRCodeService: QRCodeServiceProtocol, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = QRCodeService()
    
    // MARK: - Published Properties
    @Published public private(set) var lastScannedCode: QRCodeData?
    @Published public private(set) var isGenerating = false
    
    // MARK: - Private Properties
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    public func generateQRCode(from data: QRCodeData, size: CGSize = CGSize(width: 300, height: 300)) async throws -> UIImage {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let jsonData = try encoder.encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            
            return try await generateQRCodeImage(from: jsonString, size: size)
            
        } catch {
            throw QRCodeError.generationFailed
        }
    }
    
    public func generatePassQRCode(passId: String, userId: String) async throws -> UIImage {
        let data = QRCodeData(
            type: .pass,
            payload: "pass:\(passId):\(userId)",
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(300) // 5 minutes
        )
        
        return try await generateQRCode(from: data)
    }
    
    public func generateCheckInQRCode(gymId: String, userId: String) async throws -> UIImage {
        let data = QRCodeData(
            type: .checkIn,
            payload: "checkin:\(gymId):\(userId):\(Date().timeIntervalSince1970)",
            timestamp: Date(),
            expiresAt: Date().addingTimeInterval(60) // 1 minute
        )
        
        return try await generateQRCode(from: data)
    }
    
    public func parseQRCode(_ string: String) -> QRCodeData? {
        // Try to parse as JSON first
        if let data = string.data(using: .utf8) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            if let qrData = try? decoder.decode(QRCodeData.self, from: data) {
                return qrData
            }
        }
        
        // Try to parse legacy format
        let components = string.split(separator: ":")
        guard components.count >= 2 else { return nil }
        
        let typeString = String(components[0])
        let type = QRCodeData.QRCodeType(rawValue: typeString) ?? .unknown
        
        return QRCodeData(
            type: type,
            payload: string,
            timestamp: Date(),
            expiresAt: nil
        )
    }
    
    public func validateQRCode(_ data: QRCodeData) async throws -> CheckInResult {
        // Simulate API call for validation
        // In production, this would call your backend API
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        guard !data.isExpired else {
            return CheckInResult(
                success: false,
                message: "QR code has expired",
                gymId: nil,
                gymName: nil,
                checkInTime: nil,
                errorCode: "EXPIRED"
            )
        }
        
        // Mock successful check-in
        return CheckInResult(
            success: true,
            message: "Check-in successful!",
            gymId: "gym_123",
            gymName: "Capybara Fitness Center",
            checkInTime: Date(),
            errorCode: nil
        )
    }
    
    public func processScannedCode(_ code: String) async throws -> CheckInResult {
        guard let data = parseQRCode(code) else {
            throw QRCodeError.invalidQRCode
        }
        
        lastScannedCode = data
        
        // Post notification
        NotificationCenter.default.post(
            name: NotificationNames.qrCodeScanned,
            object: data
        )
        
        return try await validateQRCode(data)
    }
    
    // MARK: - Private Methods
    
    private func generateQRCodeImage(from string: String, size: CGSize) async throws -> UIImage {
        filter.message = Data(string.utf8)
        filter.correctionLevel = "H" // High error correction
        
        guard let outputImage = filter.outputImage else {
            throw QRCodeError.generationFailed
        }
        
        // Scale the image to the desired size
        let scaleX = size.width / outputImage.extent.size.width
        let scaleY = size.height / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            throw QRCodeError.generationFailed
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        
        // Add logo in center if needed
        return uiImage
    }
    
    public func generateQRCodeWithLogo(
        from string: String,
        size: CGSize = CGSize(width: 300, height: 300),
        logo: UIImage? = nil
    ) async throws -> UIImage {
        let qrImage = try await generateQRCodeImage(from: string, size: size)
        
        guard let logo = logo else { return qrImage }
        
        // Create a new image with the logo in the center
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        qrImage.draw(in: CGRect(origin: .zero, size: size))
        
        // Draw logo in center
        let logoSize = CGSize(width: size.width * 0.25, height: size.height * 0.25)
        let logoOrigin = CGPoint(
            x: (size.width - logoSize.width) / 2,
            y: (size.height - logoSize.height) / 2
        )
        
        // Draw white background for logo
        let logoBackgroundRect = CGRect(origin: logoOrigin, size: logoSize)
        UIColor.white.setFill()
        UIBezierPath(roundedRect: logoBackgroundRect, cornerRadius: 8).fill()
        
        logo.draw(in: logoBackgroundRect.insetBy(dx: 4, dy: 4))
        
        guard let finalImage = UIGraphicsGetImageFromCurrentImageContext() else {
            throw QRCodeError.generationFailed
        }
        
        return finalImage
    }
}

// MARK: - UIImage Extensions for QR Code
public extension UIImage {
    
    /// Detect QR codes in image
    func detectQRCodes() -> [String] {
        guard let cgImage = self.cgImage else { return [] }
        
        let request = VNDetectBarcodesRequest()
        request.symbologies = [.qr]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            return request.results?.compactMap { $0.payloadStringValue } ?? []
        } catch {
            Logger.error("QR code detection failed: \(error)")
            return []
        }
    }
}

import Vision

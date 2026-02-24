// MARK: - Mock Pass Service
// Comprehensive mock for PassService to enable isolated unit testing

import Foundation
import Combine
@testable import CapybaraGym

// MARK: - Pass Service Protocol
public protocol PassServiceProtocol {
    var passesPublisher: AnyPublisher<[GymPass], Never> { get }
    var activePassPublisher: AnyPublisher<GymPass?, Never> { get }
    
    func fetchUserPasses(userId: String) async throws -> [GymPass]
    func fetchActivePass(userId: String) async throws -> GymPass?
    func createPass(userId: String, type: PassType, duration: PassDuration) async throws -> GymPass
    func renewPass(passId: String) async throws -> GymPass
    func cancelPass(passId: String) async throws
    func generateQRCode(passId: String) async throws -> QRCodeData
    func validateQRCode(code: String) async throws -> QRValidationResult
    func checkIn(passId: String, gymId: String) async throws -> CheckInResult
    func fetchCheckInHistory(passId: String) async throws -> [CheckInRecord]
    func fetchPassTypes() async throws -> [PassTypeInfo]
    func calculatePassPrice(type: PassType, duration: PassDuration) -> Decimal
}

// MARK: - Pass Error
public enum PassError: Error, Equatable {
    case passNotFound
    case noActivePass
    case passExpired
    case passCancelled
    case invalidPassType
    case checkInFailed
    case qrCodeGenerationFailed
    case qrCodeInvalid
    case qrCodeExpired
    case networkError
    case paymentRequired
    case unknown(String)
    
    public static func == (lhs: PassError, rhs: PassError) -> Bool {
        switch (lhs, rhs) {
        case (.passNotFound, .passNotFound),
             (.noActivePass, .noActivePass),
             (.passExpired, .passExpired),
             (.passCancelled, .passCancelled),
             (.invalidPassType, .invalidPassType),
             (.checkInFailed, .checkInFailed),
             (.qrCodeGenerationFailed, .qrCodeGenerationFailed),
             (.qrCodeInvalid, .qrCodeInvalid),
             (.qrCodeExpired, .qrCodeExpired),
             (.networkError, .networkError),
             (.paymentRequired, .paymentRequired):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Mock Pass Service
public final class MockPassService: PassServiceProtocol {
    
    // MARK: - Properties
    @Published private var passes: [GymPass] = []
    public var passesPublisher: AnyPublisher<[GymPass], Never> {
        $passes.eraseToAnyPublisher()
    }
    
    @Published private var activePass: GymPass?
    public var activePassPublisher: AnyPublisher<GymPass?, Never> {
        $activePass.eraseToAnyPublisher()
    }
    
    // MARK: - Configuration
    public var shouldSucceed = true
    public var shouldReturnPassNotFound = false
    public var shouldReturnNoActivePass = false
    public var shouldReturnPassExpired = false
    public var shouldReturnPassCancelled = false
    public var shouldReturnQRCodeExpired = false
    public var shouldReturnCheckInFailed = false
    public var shouldReturnNetworkError = false
    public var shouldReturnPaymentRequired = false
    public var delay: TimeInterval = 0.1
    
    // MARK: - Call Tracking
    public var fetchUserPassesCallCount = 0
    public var fetchActivePassCallCount = 0
    public var createPassCallCount = 0
    public var renewPassCallCount = 0
    public var cancelPassCallCount = 0
    public var generateQRCodeCallCount = 0
    public var validateQRCodeCallCount = 0
    public var checkInCallCount = 0
    public var fetchCheckInHistoryCallCount = 0
    public var fetchPassTypesCallCount = 0
    public var calculatePassPriceCallCount = 0
    
    // MARK: - Captured Parameters
    public var capturedUserId: String?
    public var capturedPassId: String?
    public var capturedGymId: String?
    public var capturedPassType: PassType?
    public var capturedPassDuration: PassDuration?
    public var capturedQRCode: String?
    
    // MARK: - Test Data
    public var mockPasses: [GymPass] = [
        GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
            endDate: Date().addingTimeInterval(86400 * 30), // 30 days from now
            checkInsRemaining: nil,
            totalCheckIns: 45,
            gyms: ["gym-1", "gym-2", "gym-3"],
            autoRenew: true,
            price: 49.99
        ),
        GymPass(
            id: "pass-2",
            userId: "user-1",
            type: .premium,
            status: .expired,
            startDate: Date().addingTimeInterval(-86400 * 90),
            endDate: Date().addingTimeInterval(-86400 * 5),
            checkInsRemaining: nil,
            totalCheckIns: 78,
            gyms: ["gym-1", "gym-2", "gym-3"],
            autoRenew: false,
            price: 79.99
        )
    ]
    
    public var mockQRCodeData = QRCodeData(
        code: "QR123456789",
        passId: "pass-1",
        expiresAt: Date().addingTimeInterval(300), // 5 minutes
        imageData: Data()
    )
    
    public var mockCheckInHistory: [CheckInRecord] = [
        CheckInRecord(
            id: "checkin-1",
            passId: "pass-1",
            gymId: "gym-1",
            gymName: "Downtown Capybara Fitness",
            timestamp: Date().addingTimeInterval(-86400),
            isValid: true
        ),
        CheckInRecord(
            id: "checkin-2",
            passId: "pass-1",
            gymId: "gym-2",
            gymName: "Uptown Capybara Center",
            timestamp: Date().addingTimeInterval(-86400 * 3),
            isValid: true
        ),
        CheckInRecord(
            id: "checkin-3",
            passId: "pass-1",
            gymId: "gym-1",
            gymName: "Downtown Capybara Fitness",
            timestamp: Date().addingTimeInterval(-86400 * 7),
            isValid: true
        )
    ]
    
    public var mockPassTypes: [PassTypeInfo] = [
        PassTypeInfo(
            type: .standard,
            name: "Standard Pass",
            description: "Access to all basic facilities",
            features: ["Gym access", "Locker room", "Showers"],
            basePrice: 49.99
        ),
        PassTypeInfo(
            type: .premium,
            name: "Premium Pass",
            description: "Full access with premium amenities",
            features: ["All Standard features", "Pool access", "Sauna", "Group classes"],
            basePrice: 79.99
        ),
        PassTypeInfo(
            type: .dayPass,
            name: "Day Pass",
            description: "Single day access",
            features: ["24-hour access", "All facilities"],
            basePrice: 15.99
        )
    ]
    
    // MARK: - Initialization
    public init() {
        passes = mockPasses
        activePass = mockPasses.first { $0.status == .active }
    }
    
    // MARK: - PassServiceProtocol Implementation
    
    public func fetchUserPasses(userId: String) async throws -> [GymPass] {
        fetchUserPassesCallCount += 1
        capturedUserId = userId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !userId.isEmpty else {
            throw PassError.unknown("Invalid user ID")
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return passes
        }
        
        throw PassError.unknown("Failed to fetch passes")
    }
    
    public func fetchActivePass(userId: String) async throws -> GymPass? {
        fetchActivePassCallCount += 1
        capturedUserId = userId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        if shouldReturnNoActivePass {
            return nil
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return activePass
        }
        
        throw PassError.unknown("Failed to fetch active pass")
    }
    
    public func createPass(userId: String, type: PassType, duration: PassDuration) async throws -> GymPass {
        createPassCallCount += 1
        capturedUserId = userId
        capturedPassType = type
        capturedPassDuration = duration
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !userId.isEmpty else {
            throw PassError.unknown("Invalid user ID")
        }
        
        if shouldReturnInvalidPassType {
            throw PassError.invalidPassType
        }
        
        if shouldReturnPaymentRequired {
            throw PassError.paymentRequired
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            let newPass = GymPass(
                id: "pass-\(UUID().uuidString)",
                userId: userId,
                type: type,
                status: .active,
                startDate: Date(),
                endDate: Date().addingTimeInterval(duration.timeInterval),
                checkInsRemaining: type == .dayPass ? 1 : nil,
                totalCheckIns: 0,
                gyms: ["gym-1", "gym-2", "gym-3"],
                autoRenew: type != .dayPass,
                price: calculatePassPrice(type: type, duration: duration)
            )
            passes.append(newPass)
            activePass = newPass
            return newPass
        }
        
        throw PassError.unknown("Failed to create pass")
    }
    
    public func renewPass(passId: String) async throws -> GymPass {
        renewPassCallCount += 1
        capturedPassId = passId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassNotFound {
            throw PassError.passNotFound
        }
        
        if shouldReturnPaymentRequired {
            throw PassError.paymentRequired
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            if let index = passes.firstIndex(where: { $0.id == passId }) {
                var renewedPass = passes[index]
                // Extend by 30 days
                let newEndDate = max(renewedPass.endDate, Date()).addingTimeInterval(86400 * 30)
                renewedPass = GymPass(
                    id: renewedPass.id,
                    userId: renewedPass.userId,
                    type: renewedPass.type,
                    status: .active,
                    startDate: renewedPass.startDate,
                    endDate: newEndDate,
                    checkInsRemaining: renewedPass.checkInsRemaining,
                    totalCheckIns: renewedPass.totalCheckIns,
                    gyms: renewedPass.gyms,
                    autoRenew: renewedPass.autoRenew,
                    price: renewedPass.price
                )
                passes[index] = renewedPass
                activePass = renewedPass
                return renewedPass
            }
            throw PassError.passNotFound
        }
        
        throw PassError.unknown("Failed to renew pass")
    }
    
    public func cancelPass(passId: String) async throws {
        cancelPassCallCount += 1
        capturedPassId = passId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassNotFound {
            throw PassError.passNotFound
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            if let index = passes.firstIndex(where: { $0.id == passId }) {
                var cancelledPass = passes[index]
                cancelledPass = GymPass(
                    id: cancelledPass.id,
                    userId: cancelledPass.userId,
                    type: cancelledPass.type,
                    status: .cancelled,
                    startDate: cancelledPass.startDate,
                    endDate: cancelledPass.endDate,
                    checkInsRemaining: cancelledPass.checkInsRemaining,
                    totalCheckIns: cancelledPass.totalCheckIns,
                    gyms: cancelledPass.gyms,
                    autoRenew: false,
                    price: cancelledPass.price
                )
                passes[index] = cancelledPass
                if activePass?.id == passId {
                    activePass = nil
                }
            }
        }
    }
    
    public func generateQRCode(passId: String) async throws -> QRCodeData {
        generateQRCodeCallCount += 1
        capturedPassId = passId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassNotFound {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassExpired {
            throw PassError.passExpired
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return QRCodeData(
                code: "QR\(Int.random(in: 100000000...999999999))",
                passId: passId,
                expiresAt: Date().addingTimeInterval(300),
                imageData: Data("mock-qr-image-data".utf8)
            )
        }
        
        throw PassError.qrCodeGenerationFailed
    }
    
    public func validateQRCode(code: String) async throws -> QRValidationResult {
        validateQRCodeCallCount += 1
        capturedQRCode = code
        
        try await Task.sleep(nanoseconds: UInt64(delay * 300_000_000))
        
        guard !code.isEmpty else {
            throw PassError.qrCodeInvalid
        }
        
        if shouldReturnQRCodeExpired {
            return QRValidationResult(
                isValid: false,
                passId: nil,
                message: "QR code has expired",
                timestamp: Date()
            )
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return QRValidationResult(
                isValid: true,
                passId: "pass-1",
                message: "Valid QR code",
                timestamp: Date()
            )
        }
        
        return QRValidationResult(
            isValid: false,
            passId: nil,
            message: "Invalid QR code",
            timestamp: Date()
        )
    }
    
    public func checkIn(passId: String, gymId: String) async throws -> CheckInResult {
        checkInCallCount += 1
        capturedPassId = passId
        capturedGymId = gymId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        guard !passId.isEmpty, !gymId.isEmpty else {
            throw PassError.checkInFailed
        }
        
        if shouldReturnPassNotFound {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassExpired {
            throw PassError.passExpired
        }
        
        if shouldReturnCheckInFailed {
            return CheckInResult(
                success: false,
                message: "Check-in failed",
                timestamp: Date(),
                gymName: nil
            )
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return CheckInResult(
                success: true,
                message: "Check-in successful",
                timestamp: Date(),
                gymName: "Downtown Capybara Fitness"
            )
        }
        
        throw PassError.checkInFailed
    }
    
    public func fetchCheckInHistory(passId: String) async throws -> [CheckInRecord] {
        fetchCheckInHistoryCallCount += 1
        capturedPassId = passId
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        if shouldReturnPassNotFound {
            throw PassError.passNotFound
        }
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return mockCheckInHistory
        }
        
        throw PassError.unknown("Failed to fetch check-in history")
    }
    
    public func fetchPassTypes() async throws -> [PassTypeInfo] {
        fetchPassTypesCallCount += 1
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        if shouldReturnNetworkError {
            throw PassError.networkError
        }
        
        if shouldSucceed {
            return mockPassTypes
        }
        
        throw PassError.unknown("Failed to fetch pass types")
    }
    
    public func calculatePassPrice(type: PassType, duration: PassDuration) -> Decimal {
        calculatePassPriceCallCount += 1
        capturedPassType = type
        capturedPassDuration = duration
        
        let basePrice: Decimal
        switch type {
        case .standard:
            basePrice = 49.99
        case .premium:
            basePrice = 79.99
        case .dayPass:
            basePrice = 15.99
        }
        
        let multiplier: Decimal
        switch duration {
        case .oneMonth:
            multiplier = 1.0
        case .threeMonths:
            multiplier = 2.7 // 10% discount
        case .sixMonths:
            multiplier = 5.1 // 15% discount
        case .oneYear:
            multiplier = 9.6 // 20% discount
        }
        
        return basePrice * multiplier
    }
    
    // MARK: - Helper Methods
    
    public func reset() {
        fetchUserPassesCallCount = 0
        fetchActivePassCallCount = 0
        createPassCallCount = 0
        renewPassCallCount = 0
        cancelPassCallCount = 0
        generateQRCodeCallCount = 0
        validateQRCodeCallCount = 0
        checkInCallCount = 0
        fetchCheckInHistoryCallCount = 0
        fetchPassTypesCallCount = 0
        calculatePassPriceCallCount = 0
        
        capturedUserId = nil
        capturedPassId = nil
        capturedGymId = nil
        capturedPassType = nil
        capturedPassDuration = nil
        capturedQRCode = nil
        
        shouldSucceed = true
        shouldReturnPassNotFound = false
        shouldReturnNoActivePass = false
        shouldReturnPassExpired = false
        shouldReturnPassCancelled = false
        shouldReturnQRCodeExpired = false
        shouldReturnCheckInFailed = false
        shouldReturnNetworkError = false
        shouldReturnPaymentRequired = false
        
        passes = mockPasses
        activePass = mockPasses.first { $0.status == .active }
    }
    
    public func addMockPass(_ pass: GymPass) {
        passes.append(pass)
    }
    
    public func expirePass(passId: String) {
        if let index = passes.firstIndex(where: { $0.id == passId }) {
            var expiredPass = passes[index]
            expiredPass = GymPass(
                id: expiredPass.id,
                userId: expiredPass.userId,
                type: expiredPass.type,
                status: .expired,
                startDate: expiredPass.startDate,
                endDate: Date().addingTimeInterval(-86400),
                checkInsRemaining: expiredPass.checkInsRemaining,
                totalCheckIns: expiredPass.totalCheckIns,
                gyms: expiredPass.gyms,
                autoRenew: false,
                price: expiredPass.price
            )
            passes[index] = expiredPass
            if activePass?.id == passId {
                activePass = nil
            }
        }
    }
}

// MARK: - Supporting Models

public struct GymPass: Equatable, Identifiable {
    public let id: String
    public let userId: String
    public let type: PassType
    public let status: PassStatus
    public let startDate: Date
    public let endDate: Date
    public let checkInsRemaining: Int?
    public let totalCheckIns: Int
    public let gyms: [String]
    public let autoRenew: Bool
    public let price: Decimal
    
    public var isActive: Bool {
        status == .active && endDate > Date()
    }
    
    public var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }
    
    public init(id: String, userId: String, type: PassType, status: PassStatus,
                startDate: Date, endDate: Date, checkInsRemaining: Int?, totalCheckIns: Int,
                gyms: [String], autoRenew: Bool, price: Decimal) {
        self.id = id
        self.userId = userId
        self.type = type
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.checkInsRemaining = checkInsRemaining
        self.totalCheckIns = totalCheckIns
        self.gyms = gyms
        self.autoRenew = autoRenew
        self.price = price
    }
}

public enum PassType: String, CaseIterable {
    case standard = "standard"
    case premium = "premium"
    case dayPass = "dayPass"
}

public enum PassStatus: String, Equatable {
    case active = "active"
    case expired = "expired"
    case cancelled = "cancelled"
    case pending = "pending"
}

public enum PassDuration: String, CaseIterable {
    case oneMonth = "1m"
    case threeMonths = "3m"
    case sixMonths = "6m"
    case oneYear = "1y"
    
    var timeInterval: TimeInterval {
        switch self {
        case .oneMonth:
            return 86400 * 30
        case .threeMonths:
            return 86400 * 90
        case .sixMonths:
            return 86400 * 180
        case .oneYear:
            return 86400 * 365
        }
    }
}

public struct QRCodeData: Equatable {
    public let code: String
    public let passId: String
    public let expiresAt: Date
    public let imageData: Data
    
    public var isExpired: Bool {
        Date() > expiresAt
    }
    
    public init(code: String, passId: String, expiresAt: Date, imageData: Data) {
        self.code = code
        self.passId = passId
        self.expiresAt = expiresAt
        self.imageData = imageData
    }
}

public struct QRValidationResult: Equatable {
    public let isValid: Bool
    public let passId: String?
    public let message: String
    public let timestamp: Date
    
    public init(isValid: Bool, passId: String?, message: String, timestamp: Date) {
        self.isValid = isValid
        self.passId = passId
        self.message = message
        self.timestamp = timestamp
    }
}

public struct CheckInResult: Equatable {
    public let success: Bool
    public let message: String
    public let timestamp: Date
    public let gymName: String?
    
    public init(success: Bool, message: String, timestamp: Date, gymName: String?) {
        self.success = success
        self.message = message
        self.timestamp = timestamp
        self.gymName = gymName
    }
}

public struct CheckInRecord: Equatable, Identifiable {
    public let id: String
    public let passId: String
    public let gymId: String
    public let gymName: String
    public let timestamp: Date
    public let isValid: Bool
    
    public init(id: String, passId: String, gymId: String, gymName: String, timestamp: Date, isValid: Bool) {
        self.id = id
        self.passId = passId
        self.gymId = gymId
        self.gymName = gymName
        self.timestamp = timestamp
        self.isValid = isValid
    }
}

public struct PassTypeInfo: Equatable, Identifiable {
    public let id = UUID()
    public let type: PassType
    public let name: String
    public let description: String
    public let features: [String]
    public let basePrice: Decimal
    
    public init(type: PassType, name: String, description: String, features: [String], basePrice: Decimal) {
        self.type = type
        self.name = name
        self.description = description
        self.features = features
        self.basePrice = basePrice
    }
}

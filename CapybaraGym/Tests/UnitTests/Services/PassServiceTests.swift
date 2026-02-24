// MARK: - Pass Service Tests
// Comprehensive unit tests for PassService following TDD principles

import XCTest
import Combine
@testable import CapybaraGym

// MARK: - PassService
/// Production implementation of pass service
@MainActor
final class PassService: PassServiceProtocol {
    
    // MARK: - Properties
    @Published private var passes: [GymPass] = []
    var passesPublisher: AnyPublisher<[GymPass], Never> {
        $passes.eraseToAnyPublisher()
    }
    
    @Published private var activePass: GymPass?
    var activePassPublisher: AnyPublisher<GymPass?, Never> {
        $activePass.eraseToAnyPublisher()
    }
    
    // MARK: - Dependencies
    private let networkClient: NetworkClientProtocol
    private let paymentProcessor: PaymentProcessorProtocol
    
    // MARK: - Initialization
    init(networkClient: NetworkClientProtocol, paymentProcessor: PaymentProcessorProtocol) {
        self.networkClient = networkClient
        self.paymentProcessor = paymentProcessor
    }
    
    // MARK: - PassServiceProtocol Implementation
    
    func fetchUserPasses(userId: String) async throws -> [GymPass] {
        guard !userId.isEmpty else {
            throw PassError.unknown("Invalid user ID")
        }
        
        do {
            let fetchedPasses: [GymPass] = try await networkClient.get(
                endpoint: "/users/\(userId)/passes",
                headers: nil
            )
            
            passes = fetchedPasses
            return fetchedPasses
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchActivePass(userId: String) async throws -> GymPass? {
        guard !userId.isEmpty else {
            throw PassError.unknown("Invalid user ID")
        }
        
        do {
            let pass: GymPass? = try await networkClient.get(
                endpoint: "/users/\(userId)/passes/active",
                headers: nil
            )
            
            activePass = pass
            return pass
        } catch let error as NetworkError {
            if case .notFound = error {
                return nil
            }
            throw mapNetworkError(error)
        }
    }
    
    func createPass(userId: String, type: PassType, duration: PassDuration) async throws -> GymPass {
        guard !userId.isEmpty else {
            throw PassError.unknown("Invalid user ID")
        }
        
        let price = calculatePassPrice(type: type, duration: duration)
        
        // Process payment first
        let paymentResult = await paymentProcessor.processPayment(amount: price)
        guard paymentResult.success else {
            throw PassError.paymentRequired
        }
        
        let request = CreatePassRequest(
            userId: userId,
            type: type,
            duration: duration,
            paymentId: paymentResult.paymentId
        )
        
        do {
            let pass: GymPass = try await networkClient.post(
                endpoint: "/passes",
                body: request
            )
            
            passes.append(pass)
            if pass.isActive {
                activePass = pass
            }
            
            return pass
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func renewPass(passId: String) async throws -> GymPass {
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        // Get current pass to determine price
        guard let currentPass = passes.first(where: { $0.id == passId }) else {
            throw PassError.passNotFound
        }
        
        let price = calculatePassPrice(type: currentPass.type, duration: .oneMonth)
        
        // Process payment
        let paymentResult = await paymentProcessor.processPayment(amount: price)
        guard paymentResult.success else {
            throw PassError.paymentRequired
        }
        
        let request = RenewPassRequest(paymentId: paymentResult.paymentId)
        
        do {
            let renewedPass: GymPass = try await networkClient.post(
                endpoint: "/passes/\(passId)/renew",
                body: request
            )
            
            // Update local cache
            if let index = passes.firstIndex(where: { $0.id == passId }) {
                passes[index] = renewedPass
            }
            activePass = renewedPass
            
            return renewedPass
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func cancelPass(passId: String) async throws {
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        do {
            try await networkClient.post(
                endpoint: "/passes/\(passId)/cancel",
                body: EmptyRequest()
            )
            
            // Update local cache
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
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func generateQRCode(passId: String) async throws -> QRCodeData {
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        // Verify pass is active
        guard let pass = passes.first(where: { $0.id == passId }), pass.isActive else {
            throw PassError.passExpired
        }
        
        do {
            let qrData: QRCodeData = try await networkClient.get(
                endpoint: "/passes/\(passId)/qr-code",
                headers: nil
            )
            
            return qrData
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func validateQRCode(code: String) async throws -> QRValidationResult {
        guard !code.isEmpty else {
            throw PassError.qrCodeInvalid
        }
        
        let request = ValidateQRCodeRequest(code: code)
        
        do {
            let result: QRValidationResult = try await networkClient.post(
                endpoint: "/passes/validate-qr",
                body: request
            )
            
            return result
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func checkIn(passId: String, gymId: String) async throws -> CheckInResult {
        guard !passId.isEmpty, !gymId.isEmpty else {
            throw PassError.checkInFailed
        }
        
        let request = CheckInRequest(passId: passId, gymId: gymId)
        
        do {
            let result: CheckInResult = try await networkClient.post(
                endpoint: "/passes/check-in",
                body: request
            )
            
            return result
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchCheckInHistory(passId: String) async throws -> [CheckInRecord] {
        guard !passId.isEmpty else {
            throw PassError.passNotFound
        }
        
        do {
            let history: [CheckInRecord] = try await networkClient.get(
                endpoint: "/passes/\(passId)/check-ins",
                headers: nil
            )
            
            return history
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func fetchPassTypes() async throws -> [PassTypeInfo] {
        do {
            let types: [PassTypeInfo] = try await networkClient.get(
                endpoint: "/pass-types",
                headers: nil
            )
            
            return types
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func calculatePassPrice(type: PassType, duration: PassDuration) -> Decimal {
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
        
        return (basePrice * multiplier).rounded(2)
    }
    
    // MARK: - Private Methods
    
    private func mapNetworkError(_ error: NetworkError) -> PassError {
        switch error {
        case .notFound:
            return .passNotFound
        case .unauthorized:
            return .passExpired
        case .conflict:
            return .passCancelled
        case .paymentRequired:
            return .paymentRequired
        case .serverError, .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Supporting Types

struct CreatePassRequest: Codable {
    let userId: String
    let type: PassType
    let duration: PassDuration
    let paymentId: String
}

struct RenewPassRequest: Codable {
    let paymentId: String
}

struct ValidateQRCodeRequest: Codable {
    let code: String
}

struct CheckInRequest: Codable {
    let passId: String
    let gymId: String
}

struct PaymentResult {
    let success: Bool
    let paymentId: String
    let errorMessage: String?
}

// MARK: - Protocols

protocol PaymentProcessorProtocol {
    func processPayment(amount: Decimal) async -> PaymentResult
}

// MARK: - PassServiceTests

@MainActor
final class PassServiceTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: PassService!
    private var mockNetworkClient: MockNetworkClient!
    private var mockPaymentProcessor: MockPaymentProcessor!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        mockPaymentProcessor = MockPaymentProcessor()
        sut = PassService(
            networkClient: mockNetworkClient,
            paymentProcessor: mockPaymentProcessor
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient.reset()
        mockPaymentProcessor.reset()
        mockNetworkClient = nil
        mockPaymentProcessor = nil
        super.tearDown()
    }
    
    // MARK: - Fetch User Passes Tests
    
    func test_fetchUserPasses_withValidUserId_returnsPasses() async throws {
        // Given
        let expectedPasses = [
            GymPass(
                id: "pass-1",
                userId: "user-1",
                type: .standard,
                status: .active,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                checkInsRemaining: nil,
                totalCheckIns: 10,
                gyms: ["gym-1"],
                autoRenew: true,
                price: 49.99
            )
        ]
        mockNetworkClient.mockPasses = expectedPasses
        
        // When
        let passes = try await sut.fetchUserPasses(userId: "user-1")
        
        // Then
        XCTAssertEqual(passes.count, 1)
        XCTAssertEqual(passes.first?.id, "pass-1")
    }
    
    func test_fetchUserPasses_withEmptyUserId_throwsError() async {
        // When/Then
        do {
            _ = try await sut.fetchUserPasses(userId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            if case .unknown = error {
                // Expected
            } else {
                XCTFail("Expected unknown error")
            }
        }
    }
    
    func test_fetchUserPasses_withNetworkError_throwsNetworkError() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .networkError
        
        // When/Then
        do {
            _ = try await sut.fetchUserPasses(userId: "user-1")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .networkError)
        }
    }
    
    // MARK: - Fetch Active Pass Tests
    
    func test_fetchActivePass_withActivePass_returnsPass() async throws {
        // Given
        let expectedPass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPass = expectedPass
        
        // When
        let pass = try await sut.fetchActivePass(userId: "user-1")
        
        // Then
        XCTAssertNotNil(pass)
        XCTAssertEqual(pass?.id, "pass-1")
    }
    
    func test_fetchActivePass_withNoActivePass_returnsNil() async throws {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .notFound
        
        // When
        let pass = try await sut.fetchActivePass(userId: "user-1")
        
        // Then
        XCTAssertNil(pass)
    }
    
    // MARK: - Create Pass Tests
    
    func test_createPass_withValidData_returnsPass() async throws {
        // Given
        mockPaymentProcessor.shouldSucceed = true
        mockPaymentProcessor.paymentId = "payment-123"
        
        let expectedPass = GymPass(
            id: "new-pass",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            checkInsRemaining: nil,
            totalCheckIns: 0,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPass = expectedPass
        
        // When
        let pass = try await sut.createPass(userId: "user-1", type: .standard, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(pass.id, "new-pass")
        XCTAssertEqual(mockPaymentProcessor.processPaymentCallCount, 1)
    }
    
    func test_createPass_withFailedPayment_throwsPaymentRequired() async {
        // Given
        mockPaymentProcessor.shouldSucceed = false
        
        // When/Then
        do {
            _ = try await sut.createPass(userId: "user-1", type: .standard, duration: .oneMonth)
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .paymentRequired)
        }
    }
    
    func test_createPass_withEmptyUserId_throwsError() async {
        // When/Then
        do {
            _ = try await sut.createPass(userId: "", type: .standard, duration: .oneMonth)
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            if case .unknown = error {
                // Expected
            } else {
                XCTFail("Expected unknown error")
            }
        }
    }
    
    // MARK: - Renew Pass Tests
    
    func test_renewPass_withValidPassId_returnsRenewedPass() async throws {
        // Given
        let existingPass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPasses = [existingPass]
        mockPaymentProcessor.shouldSucceed = true
        mockPaymentProcessor.paymentId = "payment-456"
        
        let renewedPass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 60),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPass = renewedPass
        
        // When
        let pass = try await sut.renewPass(passId: "pass-1")
        
        // Then
        XCTAssertEqual(pass.id, "pass-1")
        XCTAssertEqual(mockPaymentProcessor.processPaymentCallCount, 1)
    }
    
    func test_renewPass_withNonexistentPass_throwsPassNotFound() async {
        // Given
        mockNetworkClient.mockPasses = []
        
        // When/Then
        do {
            _ = try await sut.renewPass(passId: "nonexistent")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passNotFound)
        }
    }
    
    func test_renewPass_withEmptyPassId_throwsPassNotFound() async {
        // When/Then
        do {
            _ = try await sut.renewPass(passId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passNotFound)
        }
    }
    
    // MARK: - Cancel Pass Tests
    
    func test_cancelPass_withValidPassId_succeeds() async throws {
        // Given
        let existingPass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPasses = [existingPass]
        
        // When/Then - Should not throw
        try await sut.cancelPass(passId: "pass-1")
    }
    
    func test_cancelPass_withEmptyPassId_throwsPassNotFound() async {
        // When/Then
        do {
            try await sut.cancelPass(passId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passNotFound)
        }
    }
    
    // MARK: - Generate QR Code Tests
    
    func test_generateQRCode_withActivePass_returnsQRCodeData() async throws {
        // Given
        let activePass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: true,
            price: 49.99
        )
        mockNetworkClient.mockPasses = [activePass]
        
        let expectedQRData = QRCodeData(
            code: "QR123456",
            passId: "pass-1",
            expiresAt: Date().addingTimeInterval(300),
            imageData: Data()
        )
        mockNetworkClient.mockQRCodeData = expectedQRData
        
        // When
        let qrData = try await sut.generateQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(qrData.code, "QR123456")
    }
    
    func test_generateQRCode_withExpiredPass_throwsPassExpired() async {
        // Given
        let expiredPass = GymPass(
            id: "pass-1",
            userId: "user-1",
            type: .standard,
            status: .expired,
            startDate: Date().addingTimeInterval(-86400 * 60),
            endDate: Date().addingTimeInterval(-86400),
            checkInsRemaining: nil,
            totalCheckIns: 10,
            gyms: ["gym-1"],
            autoRenew: false,
            price: 49.99
        )
        mockNetworkClient.mockPasses = [expiredPass]
        
        // When/Then
        do {
            _ = try await sut.generateQRCode(passId: "pass-1")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passExpired)
        }
    }
    
    func test_generateQRCode_withEmptyPassId_throwsPassNotFound() async {
        // When/Then
        do {
            _ = try await sut.generateQRCode(passId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passNotFound)
        }
    }
    
    // MARK: - Validate QR Code Tests
    
    func test_validateQRCode_withValidCode_returnsValidResult() async throws {
        // Given
        let expectedResult = QRValidationResult(
            isValid: true,
            passId: "pass-1",
            message: "Valid QR code",
            timestamp: Date()
        )
        mockNetworkClient.mockQRValidationResult = expectedResult
        
        // When
        let result = try await sut.validateQRCode(code: "QR123456")
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.passId, "pass-1")
    }
    
    func test_validateQRCode_withEmptyCode_throwsQRCodeInvalid() async {
        // When/Then
        do {
            _ = try await sut.validateQRCode(code: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .qrCodeInvalid)
        }
    }
    
    // MARK: - Check In Tests
    
    func test_checkIn_withValidData_returnsSuccess() async throws {
        // Given
        let expectedResult = CheckInResult(
            success: true,
            message: "Check-in successful",
            timestamp: Date(),
            gymName: "Downtown Fitness"
        )
        mockNetworkClient.mockCheckInResult = expectedResult
        
        // When
        let result = try await sut.checkIn(passId: "pass-1", gymId: "gym-1")
        
        // Then
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.message, "Check-in successful")
    }
    
    func test_checkIn_withEmptyPassId_throwsCheckInFailed() async {
        // When/Then
        do {
            _ = try await sut.checkIn(passId: "", gymId: "gym-1")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .checkInFailed)
        }
    }
    
    func test_checkIn_withEmptyGymId_throwsCheckInFailed() async {
        // When/Then
        do {
            _ = try await sut.checkIn(passId: "pass-1", gymId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .checkInFailed)
        }
    }
    
    // MARK: - Fetch Check-In History Tests
    
    func test_fetchCheckInHistory_withValidPassId_returnsHistory() async throws {
        // Given
        let expectedHistory = [
            CheckInRecord(
                id: "checkin-1",
                passId: "pass-1",
                gymId: "gym-1",
                gymName: "Downtown Fitness",
                timestamp: Date(),
                isValid: true
            )
        ]
        mockNetworkClient.mockCheckInHistory = expectedHistory
        
        // When
        let history = try await sut.fetchCheckInHistory(passId: "pass-1")
        
        // Then
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.gymName, "Downtown Fitness")
    }
    
    func test_fetchCheckInHistory_withEmptyPassId_throwsPassNotFound() async {
        // When/Then
        do {
            _ = try await sut.fetchCheckInHistory(passId: "")
            XCTFail("Expected error to be thrown")
        } catch let error as PassError {
            XCTAssertEqual(error, .passNotFound)
        }
    }
    
    // MARK: - Fetch Pass Types Tests
    
    func test_fetchPassTypes_returnsTypes() async throws {
        // Given
        let expectedTypes = [
            PassTypeInfo(
                type: .standard,
                name: "Standard Pass",
                description: "Access to all basic facilities",
                features: ["Gym access", "Locker room"],
                basePrice: 49.99
            ),
            PassTypeInfo(
                type: .premium,
                name: "Premium Pass",
                description: "Full access with premium amenities",
                features: ["Pool", "Sauna"],
                basePrice: 79.99
            )
        ]
        mockNetworkClient.mockPassTypes = expectedTypes
        
        // When
        let types = try await sut.fetchPassTypes()
        
        // Then
        XCTAssertEqual(types.count, 2)
        XCTAssertEqual(types.first?.type, .standard)
    }
    
    // MARK: - Calculate Pass Price Tests
    
    func test_calculatePassPrice_standardOneMonth_returnsCorrectPrice() {
        // When
        let price = sut.calculatePassPrice(type: .standard, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(price, 49.99)
    }
    
    func test_calculatePassPrice_premiumOneMonth_returnsCorrectPrice() {
        // When
        let price = sut.calculatePassPrice(type: .premium, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(price, 79.99)
    }
    
    func test_calculatePassPrice_dayPass_returnsCorrectPrice() {
        // When
        let price = sut.calculatePassPrice(type: .dayPass, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(price, 15.99)
    }
    
    func test_calculatePassPrice_withLongerDuration_appliesDiscount() {
        // When
        let oneMonthPrice = sut.calculatePassPrice(type: .standard, duration: .oneMonth)
        let threeMonthPrice = sut.calculatePassPrice(type: .standard, duration: .threeMonths)
        let sixMonthPrice = sut.calculatePassPrice(type: .standard, duration: .sixMonths)
        let oneYearPrice = sut.calculatePassPrice(type: .standard, duration: .oneYear)
        
        // Then
        XCTAssertTrue(threeMonthPrice < oneMonthPrice * 3)
        XCTAssertTrue(sixMonthPrice < oneMonthPrice * 6)
        XCTAssertTrue(oneYearPrice < oneMonthPrice * 12)
    }
    
    // MARK: - Publisher Tests
    
    func test_passesPublisher_publishesChanges() async {
        // Given
        let expectedPasses = [
            GymPass(
                id: "pass-1",
                userId: "user-1",
                type: .standard,
                status: .active,
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 30),
                checkInsRemaining: nil,
                totalCheckIns: 10,
                gyms: ["gym-1"],
                autoRenew: true,
                price: 49.99
            )
        ]
        mockNetworkClient.mockPasses = expectedPasses
        
        let expectation = XCTestExpectation(description: "Passes publisher emits")
        
        var receivedPasses: [GymPass] = []
        let cancellable = sut.passesPublisher
            .dropFirst()
            .first()
            .sink { passes in
                receivedPasses = passes
                expectation.fulfill()
            }
        
        // When
        _ = try? await sut.fetchUserPasses(userId: "user-1")
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(receivedPasses.count, 1)
        
        cancellable.cancel()
    }
}

// MARK: - Mock Payment Processor

class MockPaymentProcessor: PaymentProcessorProtocol {
    var shouldSucceed = true
    var paymentId = "mock-payment-id"
    var processPaymentCallCount = 0
    
    func processPayment(amount: Decimal) async -> PaymentResult {
        processPaymentCallCount += 1
        
        if shouldSucceed {
            return PaymentResult(
                success: true,
                paymentId: paymentId,
                errorMessage: nil
            )
        } else {
            return PaymentResult(
                success: false,
                paymentId: "",
                errorMessage: "Payment failed"
            )
        }
    }
    
    func reset() {
        shouldSucceed = true
        paymentId = "mock-payment-id"
        processPaymentCallCount = 0
    }
}

// MARK: - Decimal Extension

extension Decimal {
    func rounded(_ scale: Int) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, .plain)
        return result
    }
}

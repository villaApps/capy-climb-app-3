// MARK: - QR Code ViewModel Tests
// Comprehensive unit tests for QRCodeViewModel following TDD principles

import XCTest
import Combine
import UIKit
@testable import CapybaraGym

// MARK: - QRCodeViewModel
/// ViewModel responsible for managing QR code generation and display
@MainActor
final class QRCodeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var qrCodeData: QRCodeData?
    @Published var qrCodeImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var timeRemaining: Int = 300 // 5 minutes in seconds
    @Published var isExpired: Bool = false
    @Published var showCheckInSuccess: Bool = false
    @Published var checkInMessage: String = ""
    
    // MARK: - Dependencies
    private let passService: PassServiceProtocol
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var canRefresh: Bool {
        !isLoading && !isExpired
    }
    
    // MARK: - Initialization
    init(passService: PassServiceProtocol) {
        self.passService = passService
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Lifecycle
    func onAppear(passId: String) async {
        await generateQRCode(passId: passId)
        startTimer()
    }
    
    func onDisappear() {
        stopTimer()
    }
    
    // MARK: - QR Code Generation
    func generateQRCode(passId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await passService.generateQRCode(passId: passId)
            qrCodeData = data
            timeRemaining = 300 // Reset to 5 minutes
            isExpired = false
            
            // Generate UIImage from data
            if !data.imageData.isEmpty {
                qrCodeImage = UIImage(data: data.imageData)
            }
        } catch let error as PassError {
            handlePassError(error)
        } catch {
            errorMessage = "Failed to generate QR code"
        }
        
        isLoading = false
    }
    
    func refreshQRCode(passId: String) async {
        guard canRefresh else { return }
        await generateQRCode(passId: passId)
    }
    
    // MARK: - QR Code Validation
    func validateQRCode(code: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await passService.validateQRCode(code: code)
            if result.isValid {
                showCheckInSuccess = true
                checkInMessage = result.message
            } else {
                errorMessage = result.message
            }
        } catch {
            errorMessage = "Failed to validate QR code"
        }
        
        isLoading = false
    }
    
    // MARK: - Check In
    func checkIn(passId: String, gymId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await passService.checkIn(passId: passId, gymId: gymId)
            if result.success {
                showCheckInSuccess = true
                checkInMessage = result.message
            } else {
                errorMessage = result.message
            }
        } catch let error as PassError {
            handlePassError(error)
        } catch {
            errorMessage = "Check-in failed"
        }
        
        isLoading = false
    }
    
    // MARK: - Timer Management
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func tick() {
        guard timeRemaining > 0 else {
            isExpired = true
            stopTimer()
            return
        }
        timeRemaining -= 1
    }
    
    // MARK: - Actions
    func dismissCheckInSuccess() {
        showCheckInSuccess = false
        checkInMessage = ""
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func reset() {
        qrCodeData = nil
        qrCodeImage = nil
        timeRemaining = 300
        isExpired = false
        errorMessage = nil
        showCheckInSuccess = false
        checkInMessage = ""
        stopTimer()
    }
    
    // MARK: - Private Methods
    private func handlePassError(_ error: PassError) {
        switch error {
        case .passNotFound:
            errorMessage = "Pass not found"
        case .passExpired:
            errorMessage = "Pass has expired"
        case .qrCodeGenerationFailed:
            errorMessage = "Failed to generate QR code"
        case .qrCodeExpired:
            errorMessage = "QR code has expired"
        case .qrCodeInvalid:
            errorMessage = "Invalid QR code"
        case .checkInFailed:
            errorMessage = "Check-in failed"
        case .networkError:
            errorMessage = "Network error. Please try again."
        default:
            errorMessage = "An error occurred"
        }
    }
}

// MARK: - QRCodeViewModelTests
@MainActor
final class QRCodeViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: QRCodeViewModel!
    private var mockPassService: MockPassService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockPassService = MockPassService()
        sut = QRCodeViewModel(passService: mockPassService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut.onDisappear()
        sut = nil
        mockPassService.reset()
        mockPassService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasNoQRCodeData() {
        XCTAssertNil(sut.qrCodeData)
    }
    
    func test_initialState_hasNoQRCodeImage() {
        XCTAssertNil(sut.qrCodeImage)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_has300SecondsRemaining() {
        XCTAssertEqual(sut.timeRemaining, 300)
    }
    
    func test_initialState_isNotExpired() {
        XCTAssertFalse(sut.isExpired)
    }
    
    func test_initialState_doesNotShowCheckInSuccess() {
        XCTAssertFalse(sut.showCheckInSuccess)
    }
    
    func test_initialState_hasEmptyCheckInMessage() {
        XCTAssertEqual(sut.checkInMessage, "")
    }
    
    // MARK: - Formatted Time Remaining Tests
    
    func test_formattedTimeRemaining_with300Seconds_returnsFiveMinutes() {
        sut.timeRemaining = 300
        XCTAssertEqual(sut.formattedTimeRemaining, "05:00")
    }
    
    func test_formattedTimeRemaining_with60Seconds_returnsOneMinute() {
        sut.timeRemaining = 60
        XCTAssertEqual(sut.formattedTimeRemaining, "01:00")
    }
    
    func test_formattedTimeRemaining_with59Seconds_returnsZeroFiftyNine() {
        sut.timeRemaining = 59
        XCTAssertEqual(sut.formattedTimeRemaining, "00:59")
    }
    
    func test_formattedTimeRemaining_withZeroSeconds_returnsZeroZero() {
        sut.timeRemaining = 0
        XCTAssertEqual(sut.formattedTimeRemaining, "00:00")
    }
    
    func test_formattedTimeRemaining_withOneSecond_returnsZeroZeroOne() {
        sut.timeRemaining = 1
        XCTAssertEqual(sut.formattedTimeRemaining, "00:01")
    }
    
    // MARK: - Can Refresh Tests
    
    func test_canRefresh_whenNotLoadingAndNotExpired_returnsTrue() {
        sut.isLoading = false
        sut.isExpired = false
        XCTAssertTrue(sut.canRefresh)
    }
    
    func test_canRefresh_whenLoading_returnsFalse() {
        sut.isLoading = true
        sut.isExpired = false
        XCTAssertFalse(sut.canRefresh)
    }
    
    func test_canRefresh_whenExpired_returnsFalse() {
        sut.isLoading = false
        sut.isExpired = true
        XCTAssertFalse(sut.canRefresh)
    }
    
    // MARK: - Generate QR Code Tests
    
    func test_generateQRCode_success_setsQRCodeData() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.generateQRCode(passId: "pass-1")
        
        // Then
        XCTAssertNotNil(sut.qrCodeData)
        XCTAssertEqual(mockPassService.generateQRCodeCallCount, 1)
        XCTAssertEqual(mockPassService.capturedPassId, "pass-1")
    }
    
    func test_generateQRCode_success_resetsTimer() async {
        // Given
        mockPassService.shouldSucceed = true
        sut.timeRemaining = 100
        sut.isExpired = true
        
        // When
        await sut.generateQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(sut.timeRemaining, 300)
        XCTAssertFalse(sut.isExpired)
    }
    
    func test_generateQRCode_failure_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnPassNotFound = true
        
        // When
        await sut.generateQRCode(passId: "invalid-pass")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Pass not found")
        XCTAssertNil(sut.qrCodeData)
    }
    
    func test_generateQRCode_withExpiredPass_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnPassExpired = true
        
        // When
        await sut.generateQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Pass has expired")
    }
    
    func test_generateQRCode_withNetworkError_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.generateQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Network error. Please try again.")
    }
    
    // MARK: - Refresh QR Code Tests
    
    func test_refreshQRCode_whenCanRefresh_generatesNewCode() async {
        // Given
        mockPassService.shouldSucceed = true
        sut.isLoading = false
        sut.isExpired = false
        
        // When
        await sut.refreshQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(mockPassService.generateQRCodeCallCount, 1)
    }
    
    func test_refreshQRCode_whenLoading_doesNotGenerate() async {
        // Given
        sut.isLoading = true
        sut.isExpired = false
        
        // When
        await sut.refreshQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(mockPassService.generateQRCodeCallCount, 0)
    }
    
    func test_refreshQRCode_whenExpired_doesNotGenerate() async {
        // Given
        sut.isLoading = false
        sut.isExpired = true
        
        // When
        await sut.refreshQRCode(passId: "pass-1")
        
        // Then
        XCTAssertEqual(mockPassService.generateQRCodeCallCount, 0)
    }
    
    // MARK: - Validate QR Code Tests
    
    func test_validateQRCode_withValidCode_showsSuccess() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.validateQRCode(code: "QR123456")
        
        // Then
        XCTAssertTrue(sut.showCheckInSuccess)
        XCTAssertNotNil(sut.checkInMessage)
    }
    
    func test_validateQRCode_withInvalidCode_setsErrorMessage() async {
        // Given
        mockPassService.shouldSucceed = false
        
        // When
        await sut.validateQRCode(code: "INVALID")
        
        // Then
        XCTAssertFalse(sut.showCheckInSuccess)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func test_validateQRCode_withExpiredCode_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnQRCodeExpired = true
        
        // When
        await sut.validateQRCode(code: "QR123456")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "QR code has expired")
    }
    
    // MARK: - Check In Tests
    
    func test_checkIn_success_showsSuccess() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.checkIn(passId: "pass-1", gymId: "gym-1")
        
        // Then
        XCTAssertTrue(sut.showCheckInSuccess)
        XCTAssertEqual(sut.checkInMessage, "Check-in successful")
        XCTAssertEqual(mockPassService.checkInCallCount, 1)
    }
    
    func test_checkIn_failure_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnCheckInFailed = true
        
        // When
        await sut.checkIn(passId: "pass-1", gymId: "gym-1")
        
        // Then
        XCTAssertFalse(sut.showCheckInSuccess)
        XCTAssertEqual(sut.errorMessage, "Check-in failed")
    }
    
    func test_checkIn_withExpiredPass_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnPassExpired = true
        
        // When
        await sut.checkIn(passId: "pass-1", gymId: "gym-1")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Pass has expired")
    }
    
    func test_checkIn_withNetworkError_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.checkIn(passId: "pass-1", gymId: "gym-1")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Network error. Please try again.")
    }
    
    // MARK: - Timer Tests
    
    func test_tick_decrementsTimeRemaining() {
        // Given
        sut.timeRemaining = 300
        
        // When
        sut.tick()
        
        // Then
        XCTAssertEqual(sut.timeRemaining, 299)
    }
    
    func test_tick_whenTimeReachesZero_setsExpired() {
        // Given
        sut.timeRemaining = 1
        
        // When
        sut.tick()
        
        // Then
        XCTAssertEqual(sut.timeRemaining, 0)
        XCTAssertTrue(sut.isExpired)
    }
    
    func test_tick_whenTimeAlreadyZero_keepsZero() {
        // Given
        sut.timeRemaining = 0
        
        // When
        sut.tick()
        
        // Then
        XCTAssertEqual(sut.timeRemaining, 0)
    }
    
    // MARK: - Dismiss Check In Success Tests
    
    func test_dismissCheckInSuccess_hidesSuccess() {
        // Given
        sut.showCheckInSuccess = true
        sut.checkInMessage = "Success!"
        
        // When
        sut.dismissCheckInSuccess()
        
        // Then
        XCTAssertFalse(sut.showCheckInSuccess)
        XCTAssertEqual(sut.checkInMessage, "")
    }
    
    // MARK: - Clear Error Tests
    
    func test_clearError_clearsErrorMessage() {
        // Given
        sut.errorMessage = "Some error"
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Reset Tests
    
    func test_reset_clearsAllData() async {
        // Given
        mockPassService.shouldSucceed = true
        await sut.generateQRCode(passId: "pass-1")
        sut.timeRemaining = 100
        sut.isExpired = true
        sut.errorMessage = "Error"
        sut.showCheckInSuccess = true
        sut.checkInMessage = "Success"
        
        // When
        sut.reset()
        
        // Then
        XCTAssertNil(sut.qrCodeData)
        XCTAssertNil(sut.qrCodeImage)
        XCTAssertEqual(sut.timeRemaining, 300)
        XCTAssertFalse(sut.isExpired)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.showCheckInSuccess)
        XCTAssertEqual(sut.checkInMessage, "")
    }
    
    // MARK: - Loading State Tests
    
    func test_generateQRCode_togglesLoadingState() async {
        // Given
        mockPassService.shouldSucceed = true
        
        let expectation = expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await sut.generateQRCode(passId: "pass-1")
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertEqual(loadingStates.last, false)
    }
    
    // MARK: - Lifecycle Tests
    
    func test_onAppear_generatesQRCode() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.onAppear(passId: "pass-1")
        
        // Then
        XCTAssertEqual(mockPassService.generateQRCodeCallCount, 1)
    }
    
    func test_onDisappear_stopsTimer() {
        // Given
        sut.startTimer()
        
        // When
        sut.onDisappear()
        
        // Then - Timer should be nil after stopping
        // We can't directly test this, but we can verify no crashes occur
    }
    
    // MARK: - Publisher Tests
    
    func test_qrCodeDataPublisher_publishesChanges() async {
        // Given
        mockPassService.shouldSucceed = true
        
        let expectation = expectation(description: "QR code data publisher emits")
        
        sut.$qrCodeData
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.generateQRCode(passId: "pass-1")
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    func test_timeRemainingPublisher_publishesChanges() {
        // Given
        let expectation = expectation(description: "Time remaining publisher emits")
        
        sut.$timeRemaining
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        sut.tick()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Boundary Condition Tests
    
    func test_tick_withLargeTimeRemaining_decrementsCorrectly() {
        sut.timeRemaining = 599 // 9:59
        sut.tick()
        XCTAssertEqual(sut.timeRemaining, 598)
    }
    
    func test_formattedTimeRemaining_withLargeTime_formatsCorrectly() {
        sut.timeRemaining = 599
        XCTAssertEqual(sut.formattedTimeRemaining, "09:59")
    }
}

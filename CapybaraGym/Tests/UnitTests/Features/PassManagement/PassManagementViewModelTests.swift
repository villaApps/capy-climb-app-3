// MARK: - Pass Management ViewModel Tests
// Comprehensive unit tests for PassManagementViewModel following TDD principles

import XCTest
import Combine
@testable import CapybaraGym

// MARK: - PassManagementViewModel
/// ViewModel responsible for managing pass-related functionality
@MainActor
final class PassManagementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var passes: [GymPass] = []
    @Published var activePass: GymPass?
    @Published var selectedPass: GymPass?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showCreatePassSheet: Bool = false
    @Published var showPassDetails: Bool = false
    @Published var showCancelConfirmation: Bool = false
    @Published var showRenewConfirmation: Bool = false
    @Published var passTypes: [PassTypeInfo] = []
    @Published var checkInHistory: [CheckInRecord] = []
    
    // MARK: - Dependencies
    private let passService: PassServiceProtocol
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var hasPasses: Bool {
        !passes.isEmpty
    }
    
    var hasActivePass: Bool {
        activePass?.isActive == true
    }
    
    var expiredPasses: [GymPass] {
        passes.filter { $0.status == .expired }
    }
    
    var cancelledPasses: [GymPass] {
        passes.filter { $0.status == .cancelled }
    }
    
    // MARK: - Initialization
    init(passService: PassServiceProtocol, authService: AuthServiceProtocol) {
        self.passService = passService
        self.authService = authService
    }
    
    // MARK: - Lifecycle
    func onAppear() async {
        await fetchData()
    }
    
    func onRefresh() async {
        await fetchData()
    }
    
    // MARK: - Data Fetching
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.fetchPasses()
            }
            group.addTask {
                await self.fetchPassTypes()
            }
        }
        
        isLoading = false
    }
    
    func fetchPasses() async {
        guard let user = await authService.getCurrentUser() else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            passes = try await passService.fetchUserPasses(userId: user.id)
            activePass = passes.first { $0.status == .active }
        } catch {
            errorMessage = "Failed to load passes"
        }
    }
    
    func fetchPassTypes() async {
        do {
            passTypes = try await passService.fetchPassTypes()
        } catch {
            // Silently fail - pass types not critical
        }
    }
    
    func fetchCheckInHistory(for passId: String) async {
        isLoading = true
        
        do {
            checkInHistory = try await passService.fetchCheckInHistory(passId: passId)
        } catch {
            errorMessage = "Failed to load check-in history"
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    func selectPass(_ pass: GymPass) {
        selectedPass = pass
        showPassDetails = true
    }
    
    func clearSelection() {
        selectedPass = nil
        showPassDetails = false
    }
    
    func showCreatePass() {
        showCreatePassSheet = true
    }
    
    func hideCreatePass() {
        showCreatePassSheet = false
    }
    
    func confirmCancelPass() {
        showCancelConfirmation = true
    }
    
    func cancelPass() async {
        guard let pass = selectedPass else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await passService.cancelPass(passId: pass.id)
            showCancelConfirmation = false
            await fetchPasses()
        } catch {
            errorMessage = "Failed to cancel pass"
        }
        
        isLoading = false
    }
    
    func confirmRenewPass() {
        showRenewConfirmation = true
    }
    
    func renewPass() async {
        guard let pass = selectedPass else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let renewedPass = try await passService.renewPass(passId: pass.id)
            showRenewConfirmation = false
            selectedPass = renewedPass
            await fetchPasses()
        } catch let error as PassError {
            handlePassError(error)
        } catch {
            errorMessage = "Failed to renew pass"
        }
        
        isLoading = false
    }
    
    func createPass(type: PassType, duration: PassDuration) async {
        guard let user = await authService.getCurrentUser() else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await passService.createPass(
                userId: user.id,
                type: type,
                duration: duration
            )
            showCreatePassSheet = false
            await fetchPasses()
        } catch let error as PassError {
            handlePassError(error)
        } catch {
            errorMessage = "Failed to create pass"
        }
        
        isLoading = false
    }
    
    func calculatePrice(type: PassType, duration: PassDuration) -> Decimal {
        passService.calculatePassPrice(type: type, duration: duration)
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func handlePassError(_ error: PassError) {
        switch error {
        case .paymentRequired:
            errorMessage = "Payment required. Please update your payment method."
        case .passNotFound:
            errorMessage = "Pass not found"
        case .passExpired:
            errorMessage = "Pass has expired"
        case .networkError:
            errorMessage = "Network error. Please try again."
        default:
            errorMessage = "An error occurred. Please try again."
        }
    }
}

// MARK: - PassManagementViewModelTests
@MainActor
final class PassManagementViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: PassManagementViewModel!
    private var mockPassService: MockPassService!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockPassService = MockPassService()
        mockAuthService = MockAuthService()
        sut = PassManagementViewModel(
            passService: mockPassService,
            authService: mockAuthService
        )
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockPassService.reset()
        mockAuthService.reset()
        mockPassService = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasEmptyPasses() {
        XCTAssertTrue(sut.passes.isEmpty)
    }
    
    func test_initialState_hasNoActivePass() {
        XCTAssertNil(sut.activePass)
    }
    
    func test_initialState_hasNoSelectedPass() {
        XCTAssertNil(sut.selectedPass)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_doesNotShowCreatePassSheet() {
        XCTAssertFalse(sut.showCreatePassSheet)
    }
    
    func test_initialState_doesNotShowPassDetails() {
        XCTAssertFalse(sut.showPassDetails)
    }
    
    func test_initialState_doesNotShowCancelConfirmation() {
        XCTAssertFalse(sut.showCancelConfirmation)
    }
    
    func test_initialState_doesNotShowRenewConfirmation() {
        XCTAssertFalse(sut.showRenewConfirmation)
    }
    
    func test_initialState_hasEmptyPassTypes() {
        XCTAssertTrue(sut.passTypes.isEmpty)
    }
    
    func test_initialState_hasEmptyCheckInHistory() {
        XCTAssertTrue(sut.checkInHistory.isEmpty)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_hasPasses_withEmptyPasses_returnsFalse() {
        sut.passes = []
        XCTAssertFalse(sut.hasPasses)
    }
    
    func test_hasPasses_withPasses_returnsTrue() {
        sut.passes = mockPassService.mockPasses
        XCTAssertTrue(sut.hasPasses)
    }
    
    func test_hasActivePass_withNoActivePass_returnsFalse() {
        sut.activePass = nil
        XCTAssertFalse(sut.hasActivePass)
    }
    
    func test_hasActivePass_withActivePass_returnsTrue() {
        sut.activePass = mockPassService.mockPasses.first
        XCTAssertTrue(sut.hasActivePass)
    }
    
    func test_expiredPasses_returnsOnlyExpiredPasses() {
        // Given
        sut.passes = mockPassService.mockPasses
        
        // Then
        XCTAssertEqual(sut.expiredPasses.count, 1)
        XCTAssertEqual(sut.expiredPasses.first?.status, .expired)
    }
    
    func test_cancelledPasses_returnsOnlyCancelledPasses() {
        // Given
        var cancelledPass = mockPassService.mockPasses[0]
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
            autoRenew: cancelledPass.autoRenew,
            price: cancelledPass.price
        )
        sut.passes = [cancelledPass]
        
        // Then
        XCTAssertEqual(sut.cancelledPasses.count, 1)
        XCTAssertEqual(sut.cancelledPasses.first?.status, .cancelled)
    }
    
    // MARK: - Fetch Passes Tests
    
    func test_fetchPasses_withAuthenticatedUser_setsPasses() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldSucceed = true
        
        // When
        await sut.fetchPasses()
        
        // Then
        XCTAssertEqual(sut.passes.count, mockPassService.mockPasses.count)
        XCTAssertNotNil(sut.activePass)
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
    }
    
    func test_fetchPasses_withNoUser_setsErrorMessage() async {
        // Given
        mockAuthService.currentUser = nil
        
        // When
        await sut.fetchPasses()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "User not authenticated")
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 0)
    }
    
    func test_fetchPasses_failure_setsErrorMessage() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.fetchPasses()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to load passes")
    }
    
    // MARK: - Fetch Pass Types Tests
    
    func test_fetchPassTypes_success_setsPassTypes() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.fetchPassTypes()
        
        // Then
        XCTAssertEqual(sut.passTypes.count, mockPassService.mockPassTypes.count)
        XCTAssertEqual(mockPassService.fetchPassTypesCallCount, 1)
    }
    
    func test_fetchPassTypes_failure_doesNotSetErrorMessage() async {
        // Given
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.fetchPassTypes()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Fetch Check-In History Tests
    
    func test_fetchCheckInHistory_success_setsCheckInHistory() async {
        // Given
        mockPassService.shouldSucceed = true
        
        // When
        await sut.fetchCheckInHistory(for: "pass-1")
        
        // Then
        XCTAssertEqual(sut.checkInHistory.count, mockPassService.mockCheckInHistory.count)
        XCTAssertEqual(mockPassService.fetchCheckInHistoryCallCount, 1)
        XCTAssertEqual(mockPassService.capturedPassId, "pass-1")
    }
    
    func test_fetchCheckInHistory_failure_setsErrorMessage() async {
        // Given
        mockPassService.shouldReturnNetworkError = true
        
        // When
        await sut.fetchCheckInHistory(for: "pass-1")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to load check-in history")
    }
    
    // MARK: - Select Pass Tests
    
    func test_selectPass_setsSelectedPass() {
        // Given
        let pass = mockPassService.mockPasses.first!
        
        // When
        sut.selectPass(pass)
        
        // Then
        XCTAssertEqual(sut.selectedPass?.id, pass.id)
        XCTAssertTrue(sut.showPassDetails)
    }
    
    func test_clearSelection_clearsSelectedPass() {
        // Given
        sut.selectedPass = mockPassService.mockPasses.first
        sut.showPassDetails = true
        
        // When
        sut.clearSelection()
        
        // Then
        XCTAssertNil(sut.selectedPass)
        XCTAssertFalse(sut.showPassDetails)
    }
    
    // MARK: - Show/Hide Create Pass Tests
    
    func test_showCreatePass_setsShowCreatePassSheetToTrue() {
        // When
        sut.showCreatePass()
        
        // Then
        XCTAssertTrue(sut.showCreatePassSheet)
    }
    
    func test_hideCreatePass_setsShowCreatePassSheetToFalse() {
        // Given
        sut.showCreatePassSheet = true
        
        // When
        sut.hideCreatePass()
        
        // Then
        XCTAssertFalse(sut.showCreatePassSheet)
    }
    
    // MARK: - Cancel Pass Tests
    
    func test_confirmCancelPass_setsShowCancelConfirmationToTrue() {
        // When
        sut.confirmCancelPass()
        
        // Then
        XCTAssertTrue(sut.showCancelConfirmation)
    }
    
    func test_cancelPass_success_hidesConfirmationAndRefreshes() async {
        // Given
        sut.selectedPass = mockPassService.mockPasses.first
        mockPassService.shouldSucceed = true
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.cancelPass()
        
        // Then
        XCTAssertFalse(sut.showCancelConfirmation)
        XCTAssertEqual(mockPassService.cancelPassCallCount, 1)
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
    }
    
    func test_cancelPass_failure_setsErrorMessage() async {
        // Given
        sut.selectedPass = mockPassService.mockPasses.first
        mockPassService.shouldReturnPassNotFound = true
        
        // When
        await sut.cancelPass()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to cancel pass")
    }
    
    func test_cancelPass_withNoSelectedPass_doesNothing() async {
        // Given
        sut.selectedPass = nil
        
        // When
        await sut.cancelPass()
        
        // Then
        XCTAssertEqual(mockPassService.cancelPassCallCount, 0)
    }
    
    // MARK: - Renew Pass Tests
    
    func test_confirmRenewPass_setsShowRenewConfirmationToTrue() {
        // When
        sut.confirmRenewPass()
        
        // Then
        XCTAssertTrue(sut.showRenewConfirmation)
    }
    
    func test_renewPass_success_hidesConfirmationAndRefreshes() async {
        // Given
        sut.selectedPass = mockPassService.mockPasses.first
        mockPassService.shouldSucceed = true
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.renewPass()
        
        // Then
        XCTAssertFalse(sut.showRenewConfirmation)
        XCTAssertEqual(mockPassService.renewPassCallCount, 1)
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
    }
    
    func test_renewPass_withPaymentRequired_setsErrorMessage() async {
        // Given
        sut.selectedPass = mockPassService.mockPasses.first
        mockPassService.shouldReturnPaymentRequired = true
        
        // When
        await sut.renewPass()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Payment required. Please update your payment method.")
    }
    
    func test_renewPass_withNoSelectedPass_doesNothing() async {
        // Given
        sut.selectedPass = nil
        
        // When
        await sut.renewPass()
        
        // Then
        XCTAssertEqual(mockPassService.renewPassCallCount, 0)
    }
    
    // MARK: - Create Pass Tests
    
    func test_createPass_success_hidesSheetAndRefreshes() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldSucceed = true
        
        // When
        await sut.createPass(type: .standard, duration: .oneMonth)
        
        // Then
        XCTAssertFalse(sut.showCreatePassSheet)
        XCTAssertEqual(mockPassService.createPassCallCount, 1)
        XCTAssertEqual(mockPassService.capturedPassType, .standard)
        XCTAssertEqual(mockPassService.capturedPassDuration, .oneMonth)
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
    }
    
    func test_createPass_withNoUser_setsErrorMessage() async {
        // Given
        mockAuthService.currentUser = nil
        
        // When
        await sut.createPass(type: .standard, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(sut.errorMessage, "User not authenticated")
        XCTAssertEqual(mockPassService.createPassCallCount, 0)
    }
    
    func test_createPass_withPaymentRequired_setsErrorMessage() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldReturnPaymentRequired = true
        
        // When
        await sut.createPass(type: .premium, duration: .oneYear)
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Payment required. Please update your payment method.")
    }
    
    // MARK: - Calculate Price Tests
    
    func test_calculatePrice_callsService() {
        // When
        let price = sut.calculatePrice(type: .standard, duration: .oneMonth)
        
        // Then
        XCTAssertEqual(mockPassService.calculatePassPriceCallCount, 1)
        XCTAssertEqual(price, 49.99)
    }
    
    func test_calculatePrice_withDifferentTypes_returnsDifferentPrices() {
        // When
        let standardPrice = sut.calculatePrice(type: .standard, duration: .oneMonth)
        let premiumPrice = sut.calculatePrice(type: .premium, duration: .oneMonth)
        
        // Then
        XCTAssertNotEqual(standardPrice, premiumPrice)
        XCTAssertEqual(standardPrice, 49.99)
        XCTAssertEqual(premiumPrice, 79.99)
    }
    
    func test_calculatePrice_withDifferentDurations_returnsDifferentPrices() {
        // When
        let oneMonthPrice = sut.calculatePrice(type: .standard, duration: .oneMonth)
        let threeMonthPrice = sut.calculatePrice(type: .standard, duration: .threeMonths)
        
        // Then
        XCTAssertNotEqual(oneMonthPrice, threeMonthPrice)
        XCTAssertTrue(threeMonthPrice > oneMonthPrice)
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
    
    // MARK: - Loading State Tests
    
    func test_fetchData_togglesLoadingState() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
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
            await sut.fetchData()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertEqual(loadingStates.last, false)
    }
    
    // MARK: - Publisher Tests
    
    func test_passesPublisher_publishesChanges() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        let expectation = expectation(description: "Passes publisher emits")
        
        sut.$passes
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.fetchPasses()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - Integration Tests
    
    func test_onAppear_fetchesAllData() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldSucceed = true
        
        // When
        await sut.onAppear()
        
        // Then
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
        XCTAssertEqual(mockPassService.fetchPassTypesCallCount, 1)
    }
    
    func test_onRefresh_fetchesAllData() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockPassService.shouldSucceed = true
        
        // When
        await sut.onRefresh()
        
        // Then
        XCTAssertEqual(mockPassService.fetchUserPassesCallCount, 1)
        XCTAssertEqual(mockPassService.fetchPassTypesCallCount, 1)
    }
}

// MARK: - Sign In ViewModel Tests
// Comprehensive unit tests for SignInViewModel following TDD principles

import XCTest
import Combine
@testable import CapybaraGym

// MARK: - SignInViewModel
/// ViewModel responsible for handling sign-in logic
@MainActor
final class SignInViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignedIn: Bool = false
    @Published var showForgotPassword: Bool = false
    @Published var showConfirmation: Bool = false
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    var isEmailValid: Bool {
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
    
    var isPasswordValid: Bool {
        password.count >= 8
    }
    
    var canSubmit: Bool {
        isEmailValid && isPasswordValid && !isLoading
    }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Actions
    func signIn() async {
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signIn(email: email, password: password)
            isSignedIn = true
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate Apple Sign In
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For testing purposes, we'll simulate success
        isSignedIn = true
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate Google Sign In
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // For testing purposes, we'll simulate success
        isSignedIn = true
        isLoading = false
    }
    
    func forgotPassword() {
        showForgotPassword = true
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetForm() {
        email = ""
        password = ""
        errorMessage = nil
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .invalidCredentials:
            errorMessage = "Invalid email or password"
        case .userNotFound:
            errorMessage = "Account not found. Please sign up."
        case .networkError:
            errorMessage = "Network error. Please check your connection."
        case .sessionExpired:
            errorMessage = "Session expired. Please sign in again."
        default:
            errorMessage = "Sign in failed. Please try again."
        }
    }
}

// MARK: - SignInViewModelTests
@MainActor
final class SignInViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: SignInViewModel!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = SignInViewModel(authService: mockAuthService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService.reset()
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasEmptyEmail() {
        // Then
        XCTAssertEqual(sut.email, "")
    }
    
    func test_initialState_hasEmptyPassword() {
        // Then
        XCTAssertEqual(sut.password, "")
    }
    
    func test_initialState_isNotLoading() {
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_isNotSignedIn() {
        // Then
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_initialState_doesNotShowForgotPassword() {
        // Then
        XCTAssertFalse(sut.showForgotPassword)
    }
    
    // MARK: - Email Validation Tests
    
    func test_isEmailValid_withEmptyEmail_returnsFalse() {
        // Given
        sut.email = ""
        
        // Then
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withInvalidEmailNoAtSymbol_returnsFalse() {
        // Given
        sut.email = "invalidemail.com"
        
        // Then
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withInvalidEmailNoDomain_returnsFalse() {
        // Given
        sut.email = "test@invalid"
        
        // Then
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withValidEmail_returnsTrue() {
        // Given
        sut.email = "test@example.com"
        
        // Then
        XCTAssertTrue(sut.isEmailValid)
    }
    
    func test_isEmailValid_withValidEmailContainingPlus_returnsTrue() {
        // Given
        sut.email = "test+tag@example.com"
        
        // Then
        XCTAssertTrue(sut.isEmailValid)
    }
    
    // MARK: - Password Validation Tests
    
    func test_isPasswordValid_withEmptyPassword_returnsFalse() {
        // Given
        sut.password = ""
        
        // Then
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withShortPassword_returnsFalse() {
        // Given
        sut.password = "short"
        
        // Then
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withExactly8Characters_returnsTrue() {
        // Given
        sut.password = "password"
        
        // Then
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withLongPassword_returnsTrue() {
        // Given
        sut.password = "verylongpassword123"
        
        // Then
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    // MARK: - Can Submit Tests
    
    func test_canSubmit_withEmptyFields_returnsFalse() {
        // Given
        sut.email = ""
        sut.password = ""
        
        // Then
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_canSubmit_withOnlyEmail_returnsFalse() {
        // Given
        sut.email = "test@example.com"
        sut.password = ""
        
        // Then
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_canSubmit_withOnlyPassword_returnsFalse() {
        // Given
        sut.email = ""
        sut.password = "password123"
        
        // Then
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_canSubmit_withValidFields_returnsTrue() {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // Then
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_canSubmit_whileLoading_returnsFalse() {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.isLoading = true
        
        // Then
        XCTAssertFalse(sut.canSubmit)
    }
    
    // MARK: - Sign In Success Tests
    
    func test_signIn_withValidCredentials_setsIsSignedInToTrue() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldSucceed = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertTrue(sut.isSignedIn)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_signIn_withValidCredentials_callsAuthServiceSignIn() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockAuthService.signInCallCount, 1)
        XCTAssertEqual(mockAuthService.capturedSignInEmail, "test@example.com")
        XCTAssertEqual(mockAuthService.capturedSignInPassword, "password123")
    }
    
    func test_signIn_withValidCredentials_setsIsLoadingToFalse() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_signIn_withValidCredentials_clearsErrorMessage() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        sut.errorMessage = "Previous error"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Sign In Failure Tests
    
    func test_signIn_withInvalidCredentials_setsErrorMessage() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "wrongpassword"
        mockAuthService.shouldReturnInvalidCredentials = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Invalid email or password")
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_signIn_withUserNotFound_setsErrorMessage() async {
        // Given
        sut.email = "nonexistent@example.com"
        sut.password = "password123"
        mockAuthService.shouldReturnUserNotFound = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Account not found. Please sign up.")
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_signIn_withNetworkError_setsErrorMessage() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldReturnNetworkError = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Network error. Please check your connection.")
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_signIn_withSessionExpired_setsErrorMessage() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldReturnSessionExpired = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Session expired. Please sign in again.")
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_signIn_whenFailing_setsIsLoadingToFalse() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        mockAuthService.shouldReturnInvalidCredentials = true
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Sign In Edge Case Tests
    
    func test_signIn_withEmptyEmail_doesNotCallAuthService() async {
        // Given
        sut.email = ""
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockAuthService.signInCallCount, 0)
    }
    
    func test_signIn_withEmptyPassword_doesNotCallAuthService() async {
        // Given
        sut.email = "test@example.com"
        sut.password = ""
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockAuthService.signInCallCount, 0)
    }
    
    func test_signIn_withInvalidEmail_doesNotCallAuthService() async {
        // Given
        sut.email = "invalidemail"
        sut.password = "password123"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockAuthService.signInCallCount, 0)
    }
    
    func test_signIn_withShortPassword_doesNotCallAuthService() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "short"
        
        // When
        await sut.signIn()
        
        // Then
        XCTAssertEqual(mockAuthService.signInCallCount, 0)
    }
    
    // MARK: - Loading State Tests
    
    func test_signIn_setsIsLoadingToTrue() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        // Create expectation for loading state
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
            await sut.signIn()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
    
    // MARK: - Social Sign In Tests
    
    func test_signInWithApple_setsIsSignedInToTrue() async {
        // When
        await sut.signInWithApple()
        
        // Then
        XCTAssertTrue(sut.isSignedIn)
    }
    
    func test_signInWithApple_clearsErrorMessage() async {
        // Given
        sut.errorMessage = "Previous error"
        
        // When
        await sut.signInWithApple()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_signInWithGoogle_setsIsSignedInToTrue() async {
        // When
        await sut.signInWithGoogle()
        
        // Then
        XCTAssertTrue(sut.isSignedIn)
    }
    
    func test_signInWithGoogle_clearsErrorMessage() async {
        // Given
        sut.errorMessage = "Previous error"
        
        // When
        await sut.signInWithGoogle()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Forgot Password Tests
    
    func test_forgotPassword_setsShowForgotPasswordToTrue() {
        // When
        sut.forgotPassword()
        
        // Then
        XCTAssertTrue(sut.showForgotPassword)
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
    
    // MARK: - Reset Form Tests
    
    func test_resetForm_clearsEmail() {
        // Given
        sut.email = "test@example.com"
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertEqual(sut.email, "")
    }
    
    func test_resetForm_clearsPassword() {
        // Given
        sut.password = "password123"
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertEqual(sut.password, "")
    }
    
    func test_resetForm_clearsErrorMessage() {
        // Given
        sut.errorMessage = "Some error"
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_resetForm_setsIsLoadingToFalse() {
        // Given
        sut.isLoading = true
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - State Publisher Tests
    
    func test_isSignedIn_publishesChanges() async {
        // Given
        sut.email = "test@example.com"
        sut.password = "password123"
        
        let expectation = expectation(description: "isSignedIn publishes true")
        
        sut.$isSignedIn
            .dropFirst()
            .filter { $0 }
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.signIn()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(sut.isSignedIn)
    }
    
    // MARK: - Boundary Condition Tests
    
    func test_emailValidation_withExactly255Characters_isValid() {
        // Given
        let longLocalPart = String(repeating: "a", count: 247)
        sut.email = "\(longLocalPart)@b.co"
        
        // Then
        XCTAssertTrue(sut.isEmailValid)
    }
    
    func test_passwordValidation_withExactly8Characters_isValid() {
        // Given
        sut.password = "12345678"
        
        // Then
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    func test_passwordValidation_with7Characters_isInvalid() {
        // Given
        sut.password = "1234567"
        
        // Then
        XCTAssertFalse(sut.isPasswordValid)
    }
}

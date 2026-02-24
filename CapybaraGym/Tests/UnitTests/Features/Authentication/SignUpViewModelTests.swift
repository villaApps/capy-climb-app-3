// MARK: - Sign Up ViewModel Tests
// Comprehensive unit tests for SignUpViewModel following TDD principles

import XCTest
import Combine
@testable import CapybaraGym

// MARK: - SignUpViewModel
/// ViewModel responsible for handling sign-up logic
@MainActor
final class SignUpViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignedUp: Bool = false
    @Published var showConfirmation: Bool = false
    @Published var acceptedTerms: Bool = false
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    var isFirstNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isLastNameValid: Bool {
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var isPasswordValid: Bool {
        password.count >= 8 &&
        password.contains(where: { $0.isUppercase }) &&
        password.contains(where: { $0.isLowercase }) &&
        password.contains(where: { $0.isNumber })
    }
    
    var doPasswordsMatch: Bool {
        password == confirmPassword && !password.isEmpty
    }
    
    var passwordStrength: PasswordStrength {
        if password.isEmpty { return .empty }
        if password.count < 6 { return .weak }
        if !isPasswordValid { return .medium }
        return .strong
    }
    
    var canSubmit: Bool {
        isFirstNameValid &&
        isLastNameValid &&
        isEmailValid &&
        isPasswordValid &&
        doPasswordsMatch &&
        acceptedTerms &&
        !isLoading
    }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Actions
    func signUp() async {
        guard canSubmit else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            showConfirmation = true
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            errorMessage = "An unexpected error occurred"
        }
        
        isLoading = false
    }
    
    func confirmSignUp(code: String) async {
        guard code.count == 6 else {
            errorMessage = "Please enter a valid 6-digit code"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.confirmSignUp(email: email, confirmationCode: code)
            isSignedUp = true
            showConfirmation = false
        } catch let error as AuthError {
            handleAuthError(error)
        } catch {
            errorMessage = "Failed to confirm sign up"
        }
        
        isLoading = false
    }
    
    func resendConfirmationCode() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.resendConfirmationCode(email: email)
        } catch {
            errorMessage = "Failed to resend code"
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func resetForm() {
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        confirmPassword = ""
        acceptedTerms = false
        errorMessage = nil
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .userAlreadyExists:
            errorMessage = "An account with this email already exists"
        case .passwordTooWeak:
            errorMessage = "Password is too weak. Please use a stronger password."
        case .invalidConfirmationCode:
            errorMessage = "Invalid confirmation code. Please try again."
        case .networkError:
            errorMessage = "Network error. Please check your connection."
        default:
            errorMessage = "Sign up failed. Please try again."
        }
    }
}

// MARK: - Password Strength
enum PasswordStrength: String, CaseIterable {
    case empty = "empty"
    case weak = "weak"
    case medium = "medium"
    case strong = "strong"
}

// MARK: - SignUpViewModelTests
@MainActor
final class SignUpViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: SignUpViewModel!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = SignUpViewModel(authService: mockAuthService)
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
    
    func test_initialState_hasEmptyFirstName() {
        XCTAssertEqual(sut.firstName, "")
    }
    
    func test_initialState_hasEmptyLastName() {
        XCTAssertEqual(sut.lastName, "")
    }
    
    func test_initialState_hasEmptyEmail() {
        XCTAssertEqual(sut.email, "")
    }
    
    func test_initialState_hasEmptyPassword() {
        XCTAssertEqual(sut.password, "")
    }
    
    func test_initialState_hasEmptyConfirmPassword() {
        XCTAssertEqual(sut.confirmPassword, "")
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_isNotSignedUp() {
        XCTAssertFalse(sut.isSignedUp)
    }
    
    func test_initialState_doesNotShowConfirmation() {
        XCTAssertFalse(sut.showConfirmation)
    }
    
    func test_initialState_hasNotAcceptedTerms() {
        XCTAssertFalse(sut.acceptedTerms)
    }
    
    // MARK: - First Name Validation Tests
    
    func test_isFirstNameValid_withEmptyString_returnsFalse() {
        sut.firstName = ""
        XCTAssertFalse(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withWhitespaceOnly_returnsFalse() {
        sut.firstName = "   "
        XCTAssertFalse(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withValidName_returnsTrue() {
        sut.firstName = "John"
        XCTAssertTrue(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withNameWithSpaces_returnsTrue() {
        sut.firstName = "Mary Jane"
        XCTAssertTrue(sut.isFirstNameValid)
    }
    
    // MARK: - Last Name Validation Tests
    
    func test_isLastNameValid_withEmptyString_returnsFalse() {
        sut.lastName = ""
        XCTAssertFalse(sut.isLastNameValid)
    }
    
    func test_isLastNameValid_withWhitespaceOnly_returnsFalse() {
        sut.lastName = "   "
        XCTAssertFalse(sut.isLastNameValid)
    }
    
    func test_isLastNameValid_withValidName_returnsTrue() {
        sut.lastName = "Doe"
        XCTAssertTrue(sut.isLastNameValid)
    }
    
    // MARK: - Email Validation Tests
    
    func test_isEmailValid_withEmptyString_returnsFalse() {
        sut.email = ""
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withInvalidEmailNoAtSymbol_returnsFalse() {
        sut.email = "invalidemail.com"
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withInvalidEmailNoDomain_returnsFalse() {
        sut.email = "test@invalid"
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withInvalidEmailNoTLD_returnsFalse() {
        sut.email = "test@domain"
        XCTAssertFalse(sut.isEmailValid)
    }
    
    func test_isEmailValid_withValidEmail_returnsTrue() {
        sut.email = "test@example.com"
        XCTAssertTrue(sut.isEmailValid)
    }
    
    func test_isEmailValid_withValidEmailContainingPlus_returnsTrue() {
        sut.email = "test+tag@example.com"
        XCTAssertTrue(sut.isEmailValid)
    }
    
    func test_isEmailValid_withValidEmailContainingDots_returnsTrue() {
        sut.email = "first.last@example.co.uk"
        XCTAssertTrue(sut.isEmailValid)
    }
    
    // MARK: - Password Validation Tests
    
    func test_isPasswordValid_withEmptyPassword_returnsFalse() {
        sut.password = ""
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withShortPassword_returnsFalse() {
        sut.password = "Short1"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withPasswordNoUppercase_returnsFalse() {
        sut.password = "password123"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withPasswordNoLowercase_returnsFalse() {
        sut.password = "PASSWORD123"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withPasswordNoNumber_returnsFalse() {
        sut.password = "PasswordABC"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withValidPassword_returnsTrue() {
        sut.password = "Password123"
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    func test_isPasswordValid_withValidPasswordContainingSpecialChars_returnsTrue() {
        sut.password = "Password123!@#"
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    // MARK: - Password Strength Tests
    
    func test_passwordStrength_withEmptyPassword_returnsEmpty() {
        sut.password = ""
        XCTAssertEqual(sut.passwordStrength, .empty)
    }
    
    func test_passwordStrength_withShortPassword_returnsWeak() {
        sut.password = "abc"
        XCTAssertEqual(sut.passwordStrength, .weak)
    }
    
    func test_passwordStrength_withMediumPassword_returnsMedium() {
        sut.password = "password"
        XCTAssertEqual(sut.passwordStrength, .medium)
    }
    
    func test_passwordStrength_withStrongPassword_returnsStrong() {
        sut.password = "Password123"
        XCTAssertEqual(sut.passwordStrength, .strong)
    }
    
    // MARK: - Password Match Tests
    
    func test_doPasswordsMatch_withEmptyPasswords_returnsFalse() {
        sut.password = ""
        sut.confirmPassword = ""
        XCTAssertFalse(sut.doPasswordsMatch)
    }
    
    func test_doPasswordsMatch_withNonMatchingPasswords_returnsFalse() {
        sut.password = "Password123"
        sut.confirmPassword = "Password456"
        XCTAssertFalse(sut.doPasswordsMatch)
    }
    
    func test_doPasswordsMatch_withMatchingPasswords_returnsTrue() {
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        XCTAssertTrue(sut.doPasswordsMatch)
    }
    
    // MARK: - Can Submit Tests
    
    func test_canSubmit_withAllEmptyFields_returnsFalse() {
        sut.firstName = ""
        sut.lastName = ""
        sut.email = ""
        sut.password = ""
        sut.confirmPassword = ""
        sut.acceptedTerms = false
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_canSubmit_withValidFieldsButNoTermsAccepted_returnsFalse() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = false
        XCTAssertFalse(sut.canSubmit)
    }
    
    func test_canSubmit_withAllValidFieldsAndTermsAccepted_returnsTrue() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        XCTAssertTrue(sut.canSubmit)
    }
    
    func test_canSubmit_whileLoading_returnsFalse() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        sut.isLoading = true
        XCTAssertFalse(sut.canSubmit)
    }
    
    // MARK: - Sign Up Success Tests
    
    func test_signUp_withValidData_showsConfirmation() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        mockAuthService.shouldSucceed = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertTrue(sut.showConfirmation)
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_signUp_withValidData_callsAuthServiceSignUp() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(mockAuthService.signUpCallCount, 1)
        XCTAssertEqual(mockAuthService.capturedSignUpEmail, "john@example.com")
        XCTAssertEqual(mockAuthService.capturedSignUpPassword, "Password123")
        XCTAssertEqual(mockAuthService.capturedSignUpFirstName, "John")
        XCTAssertEqual(mockAuthService.capturedSignUpLastName, "Doe")
    }
    
    func test_signUp_withValidData_setsIsLoadingToFalse() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Sign Up Failure Tests
    
    func test_signUp_withUserAlreadyExists_setsErrorMessage() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "existing@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        mockAuthService.shouldReturnUserAlreadyExists = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "An account with this email already exists")
        XCTAssertFalse(sut.showConfirmation)
    }
    
    func test_signUp_withWeakPassword_setsErrorMessage() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        mockAuthService.shouldSucceed = false
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func test_signUp_withNetworkError_setsErrorMessage() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        mockAuthService.shouldReturnNetworkError = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Network error. Please check your connection.")
    }
    
    // MARK: - Confirm Sign Up Tests
    
    func test_confirmSignUp_withValidCode_setsIsSignedUpToTrue() async {
        // Given
        sut.email = "john@example.com"
        mockAuthService.shouldSucceed = true
        
        // When
        await sut.confirmSignUp(code: "123456")
        
        // Then
        XCTAssertTrue(sut.isSignedUp)
        XCTAssertFalse(sut.showConfirmation)
    }
    
    func test_confirmSignUp_withValidCode_callsAuthService() async {
        // Given
        sut.email = "john@example.com"
        
        // When
        await sut.confirmSignUp(code: "123456")
        
        // Then
        XCTAssertEqual(mockAuthService.confirmSignUpCallCount, 1)
        XCTAssertEqual(mockAuthService.capturedSignUpEmail, "john@example.com")
        XCTAssertEqual(mockAuthService.capturedConfirmationCode, "123456")
    }
    
    func test_confirmSignUp_withShortCode_setsErrorMessage() async {
        // When
        await sut.confirmSignUp(code: "12345")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter a valid 6-digit code")
        XCTAssertFalse(sut.isSignedUp)
    }
    
    func test_confirmSignUp_withLongCode_setsErrorMessage() async {
        // When
        await sut.confirmSignUp(code: "1234567")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Please enter a valid 6-digit code")
        XCTAssertFalse(sut.isSignedUp)
    }
    
    func test_confirmSignUp_withInvalidCode_setsErrorMessage() async {
        // Given
        sut.email = "john@example.com"
        mockAuthService.shouldSucceed = false
        
        // When
        await sut.confirmSignUp(code: "123456")
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Invalid confirmation code. Please try again.")
    }
    
    // MARK: - Resend Confirmation Code Tests
    
    func test_resendConfirmationCode_callsAuthService() async {
        // Given
        sut.email = "john@example.com"
        
        // When
        await sut.resendConfirmationCode()
        
        // Then
        XCTAssertEqual(mockAuthService.resendConfirmationCodeCallCount, 1)
        XCTAssertEqual(mockAuthService.capturedSignUpEmail, "john@example.com")
    }
    
    func test_resendConfirmationCode_withNetworkError_setsErrorMessage() async {
        // Given
        sut.email = "john@example.com"
        mockAuthService.shouldReturnNetworkError = true
        
        // When
        await sut.resendConfirmationCode()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to resend code")
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
    
    func test_resetForm_clearsAllFields() {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        sut.errorMessage = "Some error"
        sut.isLoading = true
        
        // When
        sut.resetForm()
        
        // Then
        XCTAssertEqual(sut.firstName, "")
        XCTAssertEqual(sut.lastName, "")
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
        XCTAssertEqual(sut.confirmPassword, "")
        XCTAssertFalse(sut.acceptedTerms)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    // MARK: - Loading State Tests
    
    func test_signUp_togglesLoadingState() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        
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
            await sut.signUp()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
    
    // MARK: - Edge Case Tests
    
    func test_signUp_withEmptyFirstName_doesNotCallAuthService() async {
        // Given
        sut.firstName = ""
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(mockAuthService.signUpCallCount, 0)
    }
    
    func test_signUp_withEmptyLastName_doesNotCallAuthService() async {
        // Given
        sut.firstName = "John"
        sut.lastName = ""
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "Password123"
        sut.acceptedTerms = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(mockAuthService.signUpCallCount, 0)
    }
    
    func test_signUp_withMismatchedPasswords_doesNotCallAuthService() async {
        // Given
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.email = "john@example.com"
        sut.password = "Password123"
        sut.confirmPassword = "DifferentPassword"
        sut.acceptedTerms = true
        
        // When
        await sut.signUp()
        
        // Then
        XCTAssertEqual(mockAuthService.signUpCallCount, 0)
    }
    
    // MARK: - Boundary Condition Tests
    
    func test_passwordValidation_withExactly8CharactersAndAllRequirements_isValid() {
        sut.password = "Pass1234"
        XCTAssertTrue(sut.isPasswordValid)
    }
    
    func test_passwordValidation_with7Characters_isInvalid() {
        sut.password = "Pass123"
        XCTAssertFalse(sut.isPasswordValid)
    }
    
    func test_confirmSignUp_withExactly6Digits_isValid() async {
        // Given
        sut.email = "john@example.com"
        mockAuthService.shouldSucceed = true
        
        // When
        await sut.confirmSignUp(code: "123456")
        
        // Then
        XCTAssertTrue(sut.isSignedUp)
    }
}

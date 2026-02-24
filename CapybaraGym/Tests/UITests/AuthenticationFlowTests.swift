// MARK: - Authentication Flow UI Tests
// Comprehensive UI tests for authentication flows following TDD principles

import XCTest

// MARK: - Authentication Flow Tests
/// UI tests covering complete authentication user journeys
final class AuthenticationFlowTests: XCTestCase {
    
    // MARK: - Properties
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure app for testing
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }
    
    // MARK: - Sign In Flow Tests
    
    /// Test: User can successfully sign in with valid credentials
    func test_signIn_withValidCredentials_navigatesToHome() {
        // Given - On Sign In screen
        XCTAssertTrue(app.staticTexts["Sign In"].exists)
        
        // When - Enter valid credentials
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        emailField.tap()
        emailField.typeText("test@capybaragym.com")
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        // Then - Sign in button should be enabled
        XCTAssertTrue(signInButton.isEnabled)
        
        // When - Tap sign in
        signInButton.tap()
        
        // Then - Should navigate to Home
        let homeExists = app.staticTexts["Welcome back"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(homeExists)
    }
    
    /// Test: Sign in button disabled with empty fields
    func test_signIn_withEmptyFields_buttonDisabled() {
        // Given - On Sign In screen
        let signInButton = app.buttons["Sign In"]
        
        // Then - Sign in button should be disabled initially
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    /// Test: Sign in button disabled with invalid email
    func test_signIn_withInvalidEmail_buttonDisabled() {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Enter invalid email but valid password
        emailField.tap()
        emailField.typeText("invalidemail")
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        // Then - Sign in button should be disabled
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    /// Test: Sign in button disabled with short password
    func test_signIn_withShortPassword_buttonDisabled() {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Enter valid email but short password
        emailField.tap()
        emailField.typeText("test@capybaragym.com")
        
        passwordField.tap()
        passwordField.typeText("short")
        
        // Then - Sign in button should be disabled
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    /// Test: Error message displayed for invalid credentials
    func test_signIn_withInvalidCredentials_showsError() {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Enter invalid credentials
        emailField.tap()
        emailField.typeText("wrong@email.com")
        
        passwordField.tap()
        passwordField.typeText("WrongPassword123")
        
        signInButton.tap()
        
        // Then - Error message should appear
        let errorExists = app.staticTexts["Invalid email or password"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(errorExists)
    }
    
    /// Test: Loading indicator shown during sign in
    func test_signIn_showsLoadingIndicator() {
        // Given
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let signInButton = app.buttons["Sign In"]
        
        // When - Enter credentials and tap sign in
        emailField.tap()
        emailField.typeText("test@capybaragym.com")
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        signInButton.tap()
        
        // Then - Loading indicator should appear
        let progressView = app.progressIndicators.firstMatch
        XCTAssertTrue(progressView.exists)
    }
    
    /// Test: Navigate to sign up from sign in
    func test_signIn_navigateToSignUp() {
        // Given - On Sign In screen
        let signUpLink = app.buttons["Don't have an account? Sign Up"]
        
        // When - Tap sign up link
        signUpLink.tap()
        
        // Then - Should navigate to Sign Up screen
        XCTAssertTrue(app.staticTexts["Create Account"].waitForExistence(timeout: 2.0))
    }
    
    /// Test: Navigate to forgot password
    func test_signIn_navigateToForgotPassword() {
        // Given - On Sign In screen
        let forgotPasswordLink = app.buttons["Forgot Password?"]
        
        // When - Tap forgot password link
        forgotPasswordLink.tap()
        
        // Then - Should show forgot password sheet
        XCTAssertTrue(app.staticTexts["Reset Password"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Sign Up Flow Tests
    
    /// Test: User can successfully sign up with valid data
    func test_signUp_withValidData_showsConfirmation() {
        // Given - Navigate to Sign Up
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // When - Fill in valid data
        let firstNameField = app.textFields["First Name"]
        let lastNameField = app.textFields["Last Name"]
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        let termsToggle = app.switches["I agree to the Terms of Service"]
        let signUpButton = app.buttons["Sign Up"]
        
        firstNameField.tap()
        firstNameField.typeText("John")
        
        lastNameField.tap()
        lastNameField.typeText("Doe")
        
        emailField.tap()
        emailField.typeText("newuser@capybaragym.com")
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("Password123")
        
        termsToggle.tap()
        
        // Then - Sign up button should be enabled
        XCTAssertTrue(signUpButton.isEnabled)
        
        // When - Tap sign up
        signUpButton.tap()
        
        // Then - Should show confirmation screen
        let confirmationExists = app.staticTexts["Verify Your Email"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(confirmationExists)
    }
    
    /// Test: Sign up button disabled with empty fields
    func test_signUp_withEmptyFields_buttonDisabled() {
        // Given - Navigate to Sign Up
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // Then - Sign up button should be disabled
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertFalse(signUpButton.isEnabled)
    }
    
    /// Test: Sign up button disabled without accepting terms
    func test_signUp_withoutAcceptingTerms_buttonDisabled() {
        // Given - Navigate to Sign Up
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // When - Fill in all fields but don't accept terms
        let firstNameField = app.textFields["First Name"]
        let lastNameField = app.textFields["Last Name"]
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        
        firstNameField.tap()
        firstNameField.typeText("John")
        
        lastNameField.tap()
        lastNameField.typeText("Doe")
        
        emailField.tap()
        emailField.typeText("john@example.com")
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("Password123")
        
        // Then - Sign up button should still be disabled
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertFalse(signUpButton.isEnabled)
    }
    
    /// Test: Error shown for mismatched passwords
    func test_signUp_withMismatchedPasswords_showsError() {
        // Given - Navigate to Sign Up
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // When - Enter mismatched passwords
        let passwordField = app.secureTextFields["Password"]
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        
        passwordField.tap()
        passwordField.typeText("Password123")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("DifferentPassword")
        
        // Then - Passwords don't match indicator should appear
        XCTAssertTrue(app.images["xmark.circle"].exists)
    }
    
    /// Test: Password strength indicator shown
    func test_signUp_showsPasswordStrengthIndicator() {
        // Given - Navigate to Sign Up
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // When - Enter weak password
        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("weak")
        
        // Then - Weak password indicator should appear
        XCTAssertTrue(app.staticTexts["Weak"].exists)
        
        // When - Enter medium password
        passwordField.clearAndEnterText(text: "password")
        
        // Then - Medium password indicator should appear
        XCTAssertTrue(app.staticTexts["Medium"].exists)
        
        // When - Enter strong password
        passwordField.clearAndEnterText(text: "Password123")
        
        // Then - Strong password indicator should appear
        XCTAssertTrue(app.staticTexts["Strong"].exists)
    }
    
    /// Test: Navigate back to sign in from sign up
    func test_signUp_navigateBackToSignIn() {
        // Given - On Sign Up screen
        app.buttons["Don't have an account? Sign Up"].tap()
        
        // When - Tap back button
        app.buttons["Back"].tap()
        
        // Then - Should be back on Sign In screen
        XCTAssertTrue(app.staticTexts["Sign In"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Email Confirmation Flow Tests
    
    /// Test: User can confirm email with valid code
    func test_confirmEmail_withValidCode_completesSignUp() {
        // Given - User has signed up and is on confirmation screen
        navigateToConfirmationScreen()
        
        // When - Enter valid confirmation code
        let codeFields = app.textFields.matching(identifier: "CodeDigit")
        for i in 0..<6 {
            let field = codeFields.element(boundBy: i)
            field.tap()
            field.typeText("\(i + 1)")
        }
        
        let verifyButton = app.buttons["Verify"]
        verifyButton.tap()
        
        // Then - Should navigate to Home
        let homeExists = app.staticTexts["Welcome back"].waitForExistence(timeout: 5.0)
        XCTAssertTrue(homeExists)
    }
    
    /// Test: Resend confirmation code
    func test_confirmEmail_resendCode() {
        // Given - On confirmation screen
        navigateToConfirmationScreen()
        
        // When - Tap resend code button
        let resendButton = app.buttons["Resend Code"]
        resendButton.tap()
        
        // Then - Success message should appear
        let successExists = app.staticTexts["Code sent successfully"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(successExists)
    }
    
    /// Test: Invalid confirmation code shows error
    func test_confirmEmail_withInvalidCode_showsError() {
        // Given - On confirmation screen
        navigateToConfirmationScreen()
        
        // When - Enter invalid code
        let codeFields = app.textFields.matching(identifier: "CodeDigit")
        for i in 0..<6 {
            let field = codeFields.element(boundBy: i)
            field.tap()
            field.typeText("9")
        }
        
        let verifyButton = app.buttons["Verify"]
        verifyButton.tap()
        
        // Then - Error message should appear
        let errorExists = app.staticTexts["Invalid confirmation code"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(errorExists)
    }
    
    // MARK: - Forgot Password Flow Tests
    
    /// Test: User can request password reset
    func test_forgotPassword_withValidEmail_showsSuccess() {
        // Given - On Sign In screen
        app.buttons["Forgot Password?"].tap()
        
        // When - Enter valid email
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test@capybaragym.com")
        
        let resetButton = app.buttons["Send Reset Link"]
        resetButton.tap()
        
        // Then - Success message should appear
        let successExists = app.staticTexts["Check your email for reset instructions"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(successExists)
    }
    
    /// Test: Invalid email shows error
    func test_forgotPassword_withInvalidEmail_showsError() {
        // Given - On forgot password screen
        app.buttons["Forgot Password?"].tap()
        
        // When - Enter invalid email
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("invalidemail")
        
        let resetButton = app.buttons["Send Reset Link"]
        resetButton.tap()
        
        // Then - Error message should appear
        let errorExists = app.staticTexts["Please enter a valid email"].waitForExistence(timeout: 3.0)
        XCTAssertTrue(errorExists)
    }
    
    /// Test: Cancel forgot password
    func test_forgotPassword_cancel_dismissesSheet() {
        // Given - On forgot password sheet
        app.buttons["Forgot Password?"].tap()
        
        // When - Tap cancel button
        app.buttons["Cancel"].tap()
        
        // Then - Sheet should be dismissed
        let sheetGone = !app.staticTexts["Reset Password"].waitForExistence(timeout: 2.0)
        XCTAssertTrue(sheetGone)
    }
    
    // MARK: - Social Sign In Tests
    
    /// Test: Sign in with Apple button exists
    func test_signIn_withAppleButtonExists() {
        // Given - On Sign In screen
        let appleButton = app.buttons["Sign in with Apple"]
        
        // Then - Button should exist
        XCTAssertTrue(appleButton.exists)
    }
    
    /// Test: Sign in with Google button exists
    func test_signIn_withGoogleButtonExists() {
        // Given - On Sign In screen
        let googleButton = app.buttons["Sign in with Google"]
        
        // Then - Button should exist
        XCTAssertTrue(googleButton.exists)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToConfirmationScreen() {
        // Navigate through sign up to reach confirmation screen
        app.buttons["Don't have an account? Sign Up"].tap()
        
        app.textFields["First Name"].tap()
        app.textFields["First Name"].typeText("John")
        
        app.textFields["Last Name"].tap()
        app.textFields["Last Name"].typeText("Doe")
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("newuser@capybaragym.com")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("Password123")
        
        app.secureTextFields["Confirm Password"].tap()
        app.secureTextFields["Confirm Password"].typeText("Password123")
        
        app.switches["I agree to the Terms of Service"].tap()
        
        app.buttons["Sign Up"].tap()
        
        // Wait for confirmation screen
        _ = app.staticTexts["Verify Your Email"].waitForExistence(timeout: 5.0)
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearAndEnterText(text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}

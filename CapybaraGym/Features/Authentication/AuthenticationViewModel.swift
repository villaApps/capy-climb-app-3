//
//  AuthenticationViewModel.swift
//  CapybaraGym
//
//  Authentication ViewModel
//

import SwiftUI
import Combine

@MainActor
public final class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var email = ""
    @Published public var password = ""
    @Published public var confirmPassword = ""
    @Published public var firstName = ""
    @Published public var lastName = ""
    @Published public var phoneNumber = ""
    @Published public var confirmationCode = ""
    
    @Published public var viewState: ViewState<AuthUser> = .idle
    @Published public var formState = FormState()
    
    @Published public var isEmailValid = false
    @Published public var isPasswordValid = false
    @Published public var doPasswordsMatch = false
    
    // MARK: - Computed Properties
    public var isSignInValid: Bool {
        isEmailValid && isPasswordValid
    }
    
    public var isSignUpValid: Bool {
        isEmailValid && isPasswordValid && doPasswordsMatch &&
        !firstName.isEmpty && !lastName.isEmpty
    }
    
    public var currentUser: AuthUser? {
        authService.currentUser
    }
    
    public var isAuthenticated: Bool {
        authService.isAuthenticated
    }
    
    // MARK: - Private Properties
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init() {
        setupValidation()
    }
    
    // MARK: - Public Methods
    
    public func signIn() async {
        guard validateSignIn() else { return }
        
        viewState = .loading
        formState.setSubmitting(true)
        
        do {
            let user = try await authService.signIn(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            viewState = .success(user)
            clearForm()
        } catch let error as AuthError {
            viewState = .error(error)
            formState.setGeneralError(error.localizedDescription)
        } catch {
            viewState = .error(AuthError.unknown(error))
            formState.setGeneralError(error.localizedDescription)
        }
        
        formState.setSubmitting(false)
    }
    
    public func signUp() async {
        guard validateSignUp() else { return }
        
        viewState = .loading
        formState.setSubmitting(true)
        
        let attributes: [String: String] = [
            "given_name": firstName,
            "family_name": lastName,
            "phone_number": phoneNumber
        ]
        
        do {
            let user = try await authService.signUp(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                attributes: attributes
            )
            viewState = .success(user)
        } catch let error as AuthError {
            viewState = .error(error)
            formState.setGeneralError(error.localizedDescription)
        } catch {
            viewState = .error(AuthError.unknown(error))
            formState.setGeneralError(error.localizedDescription)
        }
        
        formState.setSubmitting(false)
    }
    
    public func confirmSignUp() async {
        guard confirmationCode.count == ValidationConstants.verificationCodeLength else {
            formState.setFieldError("Please enter a valid 6-digit code", for: "confirmationCode")
            return
        }
        
        viewState = .loading
        formState.setSubmitting(true)
        
        do {
            try await authService.confirmSignUp(
                email: email.trimmingCharacters(in: .whitespaces),
                confirmationCode: confirmationCode
            )
            // Auto sign in after confirmation
            let user = try await authService.signIn(email: email, password: password)
            viewState = .success(user)
            clearForm()
        } catch let error as AuthError {
            viewState = .error(error)
            formState.setGeneralError(error.localizedDescription)
        } catch {
            viewState = .error(AuthError.unknown(error))
            formState.setGeneralError(error.localizedDescription)
        }
        
        formState.setSubmitting(false)
    }
    
    public func resendConfirmationCode() async {
        do {
            try await authService.resendConfirmationCode(
                email: email.trimmingCharacters(in: .whitespaces)
            )
        } catch {
            formState.setGeneralError(error.localizedDescription)
        }
    }
    
    public func signOut() async {
        do {
            try await authService.signOut()
            viewState = .idle
        } catch {
            formState.setGeneralError(error.localizedDescription)
        }
    }
    
    public func resetPassword() async {
        guard isEmailValid else {
            formState.setFieldError("Please enter a valid email", for: "email")
            return
        }
        
        do {
            try await authService.resetPassword(
                email: email.trimmingCharacters(in: .whitespaces)
            )
        } catch let error as AuthError {
            formState.setGeneralError(error.localizedDescription)
        } catch {
            formState.setGeneralError(error.localizedDescription)
        }
    }
    
    public func confirmResetPassword(code: String, newPassword: String) async {
        do {
            try await authService.confirmResetPassword(
                email: email.trimmingCharacters(in: .whitespaces),
                newPassword: newPassword,
                confirmationCode: code
            )
        } catch let error as AuthError {
            formState.setGeneralError(error.localizedDescription)
        } catch {
            formState.setGeneralError(error.localizedDescription)
        }
    }
    
    public func updateProfile(firstName: String, lastName: String, phoneNumber: String) async {
        let attributes: [String: String] = [
            "given_name": firstName,
            "family_name": lastName,
            "phone_number": phoneNumber
        ]
        
        do {
            _ = try await authService.updateUserAttributes(attributes: attributes)
        } catch {
            formState.setGeneralError(error.localizedDescription)
        }
    }
    
    public func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
        phoneNumber = ""
        confirmationCode = ""
        formState.reset()
    }
    
    public func clearError() {
        viewState = .idle
        formState.reset()
    }
    
    // MARK: - Private Methods
    
    private func setupValidation() {
        $email
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isValidEmail }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        $password
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isValidPassword }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
        
        Publishers.CombineLatest($password, $confirmPassword)
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .map { password, confirm in
                !confirm.isEmpty && password == confirm
            }
            .assign(to: \.doPasswordsMatch, on: self)
            .store(in: &cancellables)
    }
    
    private func validateSignIn() -> Bool {
        formState.reset()
        
        if !isEmailValid {
            formState.setFieldError("Please enter a valid email", for: "email")
        }
        
        if password.isEmpty {
            formState.setFieldError("Please enter your password", for: "password")
        }
        
        formState.validate()
        return formState.isValid
    }
    
    private func validateSignUp() -> Bool {
        formState.reset()
        
        if !isEmailValid {
            formState.setFieldError("Please enter a valid email", for: "email")
        }
        
        if !isPasswordValid {
            formState.setFieldError("Password must be at least 8 characters with uppercase, lowercase, and number", for: "password")
        }
        
        if !doPasswordsMatch {
            formState.setFieldError("Passwords do not match", for: "confirmPassword")
        }
        
        if firstName.isEmpty {
            formState.setFieldError("Please enter your first name", for: "firstName")
        }
        
        if lastName.isEmpty {
            formState.setFieldError("Please enter your last name", for: "lastName")
        }
        
        formState.validate()
        return formState.isValid
    }
}

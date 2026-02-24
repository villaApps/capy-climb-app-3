import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AuthenticationServices

/**
 * GymPass App - Authentication Service
 * 
 * Handles all authentication operations:
 * - Email/Password sign up, sign in, sign out
 * - Apple Sign In
 * - Google Sign In
 * - MFA
 * - Password reset
 */

@MainActor
public final class AuthService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var isAuthenticated: Bool = false
    @Published public var currentUser: AuthUser?
    @Published public var userAttributes: [AuthUserAttribute]?
    @Published public var isLoading: Bool = false
    @Published public var error: AuthError?
    
    // MARK: - Singleton
    
    public static let shared = AuthService()
    
    private init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Auth Status
    
    /// Check current authentication status
    public func checkAuthStatus() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            isAuthenticated = session.isSignedIn
            if session.isSignedIn {
                currentUser = try? await Amplify.Auth.getCurrentUser()
                await fetchUserAttributes()
            }
        } catch {
            self.error = error as? AuthError
            isAuthenticated = false
        }
    }
    
    // MARK: - Email/Password Authentication
    
    /// Sign up with email and password
    public func signUp(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phoneNumber: String? = nil
    ) async -> Result<AuthSignUpResult, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        let attributes = buildUserAttributes(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )
        
        let options = AuthSignUpRequest.Options(
            userAttributes: attributes
        )
        
        do {
            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Sign up failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Confirm sign up with verification code
    public func confirmSignUp(
        email: String,
        confirmationCode: String
    ) async -> Result<AuthSignUpResult, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: confirmationCode
            )
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Confirmation failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Resend confirmation code
    public func resendConfirmationCode(email: String) async -> Result<AuthCodeDeliveryDetails, AuthError> {
        do {
            let result = try await Amplify.Auth.resendSignUpCode(for: email)
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Resend code failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Sign in with email and password
    public func signIn(email: String, password: String) async -> Result<AuthSignInResult, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Amplify.Auth.signIn(
                username: email,
                password: password
            )
            
            if result.isSignedIn {
                isAuthenticated = true
                currentUser = try? await Amplify.Auth.getCurrentUser()
                await fetchUserAttributes()
            }
            
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Sign in failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Sign out
    public func signOut() async {
        isLoading = true
        defer { isLoading = false }
        
        let result = await Amplify.Auth.signOut()
        
        if let signOutResult = result as? AWSCognitoSignOutResult {
            switch signOutResult {
            case .complete:
                isAuthenticated = false
                currentUser = nil
                userAttributes = nil
            case .partial(_, let error):
                self.error = error
            case .failed(let error):
                self.error = error
            }
        }
    }
    
    // MARK: - Social Sign In
    
    /// Sign in with Apple
    public func signInWithApple(presentationAnchor: ASPresentationAnchor) async -> Result<AuthSignInResult, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Amplify.Auth.signInWithWebUI(
                for: .apple,
                presentationAnchor: presentationAnchor
            )
            
            if result.isSignedIn {
                isAuthenticated = true
                currentUser = try? await Amplify.Auth.getCurrentUser()
                await fetchUserAttributes()
            }
            
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Apple sign in failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Sign in with Google
    public func signInWithGoogle(presentationAnchor: ASPresentationAnchor) async -> Result<AuthSignInResult, AuthError> {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Amplify.Auth.signInWithWebUI(
                for: .google,
                presentationAnchor: presentationAnchor
            )
            
            if result.isSignedIn {
                isAuthenticated = true
                currentUser = try? await Amplify.Auth.getCurrentUser()
                await fetchUserAttributes()
            }
            
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Google sign in failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Password Management
    
    /// Request password reset
    public func resetPassword(email: String) async -> Result<AuthResetPasswordResult, AuthError> {
        do {
            let result = try await Amplify.Auth.resetPassword(for: email)
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Reset password failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Confirm password reset with code
    public func confirmResetPassword(
        email: String,
        newPassword: String,
        confirmationCode: String
    ) async -> Result<Void, AuthError> {
        do {
            try await Amplify.Auth.confirmResetPassword(
                for: email,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            return .success(())
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Confirm reset password failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Change password (for signed in users)
    public func changePassword(oldPassword: String, newPassword: String) async -> Result<Void, AuthError> {
        do {
            try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
            return .success(())
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Change password failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    // MARK: - User Attributes
    
    /// Fetch current user attributes
    public func fetchUserAttributes() async {
        do {
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            self.userAttributes = attributes
        } catch {
            self.error = error as? AuthError
        }
    }
    
    /// Update user attributes
    public func updateUserAttributes(_ attributes: [AuthUserAttribute]) async -> Result<[AuthUpdateAttributeResult], AuthError> {
        do {
            let result = try await Amplify.Auth.update(userAttributes: attributes)
            await fetchUserAttributes()
            return .success(result)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("Update attributes failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    // MARK: - MFA
    
    /// Setup TOTP MFA
    public func setupTOTP() async -> Result<TOTPSetupDetails, AuthError> {
        do {
            let details = try await Amplify.Auth.setUpTOTP()
            return .success(details)
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("TOTP setup failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    /// Verify TOTP setup
    public func verifyTOTPSetup(code: String) async -> Result<Void, AuthError> {
        do {
            try await Amplify.Auth.verifyTOTPSetup(with: code)
            return .success(())
        } catch let error as AuthError {
            self.error = error
            return .failure(error)
        } catch {
            let authError = AuthError.unknown("TOTP verification failed", error)
            self.error = authError
            return .failure(authError)
        }
    }
    
    // MARK: - Private Helpers
    
    private func buildUserAttributes(
        email: String,
        firstName: String,
        lastName: String,
        phoneNumber: String?
    ) -> [AuthUserAttribute] {
        var attributes: [AuthUserAttribute] = [
            AuthUserAttribute(.email, value: email),
            AuthUserAttribute(.givenName, value: firstName),
            AuthUserAttribute(.familyName, value: lastName),
        ]
        
        if let phone = phoneNumber {
            attributes.append(AuthUserAttribute(.phoneNumber, value: phone))
        }
        
        return attributes
    }
}

// MARK: - Convenience Extensions

extension AuthService {
    
    /// Get current user ID
    public var currentUserId: String? {
        currentUser?.userId
    }
    
    /// Get user's email
    public var userEmail: String? {
        userAttributes?.first { $0.key == .email }?.value
    }
    
    /// Get user's full name
    public var userFullName: String? {
        let firstName = userAttributes?.first { $0.key == .givenName }?.value ?? ""
        let lastName = userAttributes?.first { $0.key == .familyName }?.value ?? ""
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
}

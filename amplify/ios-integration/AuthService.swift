//
//  AuthService.swift
//  Capybara Wellness
//
//  Authentication service using AWS Cognito
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AuthenticationServices

/// Authentication service for user management
@MainActor
class AuthService: ObservableObject {
    
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var userAttributes: [AuthUserAttribute]?
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Authentication Status
    
    private func checkAuthStatus() {
        Task {
            do {
                let session = try await Amplify.Auth.fetchAuthSession()
                self.isAuthenticated = session.isSignedIn
                if session.isSignedIn {
                    self.currentUser = try await Amplify.Auth.getCurrentUser()
                    await fetchUserAttributes()
                }
            } catch {
                print("Auth status check failed: \(error)")
            }
        }
    }
    
    // MARK: - Email/Password Authentication
    
    /// Sign up with email and password
    func signUp(
        email: String,
        password: String,
        displayName: String,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws -> AuthSignUpResult {
        let attributes: [AuthUserAttribute] = [
            .init(.email, value: email),
            .init(.preferredUsername, value: displayName)
        ]
        
        if let firstName = firstName {
            attributes.append(.init(.givenName, value: firstName))
        }
        if let lastName = lastName {
            attributes.append(.init(.familyName, value: lastName))
        }
        
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        
        let result = try await Amplify.Auth.signUp(
            username: email,
            password: password,
            options: options
        )
        
        return result
    }
    
    /// Confirm sign up with verification code
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        _ = try await Amplify.Auth.confirmSignUp(
            for: email,
            confirmationCode: confirmationCode
        )
    }
    
    /// Resend confirmation code
    func resendConfirmationCode(email: String) async throws {
        _ = try await Amplify.Auth.resendSignUpCode(for: email)
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        let result = try await Amplify.Auth.signIn(
            username: email,
            password: password
        )
        
        if result.isSignedIn {
            self.isAuthenticated = true
            self.currentUser = try await Amplify.Auth.getCurrentUser()
            await fetchUserAttributes()
        }
    }
    
    /// Sign out
    func signOut() async throws {
        let result = await Amplify.Auth.signOut()
        
        if let signOutResult = result as? AWSCognitoSignOutResult {
            switch signOutResult {
            case .complete:
                self.isAuthenticated = false
                self.currentUser = nil
                self.userAttributes = nil
            case .partial(_, let error):
                throw error ?? AuthError.unknown("Partial sign out")
            case .failed(let error):
                throw error
            }
        }
    }
    
    // MARK: - Social Authentication
    
    /// Sign in with Apple
    func signInWithApple(presentationAnchor: ASPresentationAnchor) async throws {
        let result = try await Amplify.Auth.signInWithWebUI(
            for: .apple,
            presentationAnchor: presentationAnchor
        )
        
        if result.isSignedIn {
            self.isAuthenticated = true
            self.currentUser = try await Amplify.Auth.getCurrentUser()
            await fetchUserAttributes()
        }
    }
    
    /// Sign in with Google
    func signInWithGoogle(presentationAnchor: ASPresentationAnchor) async throws {
        let result = try await Amplify.Auth.signInWithWebUI(
            for: .google,
            presentationAnchor: presentationAnchor
        )
        
        if result.isSignedIn {
            self.isAuthenticated = true
            self.currentUser = try await Amplify.Auth.getCurrentUser()
            await fetchUserAttributes()
        }
    }
    
    // MARK: - Password Recovery
    
    /// Request password reset
    func resetPassword(email: String) async throws {
        _ = try await Amplify.Auth.resetPassword(for: email)
    }
    
    /// Confirm password reset with code
    func confirmResetPassword(
        email: String,
        newPassword: String,
        confirmationCode: String
    ) async throws {
        _ = try await Amplify.Auth.confirmResetPassword(
            for: email,
            with: newPassword,
            confirmationCode: confirmationCode
        )
    }
    
    // MARK: - Multi-Factor Authentication
    
    /// Set up SMS MFA
    func setupSMSMFA(phoneNumber: String) async throws {
        _ = try await Amplify.Auth.update(
            userAttribute: AuthUserAttribute(.phoneNumber, value: phoneNumber)
        )
    }
    
    /// Verify SMS MFA code
    func verifySMSMFA(code: String) async throws {
        _ = try await Amplify.Auth.confirmVerify(
            userAttribute: .phoneNumber,
            confirmationCode: code
        )
    }
    
    // MARK: - User Attributes
    
    /// Fetch current user attributes
    func fetchUserAttributes() async {
        do {
            self.userAttributes = try await Amplify.Auth.fetchUserAttributes()
        } catch {
            print("Failed to fetch user attributes: \(error)")
        }
    }
    
    /// Update user attributes
    func updateUserAttributes(attributes: [AuthUserAttribute]) async throws {
        _ = try await Amplify.Auth.update(userAttributes: attributes)
        await fetchUserAttributes()
    }
    
    /// Update single attribute
    func updateAttribute(_ key: AuthUserAttributeKey, value: String) async throws {
        _ = try await Amplify.Auth.update(
            userAttribute: AuthUserAttribute(key, value: value)
        )
        await fetchUserAttributes()
    }
    
    // MARK: - Helper Methods
    
    /// Get attribute value by key
    func getAttribute(_ key: AuthUserAttributeKey) -> String? {
        return userAttributes?.first { $0.key == key }?.value
    }
    
    /// Check if email is verified
    var isEmailVerified: Bool {
        getAttribute(.emailVerified) == "true"
    }
}

// MARK: - Mock Auth Service
// Comprehensive mock for AuthService to enable isolated unit testing

import Foundation
import Combine
@testable import CapybaraGym

// MARK: - Auth Service Protocol
/// Protocol defining authentication service operations
public protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    var authStatePublisher: AnyPublisher<AuthState, Never> { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws -> User
    func signOut() async throws
    func confirmSignUp(email: String, confirmationCode: String) async throws
    func resendConfirmationCode(email: String) async throws
    func forgotPassword(email: String) async throws
    func confirmForgotPassword(email: String, newPassword: String, confirmationCode: String) async throws
    func refreshSession() async throws
    func getCurrentUser() async -> User?
}

// MARK: - Auth State
public enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(AuthError)
}

// MARK: - Auth Error
public enum AuthError: Error, Equatable {
    case invalidCredentials
    case userNotFound
    case userAlreadyExists
    case invalidConfirmationCode
    case passwordTooWeak
    case networkError
    case sessionExpired
    case unknown(String)
    
    public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials),
             (.userNotFound, .userNotFound),
             (.userAlreadyExists, .userAlreadyExists),
             (.invalidConfirmationCode, .invalidConfirmationCode),
             (.passwordTooWeak, .passwordTooWeak),
             (.networkError, .networkError),
             (.sessionExpired, .sessionExpired):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

// MARK: - Mock Auth Service
public final class MockAuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    @Published private var authState: AuthState = .unauthenticated
    public var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }
    
    public var currentUser: User?
    public var isAuthenticated: Bool {
        currentUser != nil
    }
    
    // MARK: - Configuration
    public var shouldSucceed = true
    public var shouldReturnUserNotFound = false
    public var shouldReturnInvalidCredentials = false
    public var shouldReturnUserAlreadyExists = false
    public var shouldReturnNetworkError = false
    public var shouldReturnSessionExpired = false
    public var delay: TimeInterval = 0.1
    
    // MARK: - Call Tracking
    public var signInCallCount = 0
    public var signUpCallCount = 0
    public var signOutCallCount = 0
    public var confirmSignUpCallCount = 0
    public var resendConfirmationCodeCallCount = 0
    public var forgotPasswordCallCount = 0
    public var confirmForgotPasswordCallCount = 0
    public var refreshSessionCallCount = 0
    public var getCurrentUserCallCount = 0
    
    // MARK: - Captured Parameters
    public var capturedSignInEmail: String?
    public var capturedSignInPassword: String?
    public var capturedSignUpEmail: String?
    public var capturedSignUpPassword: String?
    public var capturedSignUpFirstName: String?
    public var capturedSignUpLastName: String?
    public var capturedConfirmationCode: String?
    public var capturedForgotPasswordEmail: String?
    
    // MARK: - Test Data
    public var mockUser = User(
        id: "test-user-id",
        email: "test@capybaragym.com",
        firstName: "Test",
        lastName: "User",
        profileImageUrl: nil,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - AuthServiceProtocol Implementation
    
    public func signIn(email: String, password: String) async throws -> User {
        signInCallCount += 1
        capturedSignInEmail = email
        capturedSignInPassword = password
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Validate inputs
        guard !email.isEmpty else {
            throw AuthError.invalidCredentials
        }
        guard !password.isEmpty else {
            throw AuthError.invalidCredentials
        }
        guard email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        // Return configured error
        if shouldReturnInvalidCredentials {
            authState = .error(.invalidCredentials)
            throw AuthError.invalidCredentials
        }
        
        if shouldReturnUserNotFound {
            authState = .error(.userNotFound)
            throw AuthError.userNotFound
        }
        
        if shouldReturnNetworkError {
            authState = .error(.networkError)
            throw AuthError.networkError
        }
        
        if shouldSucceed {
            currentUser = mockUser
            authState = .authenticated(mockUser)
            return mockUser
        }
        
        authState = .error(.unknown("Sign in failed"))
        throw AuthError.unknown("Sign in failed")
    }
    
    public func signUp(email: String, password: String, firstName: String, lastName: String) async throws -> User {
        signUpCallCount += 1
        capturedSignUpEmail = email
        capturedSignUpPassword = password
        capturedSignUpFirstName = firstName
        capturedSignUpLastName = lastName
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        // Validate inputs
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        guard password.count >= 8 else {
            throw AuthError.passwordTooWeak
        }
        guard !firstName.isEmpty, !lastName.isEmpty else {
            throw AuthError.unknown("Name fields required")
        }
        
        if shouldReturnUserAlreadyExists {
            authState = .error(.userAlreadyExists)
            throw AuthError.userAlreadyExists
        }
        
        if shouldReturnNetworkError {
            authState = .error(.networkError)
            throw AuthError.networkError
        }
        
        if shouldSucceed {
            let newUser = User(
                id: UUID().uuidString,
                email: email,
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            authState = .unauthenticated // Requires confirmation
            return newUser
        }
        
        throw AuthError.unknown("Sign up failed")
    }
    
    public func signOut() async throws {
        signOutCallCount += 1
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        if shouldReturnNetworkError {
            throw AuthError.networkError
        }
        
        if shouldSucceed {
            currentUser = nil
            authState = .unauthenticated
        }
    }
    
    public func confirmSignUp(email: String, confirmationCode: String) async throws {
        confirmSignUpCallCount += 1
        capturedSignUpEmail = email
        capturedConfirmationCode = confirmationCode
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard confirmationCode.count == 6 else {
            throw AuthError.invalidConfirmationCode
        }
        
        if shouldSucceed {
            currentUser = mockUser
            authState = .authenticated(mockUser)
        } else {
            throw AuthError.invalidConfirmationCode
        }
    }
    
    public func resendConfirmationCode(email: String) async throws {
        resendConfirmationCodeCallCount += 1
        capturedSignUpEmail = email
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        if shouldReturnNetworkError {
            throw AuthError.networkError
        }
        
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidCredentials
        }
    }
    
    public func forgotPassword(email: String) async throws {
        forgotPasswordCallCount += 1
        capturedForgotPasswordEmail = email
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        if shouldReturnUserNotFound {
            throw AuthError.userNotFound
        }
        
        if shouldReturnNetworkError {
            throw AuthError.networkError
        }
    }
    
    public func confirmForgotPassword(email: String, newPassword: String, confirmationCode: String) async throws {
        confirmForgotPasswordCallCount += 1
        
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooWeak
        }
        
        guard confirmationCode.count == 6 else {
            throw AuthError.invalidConfirmationCode
        }
        
        if shouldReturnInvalidCredentials {
            throw AuthError.invalidCredentials
        }
        
        if shouldReturnNetworkError {
            throw AuthError.networkError
        }
    }
    
    public func refreshSession() async throws {
        refreshSessionCallCount += 1
        
        try await Task.sleep(nanoseconds: UInt64(delay * 500_000_000))
        
        if shouldReturnSessionExpired {
            currentUser = nil
            authState = .unauthenticated
            throw AuthError.sessionExpired
        }
        
        if shouldReturnNetworkError {
            throw AuthError.networkError
        }
    }
    
    public func getCurrentUser() async -> User? {
        getCurrentUserCallCount += 1
        return currentUser
    }
    
    // MARK: - Helper Methods
    
    public func reset() {
        signInCallCount = 0
        signUpCallCount = 0
        signOutCallCount = 0
        confirmSignUpCallCount = 0
        resendConfirmationCodeCallCount = 0
        forgotPasswordCallCount = 0
        confirmForgotPasswordCallCount = 0
        refreshSessionCallCount = 0
        getCurrentUserCallCount = 0
        
        capturedSignInEmail = nil
        capturedSignInPassword = nil
        capturedSignUpEmail = nil
        capturedSignUpPassword = nil
        capturedSignUpFirstName = nil
        capturedSignUpLastName = nil
        capturedConfirmationCode = nil
        capturedForgotPasswordEmail = nil
        
        shouldSucceed = true
        shouldReturnUserNotFound = false
        shouldReturnInvalidCredentials = false
        shouldReturnUserAlreadyExists = false
        shouldReturnNetworkError = false
        shouldReturnSessionExpired = false
        
        currentUser = nil
        authState = .unauthenticated
    }
    
    public func simulateAuthenticatedUser() {
        currentUser = mockUser
        authState = .authenticated(mockUser)
    }
    
    public func simulateSessionExpired() {
        currentUser = nil
        authState = .error(.sessionExpired)
    }
}

// MARK: - User Model
public struct User: Equatable, Identifiable {
    public let id: String
    public let email: String
    public let firstName: String
    public let lastName: String
    public let profileImageUrl: String?
    public let createdAt: Date
    public let updatedAt: Date
    
    public var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    public init(id: String, email: String, firstName: String, lastName: String, 
                profileImageUrl: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

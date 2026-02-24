// MARK: - Auth Service Tests
// Comprehensive unit tests for AuthService following TDD principles

import XCTest
import Combine
@testable import CapybaraGym

// MARK: - AuthService
/// Production implementation of authentication service
@MainActor
final class AuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    @Published private var authState: AuthState = .unauthenticated
    var authStatePublisher: AnyPublisher<AuthState, Never> {
        $authState.eraseToAnyPublisher()
    }
    
    private(set) var currentUser: User?
    var isAuthenticated: Bool {
        currentUser != nil
    }
    
    // MARK: - Dependencies
    private let networkClient: NetworkClientProtocol
    private let keychainManager: KeychainManagerProtocol
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - Initialization
    init(
        networkClient: NetworkClientProtocol,
        keychainManager: KeychainManagerProtocol,
        tokenManager: TokenManagerProtocol
    ) {
        self.networkClient = networkClient
        self.keychainManager = keychainManager
        self.tokenManager = tokenManager
    }
    
    // MARK: - AuthServiceProtocol Implementation
    
    func signIn(email: String, password: String) async throws -> User {
        // Validate inputs
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            throw AuthError.invalidCredentials
        }
        guard password.count >= 8 else {
            throw AuthError.invalidCredentials
        }
        
        authState = .authenticating
        
        do {
            let request = SignInRequest(email: email, password: password)
            let response: AuthResponse = try await networkClient.post(
                endpoint: "/auth/signin",
                body: request
            )
            
            // Store tokens securely
            try keychainManager.save(response.accessToken, key: "accessToken")
            try keychainManager.save(response.refreshToken, key: "refreshToken")
            
            let user = response.user
            currentUser = user
            authState = .authenticated(user)
            
            return user
        } catch let error as NetworkError {
            authState = .error(mapNetworkError(error))
            throw mapNetworkError(error)
        } catch {
            authState = .error(.unknown(error.localizedDescription))
            throw AuthError.unknown(error.localizedDescription)
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) async throws -> User {
        // Validate inputs
        guard !email.isEmpty, email.contains("@"), email.contains(".") else {
            throw AuthError.invalidCredentials
        }
        guard password.count >= 8,
              password.contains(where: { $0.isUppercase }),
              password.contains(where: { $0.isLowercase }),
              password.contains(where: { $0.isNumber }) else {
            throw AuthError.passwordTooWeak
        }
        guard !firstName.isEmpty, !lastName.isEmpty else {
            throw AuthError.unknown("First and last name are required")
        }
        
        authState = .authenticating
        
        do {
            let request = SignUpRequest(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName
            )
            let response: AuthResponse = try await networkClient.post(
                endpoint: "/auth/signup",
                body: request
            )
            
            let user = response.user
            authState = .unauthenticated // Requires confirmation
            
            return user
        } catch let error as NetworkError {
            authState = .error(mapNetworkError(error))
            throw mapNetworkError(error)
        } catch {
            authState = .error(.unknown(error.localizedDescription))
            throw AuthError.unknown(error.localizedDescription)
        }
    }
    
    func signOut() async throws {
        do {
            try await networkClient.post(endpoint: "/auth/signout", body: EmptyRequest())
            
            // Clear stored tokens
            try keychainManager.delete(key: "accessToken")
            try keychainManager.delete(key: "refreshToken")
            
            currentUser = nil
            authState = .unauthenticated
        } catch {
            throw AuthError.networkError
        }
    }
    
    func confirmSignUp(email: String, confirmationCode: String) async throws {
        guard confirmationCode.count == 6,
              confirmationCode.allSatisfy({ $0.isNumber }) else {
            throw AuthError.invalidConfirmationCode
        }
        
        let request = ConfirmSignUpRequest(email: email, code: confirmationCode)
        
        do {
            let response: AuthResponse = try await networkClient.post(
                endpoint: "/auth/confirm-signup",
                body: request
            )
            
            try keychainManager.save(response.accessToken, key: "accessToken")
            try keychainManager.save(response.refreshToken, key: "refreshToken")
            
            currentUser = response.user
            authState = .authenticated(response.user)
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func resendConfirmationCode(email: String) async throws {
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        let request = ResendCodeRequest(email: email)
        
        do {
            try await networkClient.post(endpoint: "/auth/resend-code", body: request)
        } catch {
            throw AuthError.networkError
        }
    }
    
    func forgotPassword(email: String) async throws {
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidCredentials
        }
        
        let request = ForgotPasswordRequest(email: email)
        
        do {
            try await networkClient.post(endpoint: "/auth/forgot-password", body: request)
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func confirmForgotPassword(email: String, newPassword: String, confirmationCode: String) async throws {
        guard confirmationCode.count == 6 else {
            throw AuthError.invalidConfirmationCode
        }
        guard newPassword.count >= 8 else {
            throw AuthError.passwordTooWeak
        }
        
        let request = ConfirmForgotPasswordRequest(
            email: email,
            newPassword: newPassword,
            code: confirmationCode
        )
        
        do {
            try await networkClient.post(endpoint: "/auth/confirm-forgot-password", body: request)
        } catch let error as NetworkError {
            throw mapNetworkError(error)
        }
    }
    
    func refreshSession() async throws {
        guard let refreshToken = try? keychainManager.get(key: "refreshToken") else {
            authState = .unauthenticated
            throw AuthError.sessionExpired
        }
        
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let response: AuthResponse = try await networkClient.post(
                endpoint: "/auth/refresh",
                body: request
            )
            
            try keychainManager.save(response.accessToken, key: "accessToken")
            try keychainManager.save(response.refreshToken, key: "refreshToken")
            
            currentUser = response.user
            authState = .authenticated(response.user)
        } catch {
            authState = .unauthenticated
            throw AuthError.sessionExpired
        }
    }
    
    func getCurrentUser() async -> User? {
        // Return cached user if available
        if let user = currentUser {
            return user
        }
        
        // Try to restore session from stored tokens
        guard let accessToken = try? keychainManager.get(key: "accessToken") else {
            return nil
        }
        
        do {
            let user: User = try await networkClient.get(
                endpoint: "/auth/me",
                headers: ["Authorization": "Bearer \(accessToken)"]
            )
            currentUser = user
            return user
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func mapNetworkError(_ error: NetworkError) -> AuthError {
        switch error {
        case .unauthorized:
            return .invalidCredentials
        case .notFound:
            return .userNotFound
        case .conflict:
            return .userAlreadyExists
        case .badRequest:
            return .invalidConfirmationCode
        case .serverError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}

// MARK: - Supporting Types

struct SignInRequest: Codable {
    let email: String
    let password: String
}

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct ConfirmSignUpRequest: Codable {
    let email: String
    let code: String
}

struct ResendCodeRequest: Codable {
    let email: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ConfirmForgotPasswordRequest: Codable {
    let email: String
    let newPassword: String
    let code: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct EmptyRequest: Codable {}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

// MARK: - Protocols

protocol NetworkClientProtocol {
    func get<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T
    func post<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T
}

protocol KeychainManagerProtocol {
    func save(_ data: String, key: String) throws
    func get(key: String) throws -> String
    func delete(key: String) throws
}

protocol TokenManagerProtocol {
    func isTokenValid(_ token: String) -> Bool
    func extractExpirationDate(_ token: String) -> Date?
}

enum NetworkError: Error {
    case unauthorized
    case notFound
    case conflict
    case badRequest
    case serverError
    case networkError
    case decodingError
}

// MARK: - AuthServiceTests

@MainActor
final class AuthServiceTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: AuthService!
    private var mockNetworkClient: MockNetworkClient!
    private var mockKeychainManager: MockKeychainManager!
    private var mockTokenManager: MockTokenManager!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkClient = MockNetworkClient()
        mockKeychainManager = MockKeychainManager()
        mockTokenManager = MockTokenManager()
        sut = AuthService(
            networkClient: mockNetworkClient,
            keychainManager: mockKeychainManager,
            tokenManager: mockTokenManager
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkClient.reset()
        mockKeychainManager.reset()
        mockTokenManager.reset()
        mockNetworkClient = nil
        mockKeychainManager = nil
        mockTokenManager = nil
        super.tearDown()
    }
    
    // MARK: - Sign In Tests
    
    func test_signIn_withValidCredentials_returnsUser() async throws {
        // Given
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
        
        // When
        let user = try await sut.signIn(email: "test@example.com", password: "Password123")
        
        // Then
        XCTAssertEqual(user.id, expectedUser.id)
        XCTAssertEqual(sut.currentUser?.id, expectedUser.id)
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func test_signIn_withEmptyEmail_throwsInvalidCredentials() async {
        // When/Then
        do {
            _ = try await sut.signIn(email: "", password: "Password123")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
    
    func test_signIn_withInvalidEmailFormat_throwsInvalidCredentials() async {
        // When/Then
        do {
            _ = try await sut.signIn(email: "invalidemail", password: "Password123")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
    
    func test_signIn_withShortPassword_throwsInvalidCredentials() async {
        // When/Then
        do {
            _ = try await sut.signIn(email: "test@example.com", password: "short")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
    
    func test_signIn_storesTokensInKeychain() async throws {
        // Given
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
        
        // When
        _ = try await sut.signIn(email: "test@example.com", password: "Password123")
        
        // Then
        XCTAssertEqual(mockKeychainManager.savedData["accessToken"], "access-token")
        XCTAssertEqual(mockKeychainManager.savedData["refreshToken"], "refresh-token")
    }
    
    func test_signIn_withUnauthorizedError_throwsInvalidCredentials() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .unauthorized
        
        // When/Then
        do {
            _ = try await sut.signIn(email: "test@example.com", password: "wrongpassword")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
    
    // MARK: - Sign Up Tests
    
    func test_signUp_withValidData_returnsUser() async throws {
        // Given
        let expectedUser = User(
            id: "user-1",
            email: "new@example.com",
            firstName: "New",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
        
        // When
        let user = try await sut.signUp(
            email: "new@example.com",
            password: "Password123",
            firstName: "New",
            lastName: "User"
        )
        
        // Then
        XCTAssertEqual(user.id, expectedUser.id)
    }
    
    func test_signUp_withWeakPassword_throwsPasswordTooWeak() async {
        // When/Then
        do {
            _ = try await sut.signUp(
                email: "new@example.com",
                password: "password", // No uppercase, no number
                firstName: "New",
                lastName: "User"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .passwordTooWeak)
        }
    }
    
    func test_signUp_withEmptyFirstName_throwsError() async {
        // When/Then
        do {
            _ = try await sut.signUp(
                email: "new@example.com",
                password: "Password123",
                firstName: "",
                lastName: "User"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            if case .unknown = error {
                // Expected
            } else {
                XCTFail("Expected unknown error")
            }
        }
    }
    
    func test_signUp_withConflictError_throwsUserAlreadyExists() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .conflict
        
        // When/Then
        do {
            _ = try await sut.signUp(
                email: "existing@example.com",
                password: "Password123",
                firstName: "Existing",
                lastName: "User"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .userAlreadyExists)
        }
    }
    
    // MARK: - Sign Out Tests
    
    func test_signOut_clearsUserAndTokens() async throws {
        // Given
        let user = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: user,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
        _ = try await sut.signIn(email: "test@example.com", password: "Password123")
        
        // When
        try await sut.signOut()
        
        // Then
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(mockKeychainManager.savedData["accessToken"])
        XCTAssertNil(mockKeychainManager.savedData["refreshToken"])
    }
    
    // MARK: - Confirm Sign Up Tests
    
    func test_confirmSignUp_withValidCode_authenticatesUser() async throws {
        // Given
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "access-token",
            refreshToken: "refresh-token"
        )
        
        // When
        try await sut.confirmSignUp(email: "test@example.com", confirmationCode: "123456")
        
        // Then
        XCTAssertEqual(sut.currentUser?.id, expectedUser.id)
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func test_confirmSignUp_withShortCode_throwsInvalidConfirmationCode() async {
        // When/Then
        do {
            try await sut.confirmSignUp(email: "test@example.com", confirmationCode: "12345")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidConfirmationCode)
        }
    }
    
    func test_confirmSignUp_withNonNumericCode_throwsInvalidConfirmationCode() async {
        // When/Then
        do {
            try await sut.confirmSignUp(email: "test@example.com", confirmationCode: "12345a")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidConfirmationCode)
        }
    }
    
    // MARK: - Resend Confirmation Code Tests
    
    func test_resendConfirmationCode_withValidEmail_succeeds() async throws {
        // When/Then - Should not throw
        try await sut.resendConfirmationCode(email: "test@example.com")
    }
    
    func test_resendConfirmationCode_withEmptyEmail_throwsInvalidCredentials() async {
        // When/Then
        do {
            try await sut.resendConfirmationCode(email: "")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
    
    // MARK: - Forgot Password Tests
    
    func test_forgotPassword_withValidEmail_succeeds() async throws {
        // When/Then - Should not throw
        try await sut.forgotPassword(email: "test@example.com")
    }
    
    func test_forgotPassword_withNotFoundError_throwsUserNotFound() async {
        // Given
        mockNetworkClient.shouldThrowError = true
        mockNetworkClient.errorToThrow = .notFound
        
        // When/Then
        do {
            try await sut.forgotPassword(email: "nonexistent@example.com")
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .userNotFound)
        }
    }
    
    // MARK: - Confirm Forgot Password Tests
    
    func test_confirmForgotPassword_withValidData_succeeds() async throws {
        // When/Then - Should not throw
        try await sut.confirmForgotPassword(
            email: "test@example.com",
            newPassword: "NewPassword123",
            confirmationCode: "123456"
        )
    }
    
    func test_confirmForgotPassword_withWeakPassword_throwsPasswordTooWeak() async {
        // When/Then
        do {
            try await sut.confirmForgotPassword(
                email: "test@example.com",
                newPassword: "short",
                confirmationCode: "123456"
            )
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .passwordTooWeak)
        }
    }
    
    // MARK: - Refresh Session Tests
    
    func test_refreshSession_withValidToken_updatesUser() async throws {
        // Given
        mockKeychainManager.savedData["refreshToken"] = "valid-refresh-token"
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "new-access-token",
            refreshToken: "new-refresh-token"
        )
        
        // When
        try await sut.refreshSession()
        
        // Then
        XCTAssertEqual(sut.currentUser?.id, expectedUser.id)
        XCTAssertEqual(mockKeychainManager.savedData["accessToken"], "new-access-token")
    }
    
    func test_refreshSession_withNoToken_throwsSessionExpired() async {
        // Given
        mockKeychainManager.savedData.removeAll()
        
        // When/Then
        do {
            try await sut.refreshSession()
            XCTFail("Expected error to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .sessionExpired)
        }
    }
    
    // MARK: - Get Current User Tests
    
    func test_getCurrentUser_withCachedUser_returnsUser() async {
        // Given
        let user = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        sut = AuthService(
            networkClient: mockNetworkClient,
            keychainManager: mockKeychainManager,
            tokenManager: mockTokenManager
        )
        // Simulate setting current user through sign in
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: user,
            accessToken: "token",
            refreshToken: "refresh"
        )
        _ = try? await sut.signIn(email: "test@example.com", password: "Password123")
        
        // When
        let currentUser = await sut.getCurrentUser()
        
        // Then
        XCTAssertEqual(currentUser?.id, user.id)
    }
    
    func test_getCurrentUser_withStoredToken_fetchesFromNetwork() async {
        // Given
        mockKeychainManager.savedData["accessToken"] = "stored-token"
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockUser = expectedUser
        
        // When
        let user = await sut.getCurrentUser()
        
        // Then
        XCTAssertEqual(user?.id, expectedUser.id)
    }
    
    func test_getCurrentUser_withNoToken_returnsNil() async {
        // Given
        mockKeychainManager.savedData.removeAll()
        
        // When
        let user = await sut.getCurrentUser()
        
        // Then
        XCTAssertNil(user)
    }
    
    // MARK: - Auth State Publisher Tests
    
    func test_authStatePublisher_publishesChanges() async {
        // Given
        let expectedUser = User(
            id: "user-1",
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            profileImageUrl: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockNetworkClient.mockAuthResponse = AuthResponse(
            user: expectedUser,
            accessToken: "token",
            refreshToken: "refresh"
        )
        
        let expectation = XCTestExpectation(description: "Auth state publishes")
        var receivedStates: [AuthState] = []
        
        let cancellable = sut.authStatePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count >= 3 {
                    expectation.fulfill()
                }
            }
        
        // When
        _ = try? await sut.signIn(email: "test@example.com", password: "Password123")
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(receivedStates.contains(.authenticating))
        XCTAssertTrue(receivedStates.contains { state in
            if case .authenticated = state { return true }
            return false
        })
        
        cancellable.cancel()
    }
}

// MARK: - Mock Network Client

class MockNetworkClient: NetworkClientProtocol {
    var mockAuthResponse: AuthResponse?
    var mockUser: User?
    var shouldThrowError = false
    var errorToThrow: NetworkError?
    
    func get<T: Decodable>(endpoint: String, headers: [String: String]?) async throws -> T {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        if let user = mockUser as? T {
            return user
        }
        
        throw NetworkError.decodingError
    }
    
    func post<T: Decodable, B: Encodable>(endpoint: String, body: B) async throws -> T {
        if shouldThrowError, let error = errorToThrow {
            throw error
        }
        
        if let response = mockAuthResponse as? T {
            return response
        }
        
        throw NetworkError.decodingError
    }
    
    func reset() {
        mockAuthResponse = nil
        mockUser = nil
        shouldThrowError = false
        errorToThrow = nil
    }
}

// MARK: - Mock Keychain Manager

class MockKeychainManager: KeychainManagerProtocol {
    var savedData: [String: String] = [:]
    var shouldThrowError = false
    
    func save(_ data: String, key: String) throws {
        if shouldThrowError {
            throw KeychainError.saveFailed
        }
        savedData[key] = data
    }
    
    func get(key: String) throws -> String {
        if shouldThrowError {
            throw KeychainError.notFound
        }
        guard let data = savedData[key] else {
            throw KeychainError.notFound
        }
        return data
    }
    
    func delete(key: String) throws {
        if shouldThrowError {
            throw KeychainError.deleteFailed
        }
        savedData.removeValue(forKey: key)
    }
    
    func reset() {
        savedData.removeAll()
        shouldThrowError = false
    }
}

enum KeychainError: Error {
    case saveFailed
    case notFound
    case deleteFailed
}

// MARK: - Mock Token Manager

class MockTokenManager: TokenManagerProtocol {
    func isTokenValid(_ token: String) -> Bool {
        return true
    }
    
    func extractExpirationDate(_ token: String) -> Date? {
        return Date().addingTimeInterval(3600)
    }
    
    func reset() {}
}

//
//  AuthService.swift
//  CapybaraGym
//
//  AWS Amplify Authentication Service
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

// MARK: - Auth Errors
public enum AuthError: LocalizedError {
    case notAuthenticated
    case invalidCredentials
    case userNotFound
    case userAlreadyExists
    case invalidPassword
    case networkError
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You are not authenticated"
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .userAlreadyExists:
            return "An account with this email already exists"
        case .invalidPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and number"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Auth User Model
public struct AuthUser: Identifiable, Codable {
    public let id: String
    public let email: String
    public let username: String?
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let isEmailVerified: Bool
    public let createdAt: Date?
    
    public var displayName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        }
        return username ?? email
    }
}

// MARK: - Auth Service Protocol
public protocol AuthServiceProtocol {
    var currentUser: AuthUser? { get }
    var isAuthenticated: Bool { get }
    
    func signUp(email: String, password: String, attributes: [String: String]) async throws -> AuthUser
    func confirmSignUp(email: String, confirmationCode: String) async throws
    func resendConfirmationCode(email: String) async throws
    func signIn(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func resetPassword(email: String) async throws
    func confirmResetPassword(email: String, newPassword: String, confirmationCode: String) async throws
    func changePassword(oldPassword: String, newPassword: String) async throws
    func updateUserAttributes(attributes: [String: String]) async throws -> AuthUser
    func fetchCurrentUser() async throws -> AuthUser
    func refreshSession() async throws
}

// MARK: - Auth Service Implementation
public final class AuthService: AuthServiceProtocol, ObservableObject {
    
    // MARK: - Singleton
    public static let shared = AuthService()
    
    // MARK: - Published Properties
    @Published public private(set) var currentUser: AuthUser?
    @Published public private(set) var isAuthenticated = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    private init() {
        Task {
            await checkAuthSession()
        }
    }
    
    // MARK: - Public Methods
    
    public func signUp(
        email: String,
        password: String,
        attributes: [String: String] = [:]
    ) async throws -> AuthUser {
        do {
            let userAttributes = attributes.map { AuthUserAttribute($0.key, value: $0.value) }
            
            let options = AuthSignUpRequest.Options(
                userAttributes: userAttributes
            )
            
            let result = try await Amplify.Auth.signUp(
                username: email,
                password: password,
                options: options
            )
            
            guard result.isSignUpComplete else {
                throw AuthError.unknown(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Sign up incomplete"]))
            }
            
            let user = AuthUser(
                id: result.userId ?? UUID().uuidString,
                email: email,
                username: attributes["preferred_username"],
                firstName: attributes["given_name"],
                lastName: attributes["family_name"],
                phoneNumber: attributes["phone_number"],
                isEmailVerified: false,
                createdAt: Date()
            )
            
            Logger.info("User signed up: \(email)")
            return user
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func confirmSignUp(email: String, confirmationCode: String) async throws {
        do {
            let result = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: confirmationCode
            )
            
            guard result.isSignUpComplete else {
                throw AuthError.unknown(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Confirmation incomplete"]))
            }
            
            Logger.info("User confirmed sign up: \(email)")
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func resendConfirmationCode(email: String) async throws {
        do {
            _ = try await Amplify.Auth.resendSignUpCode(for: email)
            Logger.info("Resent confirmation code to: \(email)")
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func signIn(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await Amplify.Auth.signIn(
                username: email,
                password: password
            )
            
            guard result.isSignedIn else {
                throw AuthError.invalidCredentials
            }
            
            let user = try await fetchCurrentUser()
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            saveAuthState()
            
            // Post notification
            NotificationCenter.default.post(name: NotificationNames.userDidLogin, object: nil)
            
            Logger.info("User signed in: \(email)")
            return user
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func signOut() async throws {
        do {
            _ = try await Amplify.Auth.signOut()
            
            await MainActor.run {
                self.currentUser = nil
                self.isAuthenticated = false
            }
            
            clearAuthState()
            
            // Post notification
            NotificationCenter.default.post(name: NotificationNames.userDidLogout, object: nil)
            
            Logger.info("User signed out")
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func resetPassword(email: String) async throws {
        do {
            _ = try await Amplify.Auth.resetPassword(for: email)
            Logger.info("Password reset requested for: \(email)")
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func confirmResetPassword(
        email: String,
        newPassword: String,
        confirmationCode: String
    ) async throws {
        do {
            _ = try await Amplify.Auth.confirmResetPassword(
                for: email,
                with: newPassword,
                confirmationCode: confirmationCode
            )
            Logger.info("Password reset confirmed for: \(email)")
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func changePassword(oldPassword: String, newPassword: String) async throws {
        do {
            _ = try await Amplify.Auth.update(oldPassword: oldPassword, to: newPassword)
            Logger.info("Password changed successfully")
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func updateUserAttributes(attributes: [String: String]) async throws -> AuthUser {
        do {
            let userAttributes = attributes.map { AuthUserAttribute($0.key, value: $0.value) }
            _ = try await Amplify.Auth.update(userAttributes: userAttributes)
            
            let user = try await fetchCurrentUser()
            
            await MainActor.run {
                self.currentUser = user
            }
            
            Logger.info("User attributes updated")
            return user
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func fetchCurrentUser() async throws -> AuthUser {
        do {
            let user = try await Amplify.Auth.getCurrentUser()
            
            // Fetch user attributes
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            
            let email = attributes.first { $0.key == .email }?.value ?? user.username
            let firstName = attributes.first { $0.key == .givenName }?.value
            let lastName = attributes.first { $0.key == .familyName }?.value
            let phoneNumber = attributes.first { $0.key == .phoneNumber }?.value
            let isEmailVerified = attributes.first { $0.key == .email } != nil
            
            return AuthUser(
                id: user.userId,
                email: email,
                username: user.username,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                isEmailVerified: isEmailVerified,
                createdAt: nil
            )
            
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    public func refreshSession() async throws {
        do {
            _ = try await Amplify.Auth.fetchAuthSession()
            Logger.debug("Session refreshed")
        } catch let error as AuthError {
            throw mapAuthError(error)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthSession() async {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            
            if session.isSignedIn {
                let user = try await fetchCurrentUser()
                
                await MainActor.run {
                    self.currentUser = user
                    self.isAuthenticated = true
                }
                
                saveAuthState()
                Logger.info("User session restored")
            }
        } catch {
            Logger.error("Failed to restore session: \(error)")
        }
    }
    
    private func mapAuthError(_ error: AuthError) -> CapybaraGym.AuthError {
        switch error {
        case .service(_, let underlyingError, _):
            if let cognitoError = underlyingError as? NSError {
                switch cognitoError.code {
                case 34: // UserNotFoundException
                    return .userNotFound
                case 23: // NotAuthorizedException
                    return .invalidCredentials
                case 32: // UsernameExistsException
                    return .userAlreadyExists
                default:
                    return .unknown(error)
                }
            }
            return .unknown(error)
        case .validation(_, _, _, let underlyingError):
            return .unknown(underlyingError ?? error)
        case .configuration(_, _, _):
            return .unknown(error)
        case .unknown(_, let underlyingError):
            return .unknown(underlyingError ?? error)
        case .notAuthorized(_, _, _):
            return .notAuthenticated
        case .sessionExpired(_, _, _):
            return .notAuthenticated
        case .signedOut(_, _, _):
            return .notAuthenticated
        case .invalidState(_, _, _):
            return .unknown(error)
        @unknown default:
            return .unknown(error)
        }
    }
    
    private func saveAuthState() {
        userDefaults.set(true, forKey: UserDefaultsKeys.isLoggedIn)
        userDefaults.set(currentUser?.id, forKey: UserDefaultsKeys.userId)
    }
    
    private func clearAuthState() {
        userDefaults.set(false, forKey: UserDefaultsKeys.isLoggedIn)
        userDefaults.removeObject(forKey: UserDefaultsKeys.userId)
        userDefaults.removeObject(forKey: UserDefaultsKeys.authToken)
    }
}

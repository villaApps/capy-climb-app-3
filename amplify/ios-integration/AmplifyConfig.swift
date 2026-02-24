//
//  AmplifyConfig.swift
//  Capybara Wellness
//
//  AWS Amplify Configuration for iOS
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

/// Amplify configuration manager for Capybara Wellness app
class AmplifyConfig {
    
    static let shared = AmplifyConfig()
    
    private init() {}
    
    /// Configure Amplify with all required plugins
    func configure() {
        do {
            // Add authentication plugin
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            
            // Add API plugin for GraphQL
            try Amplify.add(plugin: AWSAPIPlugin())
            
            // Add storage plugin for S3
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            // Configure Amplify
            try Amplify.configure()
            
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
    
    /// Check if user is signed in
    var isSignedIn: AsyncStream<Bool> {
        AsyncStream { continuation in
            Task {
                do {
                    let session = try await Amplify.Auth.fetchAuthSession()
                    continuation.yield(session.isSignedIn)
                } catch {
                    continuation.yield(false)
                }
                continuation.finish()
            }
        }
    }
    
    /// Get current user
    func getCurrentUser() async throws -> AuthUser? {
        return try await Amplify.Auth.getCurrentUser()
    }
}

// MARK: - Error Handling

enum AmplifyError: LocalizedError {
    case notConfigured
    case notAuthenticated
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Amplify is not configured"
        case .notAuthenticated:
            return "User is not authenticated"
        case .networkError:
            return "Network error occurred"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

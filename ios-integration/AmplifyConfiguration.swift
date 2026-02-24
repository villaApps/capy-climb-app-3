import Foundation
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

/**
 * GymPass App - Amplify Configuration
 * 
 * This file configures AWS Amplify for the iOS app.
 * Call `AmplifyConfiguration.configure()` in your AppDelegate or App init.
 */

public enum AmplifyConfiguration {
    
    /// Configure Amplify with all plugins
    public static func configure() {
        do {
            // Add Auth plugin (Cognito)
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            
            // Add API plugin (AppSync)
            try Amplify.add(plugin: AWSAPIPlugin())
            
            // Add Storage plugin (S3)
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            // Configure Amplify
            try Amplify.configure()
            
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
    
    /// Reset Amplify (useful for testing)
    public static func reset() {
        Amplify.reset()
    }
}

// MARK: - Configuration Extension for Environment-based setup

extension AmplifyConfiguration {
    
    /// Configuration for different environments
    public enum Environment {
        case development
        case staging
        case production
        
        var configFile: String {
            switch self {
            case .development:
                return "amplifyconfiguration_dev"
            case .staging:
                return "amplifyconfiguration_staging"
            case .production:
                return "amplifyconfiguration"
            }
        }
    }
    
    /// Configure with specific environment
    public static func configure(for environment: Environment) {
        // Load configuration from specific file if needed
        configure()
    }
}

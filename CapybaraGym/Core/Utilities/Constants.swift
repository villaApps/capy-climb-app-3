//
//  Constants.swift
//  CapybaraGym
//
//  App-wide constants
//

import Foundation

// MARK: - App Constants
public struct AppConstants {
    
    /// App name
    public static let appName = "Capybara Gym"
    
    /// App version
    public static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }()
    
    /// Build number
    public static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()
    
    /// Bundle identifier
    public static let bundleIdentifier: String = {
        Bundle.main.bundleIdentifier ?? "com.capybara.gym"
    }()
    
    /// Full version string
    public static let fullVersion: String = "\(appVersion) (\(buildNumber))"
}

// MARK: - API Constants
public struct APIConstants {
    
    /// Base URL for API
    public static let baseURL = "https://api.capybaragym.com"
    
    /// API version
    public static let apiVersion = "v1"
    
    /// Full API URL
    public static let apiURL = "\(baseURL)/\(apiVersion)"
    
    /// Request timeout
    public static let timeout: TimeInterval = 30
    
    /// Retry count
    public static let retryCount = 3
    
    /// Pagination limit
    public static let paginationLimit = 20
}

// MARK: - User Defaults Keys
public struct UserDefaultsKeys {
    
    /// User preferences
    public static let hasSeenOnboarding = "hasSeenOnboarding"
    public static let isLoggedIn = "isLoggedIn"
    public static let userId = "userId"
    public static let authToken = "authToken"
    public static let refreshToken = "refreshToken"
    
    /// Settings
    public static let notificationsEnabled = "notificationsEnabled"
    public static let darkModeEnabled = "darkModeEnabled"
    public static let biometricAuthEnabled = "biometricAuthEnabled"
    
    /// Cache
    public static let lastSyncDate = "lastSyncDate"
    public static let cachedGyms = "cachedGyms"
    public static let cachedPasses = "cachedPasses"
}

// MARK: - Notification Names
public struct NotificationNames {
    
    /// Auth notifications
    public static let userDidLogin = Notification.Name("userDidLogin")
    public static let userDidLogout = Notification.Name("userDidLogout")
    public static let sessionExpired = Notification.Name("sessionExpired")
    
    /// Data notifications
    public static let dataDidUpdate = Notification.Name("dataDidUpdate")
    public static let passDidUpdate = Notification.Name("passDidUpdate")
    public static let profileDidUpdate = Notification.Name("profileDidUpdate")
    
    /// Location notifications
    public static let locationDidUpdate = Notification.Name("locationDidUpdate")
    public static let locationAccessDenied = Notification.Name("locationAccessDenied")
    
    /// QR Code notifications
    public static let qrCodeScanned = Notification.Name("qrCodeScanned")
    public static let checkInCompleted = Notification.Name("checkInCompleted")
}

// MARK: - Deep Link Constants
public struct DeepLinkConstants {
    
    /// URL scheme
    public static let scheme = "capybaragym"
    
    /// Hosts
    public static let gymHost = "gym"
    public static let passHost = "pass"
    public static let shopHost = "shop"
    public static let profileHost = "profile"
    
    /// Paths
    public static let checkInPath = "checkin"
    public static let purchasePath = "purchase"
    public static let redeemPath = "redeem"
}

// MARK: - Validation Constants
public struct ValidationConstants {
    
    /// Minimum password length
    public static let minPasswordLength = 8
    
    /// Maximum password length
    public static let maxPasswordLength = 128
    
    /// Minimum name length
    public static let minNameLength = 2
    
    /// Maximum name length
    public static let maxNameLength = 50
    
    /// Phone number length
    public static let phoneNumberLength = 10
    
    /// Verification code length
    public static let verificationCodeLength = 6
}

// MARK: - Cache Constants
public struct CacheConstants {
    
    /// Image cache size (MB)
    public static let imageCacheSize = 100
    
    /// Data cache duration (hours)
    public static let dataCacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours
    
    /// Location cache duration (minutes)
    public static let locationCacheDuration: TimeInterval = 5 * 60 // 5 minutes
}

// MARK: - Feature Flags
public struct FeatureFlags {
    
    /// Enable biometric authentication
    public static let biometricAuth = true
    
    /// Enable social login
    public static let socialLogin = true
    
    /// Enable in-app purchases
    public static let inAppPurchases = true
    
    /// Enable community features
    public static let communityFeatures = true
    
    /// Enable dark mode
    public static let darkMode = false
}

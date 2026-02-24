//
//  AppDelegate.swift
//  CapybaraGym
//
//  Created by Capybara Gym Team
//  Copyright © 2024 Capybara Gym. All rights reserved.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Configure appearance
        configureAppearance()
        
        // Register for remote notifications
        registerForPushNotifications(application)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("📱 Device Token: \(token)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for notifications: \(error.localizedDescription)")
    }
    
    // MARK: - Private Methods
    
    private func configureAppearance() {
        // Navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(CapyColors.background)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(CapyColors.textPrimary),
            .font: UIFont(name: CapyTypography.FontFamily.outfitSemiBold, size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(CapyColors.textPrimary),
            .font: UIFont(name: CapyTypography.FontFamily.outfitBold, size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(CapyColors.cardBackground)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Disable keyboard dismissal swipe
        UITextField.appearance().keyboardAppearance = .light
    }
    
    private func registerForPushNotifications(_ application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}

//
//  CapybaraGymApp.swift
//  CapybaraGym
//
//  Created by Capybara Gym Team
//  Copyright © 2024 Capybara Gym. All rights reserved.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

@main
struct CapybaraGymApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var navigationRouter = NavigationRouter()
    
    init() {
        configureAmplify()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .environmentObject(navigationRouter)
                .preferredColorScheme(.light)
        }
    }
    
    private func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("✅ Amplify configured successfully")
        } catch {
            print("❌ Failed to configure Amplify: \(error)")
        }
    }
}

//
//  RootView.swift
//  CapybaraGym
//
//  Root view that handles authentication state and main app flow
//

import SwiftUI

public struct RootView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var navigationRouter: NavigationRouter
    
    public init() {}
    
    public var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationFlow()
            }
        }
    }
}

// MARK: - Authentication Flow
struct AuthenticationFlow: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            SignInView()
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    
    @EnvironmentObject var navigationRouter: NavigationRouter
    @State private var showQRScanner = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $navigationRouter.selectedTab) {
                HomeView()
                    .tag(NavigationRouter.Tab.home)
                    .tabItem {
                        Image(systemName: NavigationRouter.Tab.home.icon)
                        Text(NavigationRouter.Tab.home.title)
                    }
                
                GymMapView()
                    .tag(NavigationRouter.Tab.gymMap)
                    .tabItem {
                        Image(systemName: NavigationRouter.Tab.gymMap.icon)
                        Text(NavigationRouter.Tab.gymMap.title)
                    }
                
                // Placeholder for QR Scanner (center button)
                Color.clear
                    .tag(NavigationRouter.Tab.qrScanner)
                    .tabItem {
                        Image(systemName: NavigationRouter.Tab.qrScanner.icon)
                        Text(NavigationRouter.Tab.qrScanner.title)
                    }
                
                ShopView()
                    .tag(NavigationRouter.Tab.shop)
                    .tabItem {
                        Image(systemName: NavigationRouter.Tab.shop.icon)
                        Text(NavigationRouter.Tab.shop.title)
                    }
                
                CommunityView()
                    .tag(NavigationRouter.Tab.community)
                    .tabItem {
                        Image(systemName: NavigationRouter.Tab.community.icon)
                        Text(NavigationRouter.Tab.community.title)
                    }
            }
            .tint(CapyColors.primary)
            
            // Custom QR Scanner Button (centered)
            VStack {
                Spacer()
                
                Button(action: {
                    showQRScanner = true
                }) {
                    ZStack {
                        Circle()
                            .fill(CapyColors.primary)
                            .frame(width: 64, height: 64)
                            .shadow(color: CapyColors.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: "qrcode")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -10)
            }
        }
        .sheet(isPresented: $showQRScanner) {
            QRScannerView()
        }
    }
}

// MARK: - Custom Tab Bar (Alternative)
struct CustomTabBar: View {
    
    @Binding var selectedTab: NavigationRouter.Tab
    let tabs: [NavigationRouter.Tab]
    let onCenterTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                if tab == .qrScanner {
                    // Center button
                    Spacer()
                    
                    Button(action: onCenterTap) {
                        ZStack {
                            Circle()
                                .fill(CapyColors.primary)
                                .frame(width: 56, height: 56)
                                .shadow(color: CapyColors.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(y: -20)
                    
                    Spacer()
                } else {
                    // Regular tab
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                                .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? CapyColors.primary : CapyColors.textTertiary)
                            
                            Text(tab.title)
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == tab ? CapyColors.primary : CapyColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 34) // Safe area
        .background(
            CapyColors.cardElevated
                .shadow(color: CapyColors.shadow, radius: 20, x: 0, y: -5)
        )
    }
}

// MARK: - Preview
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(NavigationRouter())
    }
}

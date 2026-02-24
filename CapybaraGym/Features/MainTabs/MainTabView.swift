//
//  MainTabView.swift
//  CapybaraGym
//
//  Main tab container view
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)
            
            // Map Tab
            GymMapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(Tab.map)
            
            // QR Scanner Tab (Center)
            QRScannerView()
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }
                .tag(Tab.scan)
            
            // Community Tab
            CommunityView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Community")
                }
                .tag(Tab.community)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile)
        }
        .accentColor(.primaryBrown)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(Color.tabBarBackground)
            
            // Remove default border
            appearance.shadowColor = .clear
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Tab Enum
enum Tab: Int, CaseIterable {
    case home = 0
    case map = 1
    case scan = 2
    case community = 3
    case profile = 4
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .scan: return "qrcode.viewfinder"
        case .community: return "person.3.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Map"
        case .scan: return "Scan"
        case .community: return "Community"
        case .profile: return "Profile"
        }
    }
}

// MARK: - ViewModel
@MainActor
class MainTabViewModel: ObservableObject {
    @Published var selectedTab: Tab = .home
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
}

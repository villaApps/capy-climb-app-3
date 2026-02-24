//
//  NavigationRouter.swift
//  CapybaraGym
//
//  Central navigation router for the app
//

import SwiftUI

// MARK: - Navigation Route
public enum NavigationRoute: Hashable {
    // Authentication
    case signIn
    case signUp
    case forgotPassword
    case confirmSignUp(email: String)
    
    // Main Tabs
    case home
    case gymMap
    case passManagement
    case qrScanner
    case shop
    case community
    case profile
    
    // Gym
    case gymDetail(gymId: String)
    case gymDirections(gym: GymLocation)
    
    // Pass
    case passDetail(passId: String)
    case purchasePass(type: Pass.PassType)
    
    // Profile
    case editProfile
    case settings
    case paymentMethods
    
    // Shop
    case productDetail(productId: String)
    
    // Community
    case postDetail(postId: String)
    case challengeDetail(challengeId: String)
}

// MARK: - Navigation Router
@MainActor
public final class NavigationRouter: ObservableObject {
    
    // MARK: - Published Properties
    @Published public var path = NavigationPath()
    @Published public var selectedTab: Tab = .home
    @Published public var presentSheet: NavigationRoute?
    @Published public var presentFullScreen: NavigationRoute?
    
    // MARK: - Tab Enum
    public enum Tab: String, CaseIterable {
        case home = "home"
        case gymMap = "map"
        case qrScanner = "qr"
        case shop = "shop"
        case community = "community"
        case profile = "profile"
        
        public var title: String {
            switch self {
            case .home: return "Home"
            case .gymMap: return "Map"
            case .qrScanner: return "Scan"
            case .shop: return "Shop"
            case .community: return "Community"
            case .profile: return "Profile"
            }
        }
        
        public var icon: String {
            switch self {
            case .home: return "house"
            case .gymMap: return "map"
            case .qrScanner: return "qrcode"
            case .shop: return "bag"
            case .community: return "person.3"
            case .profile: return "person"
            }
        }
        
        public var selectedIcon: String {
            return icon + ".fill"
        }
    }
    
    // MARK: - Navigation Methods
    
    public func navigate(to route: NavigationRoute) {
        path.append(route)
    }
    
    public func navigateBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    public func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    public func present(_ route: NavigationRoute) {
        presentSheet = route
    }
    
    public func presentFullScreen(_ route: NavigationRoute) {
        presentFullScreen = route
    }
    
    public func dismissSheet() {
        presentSheet = nil
    }
    
    public func dismissFullScreen() {
        presentFullScreen = nil
    }
    
    public func switchTab(to tab: Tab) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedTab = tab
        }
    }
}

// MARK: - View Extension for Navigation
public extension View {
    
    func withNavigationRouter() -> some View {
        self.navigationDestination(for: NavigationRoute.self) { route in
            route.view
        }
    }
}

// MARK: - Navigation Route View Extension
extension NavigationRoute {
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .signIn:
            SignInView()
        case .signUp:
            SignUpView()
        case .forgotPassword:
            EmptyView() // ForgotPasswordView()
        case .confirmSignUp(let email):
            EmptyView() // ConfirmSignUpView(email: email)
        case .home:
            HomeView()
        case .gymMap:
            GymMapView()
        case .passManagement:
            PassManagementView()
        case .qrScanner:
            QRScannerView()
        case .shop:
            ShopView()
        case .community:
            CommunityView()
        case .profile:
            ProfileView()
        case .gymDetail(let gymId):
            EmptyView() // GymDetailView(gymId: gymId)
        case .gymDirections(let gym):
            EmptyView() // GymDirectionsView(gym: gym)
        case .passDetail(let passId):
            EmptyView() // PassDetailView(passId: passId)
        case .purchasePass(let type):
            EmptyView() // PurchasePassView(type: type)
        case .editProfile:
            EmptyView() // EditProfileView()
        case .settings:
            EmptyView() // SettingsView()
        case .paymentMethods:
            EmptyView() // PaymentMethodsView()
        case .productDetail(let productId):
            EmptyView() // ProductDetailView(productId: productId)
        case .postDetail(let postId):
            EmptyView() // PostDetailView(postId: postId)
        case .challengeDetail(let challengeId):
            EmptyView() // ChallengeDetailView(challengeId: challengeId)
        }
    }
}

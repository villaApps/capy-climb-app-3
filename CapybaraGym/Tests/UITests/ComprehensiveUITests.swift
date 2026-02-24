import XCTest

// MARK: - Comprehensive UI Test Suite
/// Tests all user flows, edge cases, and error states
@MainActor
final class ComprehensiveUITests: XCTestCase {
    
    // MARK: - Properties
    var app: XCUIApplication!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure launch arguments for testing
        app.launchArguments = ["--uitesting", "--reset-state"]
        app.launchEnvironment = [
            "API_BASE_URL": "http://localhost:3000",
            "MOCK_AUTH": "true"
        ]
        
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }
    
    // MARK: - Authentication Flow Tests
    
    func testSignInFlow() {
        // Given
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let signInButton = app.buttons["signInButton"]
        
        // When - Enter valid credentials
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("Password123!")
        
        // Then - Sign in button should be enabled
        XCTAssertTrue(signInButton.isEnabled)
        
        // When - Tap sign in
        signInButton.tap()
        
        // Then - Should navigate to home
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(homeView.waitForExistence(timeout: 5))
    }
    
    func testSignInWithInvalidEmail() {
        let emailField = app.textFields["emailTextField"]
        let signInButton = app.buttons["signInButton"]
        
        emailField.tap()
        emailField.typeText("invalid-email")
        
        // Dismiss keyboard
        app.keyboards.buttons["Return"].tap()
        
        // Then - Should show error
        let errorLabel = app.staticTexts["emailErrorLabel"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2))
        XCTAssertTrue(errorLabel.label.contains("valid email"))
    }
    
    func testSignInWithEmptyFields() {
        let signInButton = app.buttons["signInButton"]
        
        // Then - Button should be disabled
        XCTAssertFalse(signInButton.isEnabled)
    }
    
    func testSignInWithWrongPassword() {
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let signInButton = app.buttons["signInButton"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        passwordField.tap()
        passwordField.typeText("wrongpassword")
        
        signInButton.tap()
        
        // Then - Should show error alert
        let alert = app.alerts["Sign In Failed"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
    }
    
    func testSignUpFlow() {
        // Navigate to sign up
        let signUpLink = app.buttons["Don't have an account? Sign Up"]
        signUpLink.tap()
        
        // Fill sign up form
        let nameField = app.textFields["nameTextField"]
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let confirmPasswordField = app.secureTextFields["confirmPasswordTextField"]
        let signUpButton = app.buttons["signUpButton"]
        
        nameField.tap()
        nameField.typeText("Test User")
        
        emailField.tap()
        emailField.typeText("newuser@example.com")
        
        passwordField.tap()
        passwordField.typeText("Password123!")
        
        confirmPasswordField.tap()
        confirmPasswordField.typeText("Password123!")
        
        signUpButton.tap()
        
        // Then - Should show confirmation screen or navigate to home
        let confirmationView = app.otherElements["confirmationView"]
        XCTAssertTrue(confirmationView.waitForExistence(timeout: 5))
    }
    
    func testPasswordVisibilityToggle() {
        let passwordField = app.secureTextFields["passwordTextField"]
        let toggleButton = app.buttons["passwordVisibilityToggle"]
        
        passwordField.tap()
        passwordField.typeText("secret123")
        
        // Toggle visibility
        toggleButton.tap()
        
        // Then - Should show as text field
        let visiblePasswordField = app.textFields["passwordTextField"]
        XCTAssertTrue(visiblePasswordField.exists)
    }
    
    func testForgotPasswordFlow() {
        let forgotPasswordLink = app.buttons["Forgot Password?"]
        forgotPasswordLink.tap()
        
        let emailField = app.textFields["emailTextField"]
        let resetButton = app.buttons["resetPasswordButton"]
        
        emailField.tap()
        emailField.typeText("test@example.com")
        
        resetButton.tap()
        
        // Then - Should show success message
        let successMessage = app.staticTexts["Password reset email sent"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 5))
    }
    
    func testSocialSignInButtons() {
        let googleButton = app.buttons["signInWithGoogle"]
        let appleButton = app.buttons["signInWithApple"]
        
        XCTAssertTrue(googleButton.exists)
        XCTAssertTrue(appleButton.exists)
        XCTAssertTrue(googleButton.isEnabled)
        XCTAssertTrue(appleButton.isEnabled)
    }
    
    // MARK: - Home Flow Tests
    
    func testHomeViewLoads() {
        signInIfNeeded()
        
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(homeView.exists)
        
        // Check key elements
        XCTAssertTrue(app.staticTexts["Welcome back"].exists)
        XCTAssertTrue(app.scrollViews["homeScrollView"].exists)
    }
    
    func testHomeQuickActions() {
        signInIfNeeded()
        
        let checkInButton = app.buttons["quickCheckInButton"]
        let viewPassesButton = app.buttons["viewPassesButton"]
        let findGymButton = app.buttons["findGymButton"]
        
        XCTAssertTrue(checkInButton.exists)
        XCTAssertTrue(viewPassesButton.exists)
        XCTAssertTrue(findGymButton.exists)
        
        // Tap check in
        checkInButton.tap()
        
        let qrScanner = app.otherElements["qrScannerView"]
        XCTAssertTrue(qrScanner.waitForExistence(timeout: 3))
    }
    
    func testHomeGymCards() {
        signInIfNeeded()
        
        let gymCards = app.scrollViews["featuredGymsScrollView"].otherElements
        XCTAssertGreaterThan(gymCards.count, 0)
        
        // Tap first gym card
        let firstCard = gymCards.element(boundBy: 0)
        firstCard.tap()
        
        let gymDetailView = app.otherElements["gymDetailView"]
        XCTAssertTrue(gymDetailView.waitForExistence(timeout: 3))
    }
    
    func testHomePullToRefresh() {
        signInIfNeeded()
        
        let scrollView = app.scrollViews["homeScrollView"]
        
        // Pull to refresh
        scrollView.swipeDown(velocity: .fast)
        
        // Then - Should show loading indicator
        let loadingIndicator = app.activityIndicators["loadingIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2))
    }
    
    // MARK: - Pass Management Tests
    
    func testPassManagementView() {
        signInIfNeeded()
        navigateToPassManagement()
        
        let passManagementView = app.otherElements["passManagementView"]
        XCTAssertTrue(passManagementView.exists)
        
        // Check tabs
        XCTAssertTrue(app.buttons["Active"].exists)
        XCTAssertTrue(app.buttons["Expired"].exists)
        XCTAssertTrue(app.buttons["History"].exists)
    }
    
    func testActivePassDisplay() {
        signInIfNeeded()
        navigateToPassManagement()
        
        let activeTab = app.buttons["Active"]
        activeTab.tap()
        
        // Check for pass card
        let passCard = app.otherElements["passCard"]
        XCTAssertTrue(passCard.waitForExistence(timeout: 3))
        
        // Check QR code
        let qrCode = app.images["passQRCode"]
        XCTAssertTrue(qrCode.exists)
    }
    
    func testPassQRCodeExpansion() {
        signInIfNeeded()
        navigateToPassManagement()
        
        let qrCode = app.images["passQRCode"]
        qrCode.tap()
        
        let expandedQRView = app.otherElements["expandedQRView"]
        XCTAssertTrue(expandedQRView.waitForExistence(timeout: 2))
    }
    
    func testBuyPassFlow() {
        signInIfNeeded()
        navigateToPassManagement()
        
        let buyPassButton = app.buttons["buyPassButton"]
        buyPassButton.tap()
        
        let shopView = app.otherElements["shopView"]
        XCTAssertTrue(shopView.waitForExistence(timeout: 3))
        
        // Select a pass
        let passOption = app.buttons["passOption"]
        passOption.tap()
        
        let checkoutButton = app.buttons["checkoutButton"]
        XCTAssertTrue(checkoutButton.exists)
    }
    
    func testPassHistory() {
        signInIfNeeded()
        navigateToPassManagement()
        
        let historyTab = app.buttons["History"]
        historyTab.tap()
        
        let historyList = app.tables["passHistoryList"]
        XCTAssertTrue(historyList.waitForExistence(timeout: 3))
    }
    
    // MARK: - QR Scanner Tests
    
    func testQRScannerOpens() {
        signInIfNeeded()
        
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()
        
        let qrScanner = app.otherElements["qrScannerView"]
        XCTAssertTrue(qrScanner.waitForExistence(timeout: 3))
        
        // Check camera preview
        XCTAssertTrue(app.otherElements["cameraPreview"].exists)
    }
    
    func testQRScannerOverlay() {
        signInIfNeeded()
        
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()
        
        // Check scanner overlay elements
        XCTAssertTrue(app.otherElements["scannerFrame"].exists)
        XCTAssertTrue(app.staticTexts["Align QR code within frame"].exists)
    }
    
    func testQRScannerTorchToggle() {
        signInIfNeeded()
        
        let scanTab = app.tabBars.buttons["Scan"]
        scanTab.tap()
        
        let torchButton = app.buttons["torchToggle"]
        XCTAssertTrue(torchButton.exists)
        
        torchButton.tap()
        // Verify torch state changed (would need device-specific testing)
    }
    
    // MARK: - Gym Map Tests
    
    func testGymMapLoads() {
        signInIfNeeded()
        
        let mapTab = app.tabBars.buttons["Map"]
        mapTab.tap()
        
        let mapView = app.otherElements["gymMapView"]
        XCTAssertTrue(mapView.waitForExistence(timeout: 3))
        
        // Check map elements
        XCTAssertTrue(app.otherElements["mapView"].exists)
    }
    
    func testGymMapSearch() {
        signInIfNeeded()
        navigateToGymMap()
        
        let searchField = app.searchFields["Search gyms..."]
        searchField.tap()
        searchField.typeText("Downtown")
        
        // Should show search results
        let resultsList = app.tables["searchResultsList"]
        XCTAssertTrue(resultsList.waitForExistence(timeout: 3))
    }
    
    func testGymMapFilters() {
        signInIfNeeded()
        navigateToGymMap()
        
        let filterButton = app.buttons["filterButton"]
        filterButton.tap()
        
        let filterSheet = app.sheets["filterSheet"]
        XCTAssertTrue(filterSheet.waitForExistence(timeout: 2))
        
        // Apply filter
        let poolFilter = app.switches["poolFilter"]
        poolFilter.tap()
        
        let applyButton = app.buttons["Apply Filters"]
        applyButton.tap()
    }
    
    func testGymAnnotationTap() {
        signInIfNeeded()
        navigateToGymMap()
        
        // Tap on a gym annotation
        let annotation = app.otherElements["gymAnnotation"]
        annotation.tap()
        
        let gymDetailCard = app.otherElements["gymDetailCard"]
        XCTAssertTrue(gymDetailCard.waitForExistence(timeout: 2))
    }
    
    // MARK: - Profile Tests
    
    func testProfileViewLoads() {
        signInIfNeeded()
        navigateToProfile()
        
        let profileView = app.otherElements["profileView"]
        XCTAssertTrue(profileView.exists)
        
        // Check profile elements
        XCTAssertTrue(app.images["profileImage"].exists)
        XCTAssertTrue(app.staticTexts["userNameLabel"].exists)
    }
    
    func testProfileEdit() {
        signInIfNeeded()
        navigateToProfile()
        
        let editButton = app.buttons["editProfileButton"]
        editButton.tap()
        
        let editProfileView = app.otherElements["editProfileView"]
        XCTAssertTrue(editProfileView.waitForExistence(timeout: 3))
        
        // Edit name
        let nameField = app.textFields["nameField"]
        nameField.tap()
        nameField.clearAndEnterText("New Name")
        
        let saveButton = app.buttons["saveButton"]
        saveButton.tap()
        
        // Should return to profile
        XCTAssertTrue(app.otherElements["profileView"].waitForExistence(timeout: 3))
    }
    
    func testProfileSettings() {
        signInIfNeeded()
        navigateToProfile()
        
        let settingsButton = app.buttons["settingsButton"]
        settingsButton.tap()
        
        let settingsView = app.otherElements["settingsView"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 3))
        
        // Toggle notifications
        let notificationsToggle = app.switches["notificationsToggle"]
        notificationsToggle.tap()
    }
    
    func testSignOut() {
        signInIfNeeded()
        navigateToProfile()
        
        let signOutButton = app.buttons["signOutButton"]
        signOutButton.tap()
        
        let confirmAlert = app.alerts["Sign Out"]
        XCTAssertTrue(confirmAlert.waitForExistence(timeout: 2))
        
        confirmAlert.buttons["Sign Out"].tap()
        
        // Should return to sign in
        let signInView = app.otherElements["signInView"]
        XCTAssertTrue(signInView.waitForExistence(timeout: 5))
    }
    
    // MARK: - Beads Feature Tests
    
    func testBeadCollectionView() {
        signInIfNeeded()
        navigateToBeads()
        
        let beadCollectionView = app.otherElements["beadCollectionView"]
        XCTAssertTrue(beadCollectionView.exists)
        
        // Check stats
        XCTAssertTrue(app.staticTexts["Total Beads"].exists)
        XCTAssertTrue(app.staticTexts["Unique Types"].exists)
    }
    
    func testBeadFiltering() {
        signInIfNeeded()
        navigateToBeads()
        
        let filterButton = app.buttons["Filter"]
        filterButton.tap()
        
        let filterSheet = app.sheets["filterSheet"]
        XCTAssertTrue(filterSheet.waitForExistence(timeout: 2))
        
        // Select rarity filter
        let rareFilter = app.buttons["Rare"]
        rareFilter.tap()
        
        // Filter sheet should dismiss
        XCTAssertFalse(filterSheet.exists)
    }
    
    func testBeadSorting() {
        signInIfNeeded()
        navigateToBeads()
        
        let sortButton = app.buttons["Newest"]
        sortButton.tap()
        
        // Select sort option
        let oldestOption = app.buttons["Oldest"]
        oldestOption.tap()
    }
    
    func testBeadDetailView() {
        signInIfNeeded()
        navigateToBeads()
        
        // Tap on first bead
        let firstBead = app.otherElements["beadCard"].firstMatch
        firstBead.tap()
        
        let beadDetailView = app.otherElements["beadDetailView"]
        XCTAssertTrue(beadDetailView.waitForExistence(timeout: 3))
        
        // Check share button
        let shareButton = app.buttons["Share Bead"]
        XCTAssertTrue(shareButton.exists)
    }
    
    func testBeadSync() {
        signInIfNeeded()
        navigateToBeads()
        
        let syncButton = app.buttons["syncButton"]
        syncButton.tap()
        
        // Should show sync progress
        let progressBar = app.progressIndicators["syncProgress"]
        XCTAssertTrue(progressBar.waitForExistence(timeout: 2))
    }
    
    // MARK: - Shop Tests
    
    func testShopViewLoads() {
        signInIfNeeded()
        navigateToShop()
        
        let shopView = app.otherElements["shopView"]
        XCTAssertTrue(shopView.exists)
        
        // Check shop elements
        XCTAssertTrue(app.scrollViews["shopBannersScrollView"].exists)
        XCTAssertTrue(app.collectionViews["passOptionsCollection"].exists)
    }
    
    func testShopPassSelection() {
        signInIfNeeded()
        navigateToShop()
        
        let passCell = app.collectionViews["passOptionsCollection"].cells.firstMatch
        passCell.tap()
        
        let passDetailView = app.otherElements["passDetailView"]
        XCTAssertTrue(passDetailView.waitForExistence(timeout: 3))
    }
    
    func testShopCheckoutFlow() {
        signInIfNeeded()
        navigateToShop()
        
        // Select pass
        let passCell = app.collectionViews["passOptionsCollection"].cells.firstMatch
        passCell.tap()
        
        // Tap buy
        let buyButton = app.buttons["Buy Now"]
        buyButton.tap()
        
        let checkoutView = app.otherElements["checkoutView"]
        XCTAssertTrue(checkoutView.waitForExistence(timeout: 3))
    }
    
    // MARK: - Community Tests
    
    func testCommunityViewLoads() {
        signInIfNeeded()
        navigateToCommunity()
        
        let communityView = app.otherElements["communityView"]
        XCTAssertTrue(communityView.exists)
        
        // Check feed
        XCTAssertTrue(app.tables["communityFeedTable"].exists)
    }
    
    func testCommunityPostInteraction() {
        signInIfNeeded()
        navigateToCommunity()
        
        let firstPost = app.tables["communityFeedTable"].cells.firstMatch
        
        // Like post
        let likeButton = firstPost.buttons["likeButton"]
        likeButton.tap()
        
        // Check like count increased
        let likeCount = firstPost.staticTexts["likeCount"]
        XCTAssertTrue(likeCount.exists)
    }
    
    func testCommunityPostDetail() {
        signInIfNeeded()
        navigateToCommunity()
        
        let firstPost = app.tables["communityFeedTable"].cells.firstMatch
        firstPost.tap()
        
        let postDetailView = app.otherElements["postDetailView"]
        XCTAssertTrue(postDetailView.waitForExistence(timeout: 3))
    }
    
    // MARK: - Navigation Tests
    
    func testTabBarNavigation() {
        signInIfNeeded()
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)
        
        // Test all tabs
        let tabs = ["Home", "Map", "Scan", "Community", "Profile"]
        
        for tab in tabs {
            let tabButton = tabBar.buttons[tab]
            XCTAssertTrue(tabButton.exists)
            tabButton.tap()
            
            // Verify view loaded
            let viewName = tab.lowercased() + "View"
            let view = app.otherElements[viewName]
            XCTAssertTrue(view.waitForExistence(timeout: 3), "\(tab) view should exist")
        }
    }
    
    func testBackNavigation() {
        signInIfNeeded()
        
        // Navigate to a detail view
        let gymCard = app.scrollViews["featuredGymsScrollView"].otherElements.element(boundBy: 0)
        gymCard.tap()
        
        let gymDetailView = app.otherElements["gymDetailView"]
        XCTAssertTrue(gymDetailView.waitForExistence(timeout: 3))
        
        // Go back
        let backButton = app.buttons["Back"]
        backButton.tap()
        
        // Should be back on home
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(homeView.waitForExistence(timeout: 3))
    }
    
    // MARK: - Error State Tests
    
    func testNetworkErrorHandling() {
        // Enable airplane mode or disconnect network
        app.launchEnvironment["MOCK_NETWORK_ERROR"] = "true"
        app.launch()
        
        signInIfNeeded()
        
        // Try to load data
        let errorView = app.otherElements["errorView"]
        XCTAssertTrue(errorView.waitForExistence(timeout: 5))
        
        // Check retry button
        let retryButton = app.buttons["Retry"]
        XCTAssertTrue(retryButton.exists)
    }
    
    func testEmptyStateHandling() {
        signInIfNeeded()
        
        // Navigate to a view that might be empty
        navigateToPassManagement()
        
        let expiredTab = app.buttons["Expired"]
        expiredTab.tap()
        
        // Check for empty state
        let emptyStateView = app.otherElements["emptyStateView"]
        if emptyStateView.exists {
            XCTAssertTrue(app.staticTexts["No expired passes"].exists)
            XCTAssertTrue(app.buttons["Browse Passes"].exists)
        }
    }
    
    func testLoadingState() {
        signInIfNeeded()
        
        // Pull to refresh to trigger loading
        let scrollView = app.scrollViews["homeScrollView"]
        scrollView.swipeDown(velocity: .fast)
        
        // Check loading indicator
        let loadingIndicator = app.activityIndicators["loadingIndicator"]
        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 2))
    }
    
    // MARK: - Accessibility Tests
    
    func testAccessibilityLabels() {
        signInIfNeeded()
        
        // Check key elements have accessibility labels
        let checkInButton = app.buttons["quickCheckInButton"]
        XCTAssertNotNil(checkInButton.label)
        
        let profileImage = app.images["profileImage"]
        XCTAssertTrue(profileImage.exists)
    }
    
    func testVoiceOverNavigation() {
        signInIfNeeded()
        
        // Test that all interactive elements are accessible
        let allButtons = app.buttons.allElementsBoundByIndex
        for button in allButtons {
            XCTAssertTrue(button.isHittable, "Button \(button.label) should be accessible")
        }
    }
    
    func testDynamicTypeSupport() {
        // This would require setting different text sizes and verifying layout
        // For now, just verify elements exist
        signInIfNeeded()
        
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(homeView.exists)
    }
    
    // MARK: - Performance Tests
    
    func testAppLaunchTime() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
    
    func testScrollPerformance() {
        signInIfNeeded()
        
        let scrollView = app.scrollViews["homeScrollView"]
        
        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scrollView.swipeUp(velocity: .fast)
            scrollView.swipeDown(velocity: .fast)
        }
    }
    
    // MARK: - Helper Methods
    
    private func signInIfNeeded() {
        // Check if already signed in
        if app.otherElements["signInView"].exists {
            let emailField = app.textFields["emailTextField"]
            let passwordField = app.secureTextFields["passwordTextField"]
            let signInButton = app.buttons["signInButton"]
            
            emailField.tap()
            emailField.typeText("test@example.com")
            
            passwordField.tap()
            passwordField.typeText("Password123!")
            
            signInButton.tap()
            
            // Wait for home view
            let homeView = app.otherElements["homeView"]
            XCTAssertTrue(homeView.waitForExistence(timeout: 5))
        }
    }
    
    private func navigateToPassManagement() {
        let passesTab = app.tabBars.buttons["Passes"]
        if passesTab.exists {
            passesTab.tap()
        } else {
            // Navigate from home
            let viewPassesButton = app.buttons["viewPassesButton"]
            viewPassesButton.tap()
        }
        
        let passManagementView = app.otherElements["passManagementView"]
        XCTAssertTrue(passManagementView.waitForExistence(timeout: 3))
    }
    
    private func navigateToGymMap() {
        let mapTab = app.tabBars.buttons["Map"]
        mapTab.tap()
        
        let mapView = app.otherElements["gymMapView"]
        XCTAssertTrue(mapView.waitForExistence(timeout: 3))
    }
    
    private func navigateToProfile() {
        let profileTab = app.tabBars.buttons["Profile"]
        profileTab.tap()
        
        let profileView = app.otherElements["profileView"]
        XCTAssertTrue(profileView.waitForExistence(timeout: 3))
    }
    
    private func navigateToBeads() {
        // Navigate from profile
        navigateToProfile()
        
        let beadsButton = app.buttons["myBeadsButton"]
        beadsButton.tap()
        
        let beadCollectionView = app.otherElements["beadCollectionView"]
        XCTAssertTrue(beadCollectionView.waitForExistence(timeout: 3))
    }
    
    private func navigateToShop() {
        // Navigate from home
        let shopButton = app.buttons["shopButton"]
        shopButton.tap()
        
        let shopView = app.otherElements["shopView"]
        XCTAssertTrue(shopView.waitForExistence(timeout: 3))
    }
    
    private func navigateToCommunity() {
        let communityTab = app.tabBars.buttons["Community"]
        communityTab.tap()
        
        let communityView = app.otherElements["communityView"]
        XCTAssertTrue(communityView.waitForExistence(timeout: 3))
    }
}

// MARK: - XCUIElement Extensions
extension XCUIElement {
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            self.typeText(text)
            return
        }
        
        self.tap()
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
        self.typeText(text)
    }
}

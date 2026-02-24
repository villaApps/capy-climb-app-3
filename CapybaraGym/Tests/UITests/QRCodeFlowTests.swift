// MARK: - QR Code Flow UI Tests
// Comprehensive UI tests for QR code flows following TDD principles

import XCTest

// MARK: - QR Code Flow Tests
/// UI tests covering complete QR code user journeys
final class QRCodeFlowTests: XCTestCase {
    
    // MARK: - Properties
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure app for testing with authenticated user and active pass
        app.launchArguments = ["--uitesting", "--authenticated", "--active-pass"]
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }
    
    // MARK: - QR Code Display Tests
    
    /// Test: QR code displayed for active pass
    func test_qrCode_displayedForActivePass() {
        // Given - Navigate to Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap on active pass
        app.buttons["Active Pass Card"].tap()
        
        // Then - QR code should be displayed
        XCTAssertTrue(app.images["QR Code"].waitForExistence(timeout: 2.0))
    }
    
    /// Test: QR code screen shows timer
    func test_qrCode_showsTimer() {
        // Given - Navigate to QR code
        navigateToQRCode()
        
        // Then - Timer should be visible
        XCTAssertTrue(app.staticTexts["Expires in"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label MATCHES '^[0-9]{2}:[0-9]{2}$'")).firstMatch.exists)
    }
    
    /// Test: QR code screen shows gym access info
    func test_qrCode_showsGymAccessInfo() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Then - Access info should be visible
        XCTAssertTrue(app.staticTexts["Valid at all locations"].exists)
        XCTAssertTrue(app.staticTexts["Show this code at the entrance"].exists)
    }
    
    /// Test: QR code can be refreshed
    func test_qrCode_refreshUpdatesCode() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Capture initial QR code
        let qrCode = app.images["QR Code"]
        XCTAssertTrue(qrCode.exists)
        
        // When - Tap refresh button
        app.buttons["Refresh"].tap()
        
        // Then - Timer should reset
        XCTAssertTrue(app.staticTexts["05:00"].waitForExistence(timeout: 2.0))
    }
    
    /// Test: QR code automatically refreshes when expired
    func test_qrCode_autoRefreshesWhenExpired() {
        // Given - On QR code screen with short expiration
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--active-pass", "--short-qr-expiration"]
        app.launch()
        navigateToQRCode()
        
        // When - Wait for expiration
        let expiredText = app.staticTexts["QR Code Expired"]
        let exists = expiredText.waitForExistence(timeout: 10.0)
        
        // Then - Expired message should appear with refresh option
        XCTAssertTrue(exists)
        XCTAssertTrue(app.buttons["Generate New Code"].exists)
    }
    
    // MARK: - QR Code Scanning Tests
    
    /// Test: Scan QR code button exists
    func test_qrCode_scanButtonExists() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Then - Scan button should exist
        XCTAssertTrue(app.buttons["Scan QR Code"].exists)
    }
    
    /// Test: Tap scan button opens camera
    func test_qrCode_scanOpensCamera() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // When - Tap scan button
        app.buttons["Scan QR Code"].tap()
        
        // Then - Camera view should appear
        XCTAssertTrue(app.otherElements["Camera View"].waitForExistence(timeout: 2.0))
    }
    
    /// Test: Cancel scanning dismisses camera
    func test_qrCode_cancelScanningDismissesCamera() {
        // Given - Camera is open
        navigateToQRCode()
        app.buttons["Scan QR Code"].tap()
        _ = app.otherElements["Camera View"].waitForExistence(timeout: 2.0)
        
        // When - Tap cancel
        app.buttons["Cancel"].tap()
        
        // Then - Camera should be dismissed
        XCTAssertFalse(app.otherElements["Camera View"].exists)
    }
    
    // MARK: - Check-In Tests
    
    /// Test: Successful check-in shows confirmation
    func test_checkIn_success_showsConfirmation() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // When - Simulate successful check-in (via test helper)
        app.buttons["Simulate Check-in"].tap()
        
        // Then - Success message should appear
        XCTAssertTrue(app.staticTexts["Check-in Successful!"].waitForExistence(timeout: 3.0))
        XCTAssertTrue(app.staticTexts["Downtown Capybara Fitness"].exists)
    }
    
    /// Test: Check-in success shows timestamp
    func test_checkIn_successShowsTimestamp() {
        // Given - Simulating check-in
        navigateToQRCode()
        app.buttons["Simulate Check-in"].tap()
        
        // Then - Timestamp should be visible
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Checked in at'")).firstMatch.waitForExistence(timeout: 3.0))
    }
    
    /// Test: Dismiss check-in success
    func test_checkIn_dismissSuccess() {
        // Given - Check-in success is showing
        navigateToQRCode()
        app.buttons["Simulate Check-in"].tap()
        _ = app.staticTexts["Check-in Successful!"].waitForExistence(timeout: 3.0)
        
        // When - Tap dismiss
        app.buttons["Done"].tap()
        
        // Then - Success message should be dismissed
        XCTAssertFalse(app.staticTexts["Check-in Successful!"].exists)
    }
    
    /// Test: Failed check-in shows error
    func test_checkIn_failure_showsError() {
        // Given - Launch with expired pass
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--expired-pass"]
        app.launch()
        navigateToQRCode()
        
        // When - Attempt check-in
        app.buttons["Simulate Check-in"].tap()
        
        // Then - Error message should appear
        XCTAssertTrue(app.staticTexts["Check-in Failed"].waitForExistence(timeout: 3.0))
        XCTAssertTrue(app.staticTexts["Pass has expired"].exists)
    }
    
    // MARK: - QR Code Expiration Tests
    
    /// Test: Timer counts down
    func test_timer_countsDown() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Capture initial time
        let initialTimeLabel = app.staticTexts.matching(NSPredicate(format: "label MATCHES '^[0-9]{2}:[0-9]{2}$'")).firstMatch
        let initialTime = initialTimeLabel.label
        
        // When - Wait a few seconds
        sleep(3)
        
        // Then - Time should have decreased
        let newTime = initialTimeLabel.label
        XCTAssertNotEqual(initialTime, newTime)
    }
    
    /// Test: Expiration warning shown at 30 seconds
    func test_expirationWarning_at30Seconds() {
        // Given - QR code with 30 seconds remaining
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--active-pass", "--qr-30-seconds"]
        app.launch()
        navigateToQRCode()
        
        // Then - Warning should be visible
        XCTAssertTrue(app.staticTexts["Expiring soon!"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.images["exclamationmark.triangle"].exists)
    }
    
    /// Test: Refresh button disabled while loading
    func test_refreshButton_disabledWhileLoading() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // When - Tap refresh
        app.buttons["Refresh"].tap()
        
        // Then - Button should be disabled during refresh
        let refreshButton = app.buttons["Refresh"]
        XCTAssertFalse(refreshButton.isEnabled)
    }
    
    // MARK: - Full Screen QR Code Tests
    
    /// Test: Tap QR code opens full screen
    func test_qrCode_tapOpensFullScreen() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // When - Tap QR code
        app.images["QR Code"].tap()
        
        // Then - Full screen view should appear
        XCTAssertTrue(app.otherElements["Full Screen QR"].waitForExistence(timeout: 2.0))
    }
    
    /// Test: Full screen QR shows brightness boost
    func test_fullScreen_showsBrightnessBoost() {
        // Given - Full screen QR is open
        navigateToQRCode()
        app.images["QR Code"].tap()
        _ = app.otherElements["Full Screen QR"].waitForExistence(timeout: 2.0)
        
        // Then - Brightness indicator should be visible
        XCTAssertTrue(app.staticTexts["Screen brightness increased"].exists)
    }
    
    /// Test: Tap to close full screen
    func test_fullScreen_tapToClose() {
        // Given - Full screen QR is open
        navigateToQRCode()
        app.images["QR Code"].tap()
        _ = app.otherElements["Full Screen QR"].waitForExistence(timeout: 2.0)
        
        // When - Tap to close
        app.otherElements["Full Screen QR"].tap()
        
        // Then - Full screen should be dismissed
        XCTAssertFalse(app.otherElements["Full Screen QR"].exists)
    }
    
    // MARK: - Gym Selection Tests
    
    /// Test: QR code shows selected gym
    func test_qrCode_showsSelectedGym() {
        // Given - User has selected a gym
        app.tabBars.buttons["Home"].tap()
        app.buttons["Downtown Capybara Fitness"].tap()
        
        // When - Navigate to QR code
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // Then - Selected gym should be shown
        XCTAssertTrue(app.staticTexts["Checking in at:"].exists)
        XCTAssertTrue(app.staticTexts["Downtown Capybara Fitness"].exists)
    }
    
    /// Test: Change gym selection
    func test_qrCode_changeGymSelection() {
        // Given - On QR code screen with gym selected
        navigateToQRCode()
        
        // When - Tap change gym
        app.buttons["Change Gym"].tap()
        
        // Then - Gym selector should appear
        XCTAssertTrue(app.staticTexts["Select Location"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Accessibility Tests
    
    /// Test: QR code has accessibility label
    func test_accessibility_qrCodeHasLabel() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Then - QR code should have accessibility label
        let qrCode = app.images["QR Code"]
        XCTAssertTrue(qrCode.exists)
        XCTAssertEqual(qrCode.label, "Your check-in QR code")
    }
    
    /// Test: Timer is accessible
    func test_accessibility_timerIsAccessible() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Then - Timer should be accessible
        XCTAssertTrue(app.staticTexts["Expires in 5 minutes"].exists)
    }
    
    /// Test: Refresh button is accessible
    func test_accessibility_refreshButton() {
        // Given - On QR code screen
        navigateToQRCode()
        
        // Then - Refresh button should be accessible
        let refreshButton = app.buttons["Refresh"]
        XCTAssertTrue(refreshButton.exists)
        XCTAssertEqual(refreshButton.label, "Generate new QR code")
    }
    
    // MARK: - Error Handling Tests
    
    /// Test: Network error shows retry option
    func test_networkError_showsRetry() {
        // Given - Launch with network error
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--active-pass", "--network-error"]
        app.launch()
        navigateToQRCode()
        
        // Then - Error and retry should be visible
        XCTAssertTrue(app.staticTexts["Failed to generate QR code"].waitForExistence(timeout: 3.0))
        XCTAssertTrue(app.buttons["Try Again"].exists)
    }
    
    /// Test: Retry generates new QR code
    func test_retry_generatesNewCode() {
        // Given - Network error is showing
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--active-pass", "--network-error"]
        app.launch()
        navigateToQRCode()
        _ = app.staticTexts["Failed to generate QR code"].waitForExistence(timeout: 3.0)
        
        // When - Tap retry
        app.buttons["Try Again"].tap()
        
        // Then - QR code should appear
        XCTAssertTrue(app.images["QR Code"].waitForExistence(timeout: 3.0))
    }
    
    // MARK: - No Pass State Tests
    
    /// Test: QR code not shown without pass
    func test_noPass_qrCodeNotShown() {
        // Given - Launch without pass
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--no-passes"]
        app.launch()
        
        // When - Navigate to Passes
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Get pass button should be shown instead of QR
        XCTAssertTrue(app.buttons["Get Your First Pass"].exists)
        XCTAssertFalse(app.images["QR Code"].exists)
    }
    
    // MARK: - Helper Methods
    
    private func navigateToQRCode() {
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        _ = app.images["QR Code"].waitForExistence(timeout: 2.0)
    }
}

// MARK: - Accessibility Identifiers

extension XCUIElementQuery {
    func matching(identifier: String) -> XCUIElementQuery {
        return self.matching(NSPredicate(format: "identifier == %@", identifier))
    }
}

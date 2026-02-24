// MARK: - Pass Management Flow UI Tests
// Comprehensive UI tests for pass management flows following TDD principles

import XCTest

// MARK: - Pass Management Flow Tests
/// UI tests covering complete pass management user journeys
final class PassManagementFlowTests: XCTestCase {
    
    // MARK: - Properties
    private var app: XCUIApplication!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configure app for testing with authenticated user
        app.launchArguments = ["--uitesting", "--authenticated", "--mock-data"]
        app.launch()
    }
    
    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }
    
    // MARK: - Pass List Tests
    
    /// Test: Pass list displays active pass
    func test_passList_displaysActivePass() {
        // Given - Navigate to Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Active pass should be displayed
        XCTAssertTrue(app.staticTexts["Active Pass"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Standard Pass"].exists)
    }
    
    /// Test: Pass list displays pass details
    func test_passList_displaysPassDetails() {
        // Given - Navigate to Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Pass details should be visible
        XCTAssertTrue(app.staticTexts["Days Remaining"].exists)
        XCTAssertTrue(app.staticTexts["Total Check-ins"].exists)
        XCTAssertTrue(app.staticTexts["Auto-renew"].exists)
    }
    
    /// Test: Tap on pass shows details
    func test_passList_tapPass_showsDetails() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap on active pass
        app.buttons["Active Pass Card"].tap()
        
        // Then - Pass details sheet should appear
        XCTAssertTrue(app.staticTexts["Pass Details"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Valid Until"].exists)
    }
    
    /// Test: Pull to refresh updates pass list
    func test_passList_pullToRefresh_updatesList() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Pull to refresh
        let passList = app.scrollViews["Pass List"]
        passList.swipeDown()
        
        // Then - Loading indicator should appear
        XCTAssertTrue(app.progressIndicators.firstMatch.waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Create Pass Tests
    
    /// Test: User can create a new pass
    func test_createPass_completesSuccessfully() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap create pass button
        app.buttons["Get a Pass"].tap()
        
        // Then - Pass type selection should appear
        XCTAssertTrue(app.staticTexts["Choose Your Pass"].waitForExistence(timeout: 2.0))
        
        // When - Select Standard pass
        app.buttons["Standard Pass"].tap()
        
        // Then - Duration selection should appear
        XCTAssertTrue(app.staticTexts["Select Duration"].exists)
        
        // When - Select 1 month
        app.buttons["1 Month"].tap()
        
        // Then - Payment screen should appear
        XCTAssertTrue(app.staticTexts["Payment"].waitForExistence(timeout: 2.0))
        
        // When - Complete payment
        app.buttons["Pay $49.99"].tap()
        
        // Then - Success message should appear
        XCTAssertTrue(app.staticTexts["Pass Created!"].waitForExistence(timeout: 5.0))
    }
    
    /// Test: Pass type selection shows features
    func test_createPass_showsPassFeatures() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap create pass button
        app.buttons["Get a Pass"].tap()
        
        // Then - Pass features should be visible
        XCTAssertTrue(app.staticTexts["Gym access"].exists)
        XCTAssertTrue(app.staticTexts["Locker room"].exists)
        
        // When - Select Premium pass
        app.buttons["Premium Pass"].tap()
        
        // Then - Premium features should be visible
        XCTAssertTrue(app.staticTexts["Pool access"].exists)
        XCTAssertTrue(app.staticTexts["Sauna"].exists)
    }
    
    /// Test: Duration selection updates price
    func test_createPass_durationUpdatesPrice() {
        // Given - On create pass flow
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Get a Pass"].tap()
        app.buttons["Standard Pass"].tap()
        
        // Then - Default price for 1 month
        XCTAssertTrue(app.staticTexts["$49.99"].exists)
        
        // When - Select 3 months
        app.buttons["3 Months"].tap()
        
        // Then - Price should update with discount
        XCTAssertTrue(app.staticTexts["$134.97"].exists)
        XCTAssertTrue(app.staticTexts["Save 10%"].exists)
        
        // When - Select 1 year
        app.buttons["1 Year"].tap()
        
        // Then - Price should update with bigger discount
        XCTAssertTrue(app.staticTexts["Save 20%"].exists)
    }
    
    /// Test: Cancel create pass
    func test_createPass_cancel_dismissesSheet() {
        // Given - On create pass flow
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Get a Pass"].tap()
        
        // When - Tap cancel
        app.buttons["Cancel"].tap()
        
        // Then - Should return to pass list
        XCTAssertTrue(app.staticTexts["My Passes"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Renew Pass Tests
    
    /// Test: User can renew an expired pass
    func test_renewPass_completesSuccessfully() {
        // Given - On Passes tab with expired pass
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap on expired pass
        app.buttons["Expired Pass Card"].tap()
        
        // Then - Pass details should show renew option
        XCTAssertTrue(app.buttons["Renew Pass"].waitForExistence(timeout: 2.0))
        
        // When - Tap renew
        app.buttons["Renew Pass"].tap()
        
        // Then - Confirmation dialog should appear
        XCTAssertTrue(app.staticTexts["Renew Pass?"].waitForExistence(timeout: 2.0))
        
        // When - Confirm renewal
        app.buttons["Confirm"].tap()
        
        // Then - Payment screen should appear
        XCTAssertTrue(app.staticTexts["Payment"].waitForExistence(timeout: 2.0))
        
        // When - Complete payment
        app.buttons["Pay"].tap()
        
        // Then - Success message should appear
        XCTAssertTrue(app.staticTexts["Pass Renewed!"].waitForExistence(timeout: 5.0))
    }
    
    /// Test: Cancel renew pass
    func test_renewPass_cancel_dismissesDialog() {
        // Given - On pass details with renew option
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Expired Pass Card"].tap()
        app.buttons["Renew Pass"].tap()
        
        // When - Tap cancel
        app.buttons["Cancel"].tap()
        
        // Then - Dialog should be dismissed
        XCTAssertFalse(app.staticTexts["Renew Pass?"].exists)
    }
    
    // MARK: - Cancel Pass Tests
    
    /// Test: User can cancel active pass
    func test_cancelPass_completesSuccessfully() {
        // Given - On Passes tab with active pass
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap on active pass
        app.buttons["Active Pass Card"].tap()
        
        // Then - Cancel option should be available
        XCTAssertTrue(app.buttons["Cancel Pass"].exists)
        
        // When - Tap cancel pass
        app.buttons["Cancel Pass"].tap()
        
        // Then - Confirmation dialog should appear
        XCTAssertTrue(app.staticTexts["Cancel Pass?"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["This action cannot be undone"].exists)
        
        // When - Confirm cancellation
        app.buttons["Yes, Cancel Pass"].tap()
        
        // Then - Success message should appear
        XCTAssertTrue(app.staticTexts["Pass Cancelled"].waitForExistence(timeout: 5.0))
    }
    
    /// Test: Cancel cancellation
    func test_cancelPass_cancelKeepsPassActive() {
        // Given - On cancel confirmation dialog
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        app.buttons["Cancel Pass"].tap()
        
        // When - Tap "Keep Pass"
        app.buttons["Keep Pass"].tap()
        
        // Then - Dialog should be dismissed, pass still active
        XCTAssertFalse(app.staticTexts["Cancel Pass?"].exists)
        XCTAssertTrue(app.staticTexts["Active Pass"].exists)
    }
    
    // MARK: - Check-In History Tests
    
    /// Test: Check-in history displayed
    func test_checkInHistory_displaysRecords() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap on active pass
        app.buttons["Active Pass Card"].tap()
        
        // Then - Check-in history should be visible
        XCTAssertTrue(app.staticTexts["Recent Check-ins"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.cells["Check-in Record"].exists)
    }
    
    /// Test: Check-in history shows gym name and date
    func test_checkInHistory_showsDetails() {
        // Given - On pass details
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // Then - Check-in details should be visible
        XCTAssertTrue(app.staticTexts["Downtown Capybara Fitness"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'days ago'")).firstMatch.exists)
    }
    
    /// Test: View all check-ins
    func test_checkInHistory_viewAllShowsFullList() {
        // Given - On pass details
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // When - Tap "View All"
        app.buttons["View All"].tap()
        
        // Then - Full check-in history should appear
        XCTAssertTrue(app.staticTexts["Check-in History"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.tables["Check-in History List"].exists)
    }
    
    // MARK: - Pass Status Tests
    
    /// Test: Active pass shows correct status
    func test_passStatus_activePass() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Active pass should show status
        XCTAssertTrue(app.staticTexts["Active"].exists)
        XCTAssertTrue(app.images["checkmark.circle.fill"].exists)
    }
    
    /// Test: Expired pass shows correct status
    func test_passStatus_expiredPass() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Expired pass should show status
        XCTAssertTrue(app.staticTexts["Expired"].exists)
        XCTAssertTrue(app.images["xmark.circle.fill"].exists)
    }
    
    /// Test: Days remaining displayed for active pass
    func test_passStatus_daysRemaining() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Days remaining should be visible
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'days remaining'")).firstMatch.exists)
    }
    
    // MARK: - Auto-Renew Tests
    
    /// Test: Auto-renew toggle exists
    func test_autoRenew_toggleExists() {
        // Given - On pass details
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // Then - Auto-renew toggle should exist
        XCTAssertTrue(app.switches["Auto-renew"].exists)
    }
    
    /// Test: Toggle auto-renew
    func test_autoRenew_toggleChangesState() {
        // Given - On pass details
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // When - Toggle auto-renew
        let toggle = app.switches["Auto-renew"]
        let initialValue = toggle.value as? String
        toggle.tap()
        
        // Then - Toggle value should change
        let newValue = toggle.value as? String
        XCTAssertNotEqual(initialValue, newValue)
    }
    
    // MARK: - Empty State Tests
    
    /// Test: Empty state shown when no passes
    func test_emptyState_noPasses() {
        // Given - Launch with no passes
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--no-passes"]
        app.launch()
        
        // When - Navigate to Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Empty state should be shown
        XCTAssertTrue(app.staticTexts["No Passes Yet"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Get a pass to start your fitness journey"].exists)
        XCTAssertTrue(app.buttons["Get Your First Pass"].exists)
    }
    
    /// Test: Empty state button navigates to create pass
    func test_emptyState_buttonNavigatesToCreatePass() {
        // Given - On empty state
        app.terminate()
        app.launchArguments = ["--uitesting", "--authenticated", "--no-passes"]
        app.launch()
        app.tabBars.buttons["Passes"].tap()
        
        // When - Tap get first pass button
        app.buttons["Get Your First Pass"].tap()
        
        // Then - Should navigate to pass creation
        XCTAssertTrue(app.staticTexts["Choose Your Pass"].waitForExistence(timeout: 2.0))
    }
    
    // MARK: - Accessibility Tests
    
    /// Test: Pass list is accessible
    func test_accessibility_passList() {
        // Given - On Passes tab
        app.tabBars.buttons["Passes"].tap()
        
        // Then - Elements should have accessibility labels
        XCTAssertTrue(app.buttons["Active Pass Card"].exists)
        XCTAssertTrue(app.buttons["Get a Pass"].exists)
    }
    
    /// Test: Pass details are accessible
    func test_accessibility_passDetails() {
        // Given - On pass details
        app.tabBars.buttons["Passes"].tap()
        app.buttons["Active Pass Card"].tap()
        
        // Then - Details should be accessible
        XCTAssertTrue(app.staticTexts["Pass Details"].exists)
        XCTAssertTrue(app.buttons["Close"].exists)
    }
}

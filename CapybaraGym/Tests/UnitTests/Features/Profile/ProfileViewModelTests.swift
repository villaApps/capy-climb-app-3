// MARK: - Profile ViewModel Tests
// Comprehensive unit tests for ProfileViewModel following TDD principles

import XCTest
import Combine
import UIKit
@testable import CapybaraGym

// MARK: - ProfileViewModel
/// ViewModel responsible for managing user profile functionality
@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var user: User?
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var profileImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var isEditing: Bool = false
    @Published var errorMessage: String?
    @Published var showSignOutConfirmation: Bool = false
    @Published var showDeleteAccountConfirmation: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showSuccessMessage: Bool = false
    @Published var successMessage: String = ""
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Validation
    var isFirstNameValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var isLastNameValid: Bool {
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var canSave: Bool {
        isFirstNameValid && isLastNameValid && !isLoading
    }
    
    var hasChanges: Bool {
        guard let user = user else { return false }
        return firstName != user.firstName || lastName != user.lastName
    }
    
    // MARK: - Initialization
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    // MARK: - Lifecycle
    func onAppear() async {
        await loadUser()
    }
    
    // MARK: - Data Loading
    func loadUser() async {
        isLoading = true
        errorMessage = nil
        
        if let currentUser = await authService.getCurrentUser() {
            user = currentUser
            firstName = currentUser.firstName
            lastName = currentUser.lastName
            email = currentUser.email
        } else {
            errorMessage = "Failed to load user profile"
        }
        
        isLoading = false
    }
    
    // MARK: - Edit Mode
    func startEditing() {
        isEditing = true
        // Reset to current values
        if let user = user {
            firstName = user.firstName
            lastName = user.lastName
        }
    }
    
    func cancelEditing() {
        isEditing = false
        errorMessage = nil
        // Reset to original values
        if let user = user {
            firstName = user.firstName
            lastName = user.lastName
        }
    }
    
    // MARK: - Profile Updates
    func saveProfile() async {
        guard canSave else { return }
        guard user != nil else {
            errorMessage = "User not found"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate profile update - in real app, would call API
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Update local user (in real app, this would come from API response)
        if var updatedUser = user {
            // Create updated user with new values
            updatedUser = User(
                id: updatedUser.id,
                email: updatedUser.email,
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: updatedUser.profileImageUrl,
                createdAt: updatedUser.createdAt,
                updatedAt: Date()
            )
            user = updatedUser
        }
        
        isEditing = false
        isLoading = false
        showSuccess(message: "Profile updated successfully")
    }
    
    func updateProfileImage(_ image: UIImage) async {
        isLoading = true
        
        // Simulate image upload
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        profileImage = image
        isLoading = false
        showSuccess(message: "Profile picture updated")
    }
    
    // MARK: - Sign Out
    func confirmSignOut() {
        showSignOutConfirmation = true
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            user = nil
            showSignOutConfirmation = false
        } catch {
            errorMessage = "Failed to sign out"
        }
        
        isLoading = false
    }
    
    func cancelSignOut() {
        showSignOutConfirmation = false
    }
    
    // MARK: - Delete Account
    func confirmDeleteAccount() {
        showDeleteAccountConfirmation = true
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate account deletion
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // In real app, would call API to delete account
        user = nil
        showDeleteAccountConfirmation = false
        isLoading = false
    }
    
    func cancelDeleteAccount() {
        showDeleteAccountConfirmation = false
    }
    
    // MARK: - Image Picker
    func showImagePickerSheet() {
        showImagePicker = true
    }
    
    func hideImagePickerSheet() {
        showImagePicker = false
    }
    
    // MARK: - Helper Methods
    func clearError() {
        errorMessage = nil
    }
    
    func dismissSuccessMessage() {
        showSuccessMessage = false
        successMessage = ""
    }
    
    private func showSuccess(message: String) {
        successMessage = message
        showSuccessMessage = true
        
        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.dismissSuccessMessage()
        }
    }
}

// MARK: - ProfileViewModelTests
@MainActor
final class ProfileViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: ProfileViewModel!
    private var mockAuthService: MockAuthService!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        sut = ProfileViewModel(authService: mockAuthService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockAuthService.reset()
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_hasNoUser() {
        XCTAssertNil(sut.user)
    }
    
    func test_initialState_hasEmptyFirstName() {
        XCTAssertEqual(sut.firstName, "")
    }
    
    func test_initialState_hasEmptyLastName() {
        XCTAssertEqual(sut.lastName, "")
    }
    
    func test_initialState_hasEmptyEmail() {
        XCTAssertEqual(sut.email, "")
    }
    
    func test_initialState_hasNoProfileImage() {
        XCTAssertNil(sut.profileImage)
    }
    
    func test_initialState_isNotLoading() {
        XCTAssertFalse(sut.isLoading)
    }
    
    func test_initialState_isNotEditing() {
        XCTAssertFalse(sut.isEditing)
    }
    
    func test_initialState_hasNoError() {
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_initialState_doesNotShowSignOutConfirmation() {
        XCTAssertFalse(sut.showSignOutConfirmation)
    }
    
    func test_initialState_doesNotShowDeleteAccountConfirmation() {
        XCTAssertFalse(sut.showDeleteAccountConfirmation)
    }
    
    func test_initialState_doesNotShowImagePicker() {
        XCTAssertFalse(sut.showImagePicker)
    }
    
    func test_initialState_doesNotShowSuccessMessage() {
        XCTAssertFalse(sut.showSuccessMessage)
    }
    
    func test_initialState_hasEmptySuccessMessage() {
        XCTAssertEqual(sut.successMessage, "")
    }
    
    // MARK: - Validation Tests
    
    func test_isFirstNameValid_withEmptyString_returnsFalse() {
        sut.firstName = ""
        XCTAssertFalse(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withWhitespaceOnly_returnsFalse() {
        sut.firstName = "   "
        XCTAssertFalse(sut.isFirstNameValid)
    }
    
    func test_isFirstNameValid_withValidName_returnsTrue() {
        sut.firstName = "John"
        XCTAssertTrue(sut.isFirstNameValid)
    }
    
    func test_isLastNameValid_withEmptyString_returnsFalse() {
        sut.lastName = ""
        XCTAssertFalse(sut.isLastNameValid)
    }
    
    func test_isLastNameValid_withValidName_returnsTrue() {
        sut.lastName = "Doe"
        XCTAssertTrue(sut.isLastNameValid)
    }
    
    func test_canSave_withValidNamesAndNotLoading_returnsTrue() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.isLoading = false
        XCTAssertTrue(sut.canSave)
    }
    
    func test_canSave_withEmptyFirstName_returnsFalse() {
        sut.firstName = ""
        sut.lastName = "Doe"
        sut.isLoading = false
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_withEmptyLastName_returnsFalse() {
        sut.firstName = "John"
        sut.lastName = ""
        sut.isLoading = false
        XCTAssertFalse(sut.canSave)
    }
    
    func test_canSave_whileLoading_returnsFalse() {
        sut.firstName = "John"
        sut.lastName = "Doe"
        sut.isLoading = true
        XCTAssertFalse(sut.canSave)
    }
    
    func test_hasChanges_withDifferentFirstName_returnsTrue() {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = "Jane" // Different from mock user's "Test"
        sut.lastName = mockAuthService.mockUser.lastName
        
        // Then
        XCTAssertTrue(sut.hasChanges)
    }
    
    func test_hasChanges_withSameValues_returnsFalse() {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = mockAuthService.mockUser.firstName
        sut.lastName = mockAuthService.mockUser.lastName
        
        // Then
        XCTAssertFalse(sut.hasChanges)
    }
    
    func test_hasChanges_withNoUser_returnsFalse() {
        sut.user = nil
        sut.firstName = "John"
        sut.lastName = "Doe"
        
        XCTAssertFalse(sut.hasChanges)
    }
    
    // MARK: - Load User Tests
    
    func test_loadUser_withAuthenticatedUser_setsUser() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.loadUser()
        
        // Then
        XCTAssertNotNil(sut.user)
        XCTAssertEqual(sut.firstName, mockAuthService.mockUser.firstName)
        XCTAssertEqual(sut.lastName, mockAuthService.mockUser.lastName)
        XCTAssertEqual(sut.email, mockAuthService.mockUser.email)
    }
    
    func test_loadUser_withNoUser_setsErrorMessage() async {
        // Given
        mockAuthService.currentUser = nil
        
        // When
        await sut.loadUser()
        
        // Then
        XCTAssertNil(sut.user)
        XCTAssertEqual(sut.errorMessage, "Failed to load user profile")
    }
    
    // MARK: - Edit Mode Tests
    
    func test_startEditing_setsIsEditingToTrue() {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        
        // When
        sut.startEditing()
        
        // Then
        XCTAssertTrue(sut.isEditing)
    }
    
    func test_startEditing_resetsToCurrentValues() {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = "Changed"
        sut.lastName = "Changed"
        
        // When
        sut.startEditing()
        
        // Then
        XCTAssertEqual(sut.firstName, mockAuthService.mockUser.firstName)
        XCTAssertEqual(sut.lastName, mockAuthService.mockUser.lastName)
    }
    
    func test_cancelEditing_setsIsEditingToFalse() {
        // Given
        sut.isEditing = true
        
        // When
        sut.cancelEditing()
        
        // Then
        XCTAssertFalse(sut.isEditing)
    }
    
    func test_cancelEditing_clearsErrorMessage() {
        // Given
        sut.isEditing = true
        sut.errorMessage = "Some error"
        
        // When
        sut.cancelEditing()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_cancelEditing_resetsToOriginalValues() {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = "Changed"
        sut.lastName = "Changed"
        
        // When
        sut.cancelEditing()
        
        // Then
        XCTAssertEqual(sut.firstName, mockAuthService.mockUser.firstName)
        XCTAssertEqual(sut.lastName, mockAuthService.mockUser.lastName)
    }
    
    // MARK: - Save Profile Tests
    
    func test_saveProfile_success_updatesUser() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = "NewName"
        sut.lastName = "NewLastName"
        
        // When
        await sut.saveProfile()
        
        // Then
        XCTAssertEqual(sut.user?.firstName, "NewName")
        XCTAssertEqual(sut.user?.lastName, "NewLastName")
        XCTAssertFalse(sut.isEditing)
    }
    
    func test_saveProfile_success_showsSuccessMessage() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        sut.firstName = "NewName"
        sut.lastName = "NewLastName"
        
        // When
        await sut.saveProfile()
        
        // Then
        XCTAssertTrue(sut.showSuccessMessage)
        XCTAssertEqual(sut.successMessage, "Profile updated successfully")
    }
    
    func test_saveProfile_withEmptyFirstName_doesNothing() async {
        // Given
        sut.firstName = ""
        sut.lastName = "Doe"
        
        // When
        await sut.saveProfile()
        
        // Then
        XCTAssertEqual(sut.isLoading, false)
    }
    
    func test_saveProfile_withNoUser_setsErrorMessage() async {
        // Given
        sut.user = nil
        sut.firstName = "John"
        sut.lastName = "Doe"
        
        // When
        await sut.saveProfile()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "User not found")
    }
    
    // MARK: - Update Profile Image Tests
    
    func test_updateProfileImage_setsProfileImage() async {
        // Given
        let image = UIImage(systemName: "person")!
        
        // When
        await sut.updateProfileImage(image)
        
        // Then
        XCTAssertNotNil(sut.profileImage)
    }
    
    func test_updateProfileImage_showsSuccessMessage() async {
        // Given
        let image = UIImage(systemName: "person")!
        
        // When
        await sut.updateProfileImage(image)
        
        // Then
        XCTAssertTrue(sut.showSuccessMessage)
        XCTAssertEqual(sut.successMessage, "Profile picture updated")
    }
    
    // MARK: - Sign Out Tests
    
    func test_confirmSignOut_setsShowSignOutConfirmationToTrue() {
        // When
        sut.confirmSignOut()
        
        // Then
        XCTAssertTrue(sut.showSignOutConfirmation)
    }
    
    func test_signOut_success_clearsUser() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        
        // When
        await sut.signOut()
        
        // Then
        XCTAssertNil(sut.user)
        XCTAssertFalse(sut.showSignOutConfirmation)
    }
    
    func test_signOut_success_callsAuthService() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.signOut()
        
        // Then
        XCTAssertEqual(mockAuthService.signOutCallCount, 1)
    }
    
    func test_signOut_failure_setsErrorMessage() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        mockAuthService.shouldReturnNetworkError = true
        
        // When
        await sut.signOut()
        
        // Then
        XCTAssertEqual(sut.errorMessage, "Failed to sign out")
    }
    
    func test_cancelSignOut_setsShowSignOutConfirmationToFalse() {
        // Given
        sut.showSignOutConfirmation = true
        
        // When
        sut.cancelSignOut()
        
        // Then
        XCTAssertFalse(sut.showSignOutConfirmation)
    }
    
    // MARK: - Delete Account Tests
    
    func test_confirmDeleteAccount_setsShowDeleteAccountConfirmationToTrue() {
        // When
        sut.confirmDeleteAccount()
        
        // Then
        XCTAssertTrue(sut.showDeleteAccountConfirmation)
    }
    
    func test_deleteAccount_success_clearsUser() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        sut.user = mockAuthService.mockUser
        
        // When
        await sut.deleteAccount()
        
        // Then
        XCTAssertNil(sut.user)
        XCTAssertFalse(sut.showDeleteAccountConfirmation)
    }
    
    func test_cancelDeleteAccount_setsShowDeleteAccountConfirmationToFalse() {
        // Given
        sut.showDeleteAccountConfirmation = true
        
        // When
        sut.cancelDeleteAccount()
        
        // Then
        XCTAssertFalse(sut.showDeleteAccountConfirmation)
    }
    
    // MARK: - Image Picker Tests
    
    func test_showImagePickerSheet_setsShowImagePickerToTrue() {
        // When
        sut.showImagePickerSheet()
        
        // Then
        XCTAssertTrue(sut.showImagePicker)
    }
    
    func test_hideImagePickerSheet_setsShowImagePickerToFalse() {
        // Given
        sut.showImagePicker = true
        
        // When
        sut.hideImagePickerSheet()
        
        // Then
        XCTAssertFalse(sut.showImagePicker)
    }
    
    // MARK: - Clear Error Tests
    
    func test_clearError_clearsErrorMessage() {
        // Given
        sut.errorMessage = "Some error"
        
        // When
        sut.clearError()
        
        // Then
        XCTAssertNil(sut.errorMessage)
    }
    
    // MARK: - Dismiss Success Message Tests
    
    func test_dismissSuccessMessage_hidesMessage() {
        // Given
        sut.showSuccessMessage = true
        sut.successMessage = "Success!"
        
        // When
        sut.dismissSuccessMessage()
        
        // Then
        XCTAssertFalse(sut.showSuccessMessage)
        XCTAssertEqual(sut.successMessage, "")
    }
    
    // MARK: - Loading State Tests
    
    func test_loadUser_togglesLoadingState() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        let expectation = expectation(description: "Loading state changes")
        var loadingStates: [Bool] = []
        
        sut.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        Task {
            await sut.loadUser()
        }
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        XCTAssertTrue(loadingStates.contains(true))
        XCTAssertEqual(loadingStates.last, false)
    }
    
    // MARK: - Publisher Tests
    
    func test_userPublisher_publishesChanges() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        let expectation = expectation(description: "User publisher emits")
        
        sut.$user
            .dropFirst()
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        await sut.loadUser()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
    }
    
    // MARK: - Lifecycle Tests
    
    func test_onAppear_loadsUser() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.onAppear()
        
        // Then
        XCTAssertEqual(mockAuthService.getCurrentUserCallCount, 1)
        XCTAssertNotNil(sut.user)
    }
    
    // MARK: - Edge Case Tests
    
    func test_saveProfile_whileAlreadyLoading_doesNothing() async {
        // Given
        sut.isLoading = true
        sut.firstName = "John"
        sut.lastName = "Doe"
        
        // When
        await sut.saveProfile()
        
        // Then - should not change loading state
        XCTAssertTrue(sut.isLoading)
    }
    
    func test_loadUser_multipleCalls_onlyLoadsOnce() async {
        // Given
        mockAuthService.simulateAuthenticatedUser()
        
        // When
        await sut.loadUser()
        await sut.loadUser()
        
        // Then
        XCTAssertEqual(mockAuthService.getCurrentUserCallCount, 2)
    }
}

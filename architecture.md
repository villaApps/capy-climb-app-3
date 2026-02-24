# Capybara Wellness App - iOS Architecture Design

## Executive Summary

This document outlines the comprehensive architecture for the Capybara-themed wellness/mental health iOS application. The architecture follows **MVVM with Clean Architecture principles**, optimized for AWS Amplify Gen 2 backend integration, with a focus on testability, maintainability, and scalability.

---

## 1. Architecture Decision: MVVM + Clean Architecture Hybrid

### 1.1 Why This Architecture?

| Criterion | MVVM | Clean Arch | Our Hybrid |
|-----------|------|------------|------------|
| Testability | Good | Excellent | Excellent |
| Complexity | Low | High | Medium |
| SwiftUI Compatibility | Excellent | Good | Excellent |
| Amplify Integration | Good | Good | Excellent |
| Team Onboarding | Easy | Hard | Medium |
| Maintainability | Good | Excellent | Excellent |

### 1.2 Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Views    │  │  ViewModels │  │   State Containers  │  │
│  │  (SwiftUI)  │◄─┤  (Observable)│◄─┤  (@Observable)      │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Use Cases │  │   Entities  │  │ Repository Protocols│  │
│  │  (Business) │  │   (Models)  │  │    (Interfaces)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Repositories│  │ Data Sources│  │   DTOs/Mappers      │  │
│  │ (Implement) │  │(Remote/Local│  │   (Transform)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   INFRASTRUCTURE LAYER                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   AWS       │  │   Local     │  │   Third-Party       │  │
│  │  Amplify    │  │   CoreData  │  │   Services          │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Project Folder Structure

```
CapybaraWellness/
├── 📁 App/
│   ├── CapybaraWellnessApp.swift          # App Entry Point
│   ├── AppDelegate.swift                  # Lifecycle & Notifications
│   ├── Info.plist
│   └── 📁 Resources/
│       ├── Assets.xcassets
│       ├── Localizable.strings
│       └── LaunchScreen.storyboard
│
├── 📁 Core/
│   ├── 📁 Architecture/
│   │   ├── BaseViewModel.swift            # Observable base class
│   │   ├── ViewState.swift                # Loading/Error/Success states
│   │   └── UseCase.swift                  # Use case protocol
│   │
│   ├── 📁 DI/
│   │   ├── DependencyContainer.swift      # DI Container
│   │   └── DependencyKeys.swift           # Injection keys
│   │
│   ├── 📁 Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── String+Extensions.swift
│   │   └── View+Extensions.swift
│   │
│   ├── 📁 Utilities/
│   │   ├── Logger.swift                   # Unified logging
│   │   ├── Constants.swift                # App constants
│   │   └── Validators.swift               # Input validation
│   │
│   └── 📁 DesignSystem/
│       ├── 📁 Components/
│       │   ├── CapyButton.swift
│       │   ├── CapyCard.swift
│       │   ├── CapyTextField.swift
│       │   └── CapyProgressRing.swift
│       ├── 📁 Theme/
│       │   ├── Colors.swift
│       │   ├── Typography.swift
│       │   └── Spacing.swift
│       └── 📁 Animations/
│           └── CapyAnimations.swift
│
├── 📁 Features/
│   ├── 📁 Authentication/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   └── User.swift
│   │   │   ├── UseCases/
│   │   │   │   ├── SignInUseCase.swift
│   │   │   │   ├── SignUpUseCase.swift
│   │   │   │   ├── SignOutUseCase.swift
│   │   │   │   └── ResetPasswordUseCase.swift
│   │   │   └── RepositoryProtocols/
│   │   │       └── AuthRepositoryProtocol.swift
│   │   ├── 📁 Data/
│   │   │   ├── Repositories/
│   │   │   │   └── AuthRepository.swift
│   │   │   ├── DataSources/
│   │   │   │   └── AuthRemoteDataSource.swift
│   │   │   └── Mappers/
│   │   │       └── UserMapper.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── 📁 SignIn/
│   │   │   │   ├── SignInView.swift
│   │   │   │   ├── SignInViewModel.swift
│   │   │   │   └── SignInState.swift
│   │   │   ├── 📁 SignUp/
│   │   │   │   ├── SignUpView.swift
│   │   │   │   ├── SignUpViewModel.swift
│   │   │   │   └── SignUpState.swift
│   │   │   └── 📁 Components/
│   │   │       └── AuthTextField.swift
│   │   └── 📁 Tests/
│   │       ├── SignInViewModelTests.swift
│   │       └── AuthRepositoryTests.swift
│   │
│   ├── 📁 Home/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── DailyQuote.swift
│   │   │   │   └── WellnessTip.swift
│   │   │   └── UseCases/
│   │   │       ├── GetDailyQuoteUseCase.swift
│   │   │       └── GetWellnessTipsUseCase.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── HomeView.swift
│   │   │   ├── HomeViewModel.swift
│   │   │   └── 📁 Components/
│   │   │       ├── DailyQuoteCard.swift
│   │   │       ├── QuickActionsGrid.swift
│   │   │       └── StreakIndicator.swift
│   │   └── 📁 Tests/
│   │       └── HomeViewModelTests.swift
│   │
│   ├── 📁 MoodTracker/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── MoodEntry.swift
│   │   │   │   ├── MoodType.swift
│   │   │   │   └── MoodStatistics.swift
│   │   │   ├── UseCases/
│   │   │   │   ├── LogMoodUseCase.swift
│   │   │   │   ├── GetMoodHistoryUseCase.swift
│   │   │   │   └── GetMoodStatsUseCase.swift
│   │   │   └── RepositoryProtocols/
│   │   │       └── MoodRepositoryProtocol.swift
│   │   ├── 📁 Data/
│   │   │   ├── Repositories/
│   │   │   │   └── MoodRepository.swift
│   │   │   ├── DataSources/
│   │   │   │   ├── MoodRemoteDataSource.swift
│   │   │   │   └── MoodLocalDataSource.swift
│   │   │   └── Mappers/
│   │   │       └── MoodEntryMapper.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── 📁 LogMood/
│   │   │   │   ├── LogMoodView.swift
│   │   │   │   ├── LogMoodViewModel.swift
│   │   │   │   └── MoodSelector.swift
│   │   │   ├── 📁 MoodHistory/
│   │   │   │   ├── MoodHistoryView.swift
│   │   │   │   ├── MoodHistoryViewModel.swift
│   │   │   │   └── MoodCalendar.swift
│   │   │   └── 📁 MoodStats/
│   │   │       ├── MoodStatsView.swift
│   │   │       └── MoodChart.swift
│   │   └── 📁 Tests/
│   │       ├── MoodRepositoryTests.swift
│   │       └── LogMoodUseCaseTests.swift
│   │
│   ├── 📁 Meditation/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── MeditationSession.swift
│   │   │   │   ├── BreathingExercise.swift
│   │   │   │   └── SessionProgress.swift
│   │   │   ├── UseCases/
│   │   │   │   ├── GetMeditationsUseCase.swift
│   │   │   │   ├── StartSessionUseCase.swift
│   │   │   │   └── CompleteSessionUseCase.swift
│   │   │   └── RepositoryProtocols/
│   │   │       └── MeditationRepositoryProtocol.swift
│   │   ├── 📁 Data/
│   │   │   ├── Repositories/
│   │   │   │   └── MeditationRepository.swift
│   │   │   └── DataSources/
│   │   │       ├── MeditationRemoteDataSource.swift
│   │   │       └── MeditationLocalDataSource.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── 📁 MeditationList/
│   │   │   │   ├── MeditationListView.swift
│   │   │   │   └── MeditationListViewModel.swift
│   │   │   ├── 📁 SessionPlayer/
│   │   │   │   ├── SessionPlayerView.swift
│   │   │   │   ├── SessionPlayerViewModel.swift
│   │   │   │   ├── BreathingAnimation.swift
│   │   │   │   └── AudioControls.swift
│   │   │   └── 📁 Breathing/
│   │   │       ├── BreathingView.swift
│   │   │       └── BreathingGuide.swift
│   │   └── 📁 Tests/
│   │       └── MeditationSessionTests.swift
│   │
│   ├── 📁 Journal/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── JournalEntry.swift
│   │   │   │   └── JournalPrompt.swift
│   │   │   ├── UseCases/
│   │   │   │   ├── CreateEntryUseCase.swift
│   │   │   │   ├── GetEntriesUseCase.swift
│   │   │   │   └── DeleteEntryUseCase.swift
│   │   │   └── RepositoryProtocols/
│   │   │       └── JournalRepositoryProtocol.swift
│   │   ├── 📁 Data/
│   │   │   └── Repositories/
│   │   │       └── JournalRepository.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── 📁 EntryList/
│   │   │   │   ├── JournalListView.swift
│   │   │   │   └── JournalListViewModel.swift
│   │   │   ├── 📁 CreateEntry/
│   │   │   │   ├── CreateEntryView.swift
│   │   │   │   ├── CreateEntryViewModel.swift
│   │   │   │   └── PromptSelector.swift
│   │   │   └── 📁 EntryDetail/
│   │   │       └── EntryDetailView.swift
│   │   └── 📁 Tests/
│   │       └── JournalRepositoryTests.swift
│   │
│   ├── 📁 Profile/
│   │   ├── 📁 Domain/
│   │   │   ├── Entities/
│   │   │   │   ├── UserProfile.swift
│   │   │   │   ├── Achievement.swift
│   │   │   │   └── Preferences.swift
│   │   │   └── UseCases/
│   │   │       ├── GetProfileUseCase.swift
│   │   │       ├── UpdateProfileUseCase.swift
│   │   │       └── GetAchievementsUseCase.swift
│   │   ├── 📁 Presentation/
│   │   │   ├── ProfileView.swift
│   │   │   ├── ProfileViewModel.swift
│   │   │   ├── 📁 Settings/
│   │   │   │   ├── SettingsView.swift
│   │   │   │   └── NotificationSettings.swift
│   │   │   └── 📁 Achievements/
│   │   │       ├── AchievementsView.swift
│   │   │       └── AchievementCard.swift
│   │   └── 📁 Tests/
│   │       └── ProfileViewModelTests.swift
│   │
│   └── 📁 Social/
│       ├── 📁 Domain/
│       │   ├── Entities/
│       │   │   ├── Friend.swift
│       │   │   ├── Activity.swift
│       │   │   └── CommunityPost.swift
│       │   └── UseCases/
│       │       ├── GetFriendsUseCase.swift
│       │       └── ShareActivityUseCase.swift
│       ├── 📁 Presentation/
│       │   ├── SocialView.swift
│       │   └── 📁 Components/
│       │       └── FriendCard.swift
│       └── 📁 Tests/
│           └── SocialRepositoryTests.swift
│
├── 📁 Services/
│   ├── 📁 Amplify/
│   │   ├── AmplifyConfiguration.swift       # Amplify init & config
│   │   ├── 📁 Auth/
│   │   │   ├── AmplifyAuthService.swift
│   │   │   └── AuthSessionManager.swift
│   │   ├── 📁 Data/
│   │   │   ├── AmplifyDataStore.swift
│   │   │   └── SyncManager.swift
│   │   ├── 📁 API/
│   │   │   └── GraphQLClient.swift
│   │   └── 📁 Storage/
│   │       └── StorageService.swift
│   │
│   ├── 📁 Analytics/
│   │   ├── AnalyticsService.swift
│   │   ├── AnalyticsEvents.swift
│   │   └── AmplitudeProvider.swift          # Or other provider
│   │
│   ├── 📁 Notifications/
│   │   ├── NotificationService.swift
│   │   ├── LocalNotificationManager.swift
│   │   └── PushNotificationHandler.swift
│   │
│   ├── 📁 Audio/
│   │   ├── AudioPlayerService.swift
│   │   ├── AudioSessionManager.swift
│   │   └── BackgroundAudioManager.swift
│   │
│   └── 📁 Health/
│       ├── HealthKitService.swift
│       └── HealthDataSync.swift
│
├── 📁 Navigation/
│   ├── AppRouter.swift                      # Main navigation router
│   ├── Route.swift                          # Route definitions
│   ├── TabBarCoordinator.swift              # Tab-based navigation
│   ├── DeepLinkHandler.swift                # Deep link processing
│   └── NavigationState.swift                # Navigation state management
│
├── 📁 Models/
│   ├── 📁 Shared/
│   │   ├── IdentifiableModels.swift
│   │   └── ResponseModels.swift
│   └── 📁 Enums/
│       ├── AppError.swift
│       ├── LoadingState.swift
│       └── TimeOfDay.swift
│
├── 📁 Preview Content/
│   └── Preview Assets.xcassets
│
└── 📁 Tests/
    ├── 📁 UnitTests/
    │   ├── 📁 Core/
    │   ├── 📁 Features/
    │   └── 📁 Services/
    ├── 📁 IntegrationTests/
    │   └── AmplifyIntegrationTests.swift
    ├── 📁 UITests/
    │   └── CapybaraWellnessUITests.swift
    └── 📁 Mocks/
        ├── MockRepositories/
        ├── MockServices/
        └── TestData/
```

---

## 3. Core Features Architecture

### 3.1 Feature: Authentication

```swift
// Domain/Entities/User.swift
struct User: Identifiable, Equatable {
    let id: String
    let email: String
    let username: String
    let createdAt: Date
    let isEmailVerified: Bool
    var profile: UserProfile?
}

// Domain/UseCases/SignInUseCase.swift
protocol SignInUseCaseProtocol {
    func execute(email: String, password: String) async throws -> User
}

// Data/Repositories/AuthRepository.swift
class AuthRepository: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: AuthLocalDataSource
    
    func signIn(email: String, password: String) async throws -> User {
        let authUser = try await remoteDataSource.signIn(email: email, password: password)
        let user = UserMapper.map(authUser)
        try await localDataSource.saveUser(user)
        return user
    }
}
```

### 3.2 Feature: Mood Tracking

```swift
// Domain/Entities/MoodEntry.swift
struct MoodEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let mood: MoodType
    let intensity: Int // 1-10
    let note: String?
    let tags: [String]
    let timestamp: Date
    let context: MoodContext?
}

enum MoodType: String, Codable, CaseIterable {
    case joyful = "😊"
    case calm = "😌"
    case anxious = "😰"
    case sad = "😢"
    case angry = "😠"
    case tired = "😴"
    case excited = "🤩"
    case grateful = "🙏"
}

struct MoodContext: Codable {
    let location: String?
    let activity: String?
    let weather: String?
    let sleepHours: Double?
}
```

### 3.3 Feature: Meditation & Breathing

```swift
// Domain/Entities/MeditationSession.swift
struct MeditationSession: Identifiable {
    let id: String
    let title: String
    let description: String
    let duration: TimeInterval
    let category: MeditationCategory
    let difficulty: DifficultyLevel
    let audioURL: URL?
    let imageURL: URL?
    let instructor: String?
    let tags: [String]
    let isPremium: Bool
}

enum MeditationCategory: String, CaseIterable {
    case mindfulness
    case sleep
    case focus
    case anxiety
    case gratitude
    case bodyScan
}

// Breathing Exercise Models
struct BreathingExercise: Identifiable {
    let id: String
    let name: String
    let pattern: BreathingPattern
    let description: String
}

struct BreathingPattern {
    let inhaleDuration: TimeInterval
    let holdDuration: TimeInterval
    let exhaleDuration: TimeInterval
    let holdEmptyDuration: TimeInterval
    let cycles: Int
}

// Predefined patterns
extension BreathingPattern {
    static let boxBreathing = BreathingPattern(
        inhaleDuration: 4,
        holdDuration: 4,
        exhaleDuration: 4,
        holdEmptyDuration: 4,
        cycles: 10
    )
    
    static let fourSevenEight = BreathingPattern(
        inhaleDuration: 4,
        holdDuration: 7,
        exhaleDuration: 8,
        holdEmptyDuration: 0,
        cycles: 4
    )
}
```

### 3.4 Feature: Journal

```swift
// Domain/Entities/JournalEntry.swift
struct JournalEntry: Identifiable, Codable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let mood: MoodType?
    let prompt: JournalPrompt?
    let images: [String] // Storage keys
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct JournalPrompt: Codable {
    let id: String
    let text: String
    let category: PromptCategory
}

enum PromptCategory: String, CaseIterable {
    case gratitude
    case reflection
    case growth
    case mindfulness
    case emotions
}
```

---

## 4. State Management

### 4.1 App State Container (Observable)

```swift
// Core/Architecture/AppState.swift
@Observable
final class AppState {
    // MARK: - Authentication State
    var authState: AuthState = .unauthenticated
    var currentUser: User?
    
    // MARK: - Navigation State
    var selectedTab: TabRoute = .home
    var presentedRoute: Route?
    
    // MARK: - Global UI State
    var isLoading = false
    var globalError: AppError?
    var showErrorAlert = false
    
    // MARK: - Feature States
    var moodTrackerState = MoodTrackerState()
    var meditationState = MeditationState()
    
    // MARK: - Sync State
    var syncStatus: SyncStatus = .idle
    var pendingSyncCount = 0
}

enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated(User)
    case error(AuthError)
}

enum SyncStatus {
    case idle
    case syncing
    case synced
    case error(Error)
}
```

### 4.2 ViewModel Base Class

```swift
// Core/Architecture/BaseViewModel.swift
@Observable
class BaseViewModel {
    var state: ViewState = .idle
    var errorMessage: String?
    
    func handleError(_ error: Error) {
        state = .error
        errorMessage = error.localizedDescription
        Logger.error(error)
    }
    
    func execute<T>(_ operation: () async throws -> T) async -> T? {
        state = .loading
        do {
            let result = try await operation()
            state = .loaded
            return result
        } catch {
            handleError(error)
            return nil
        }
    }
}

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error
    case empty
}
```

### 4.3 Feature-Specific State

```swift
// Features/MoodTracker/Presentation/LogMood/MoodTrackerState.swift
@Observable
final class MoodTrackerState {
    var todayMood: MoodEntry?
    var recentMoods: [MoodEntry] = []
    var moodStatistics: MoodStatistics?
    var selectedDate: Date = Date()
}

// Features/Meditation/Presentation/SessionPlayer/MeditationState.swift
@Observable
final class MeditationState {
    var currentSession: MeditationSession?
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var totalDuration: TimeInterval = 0
    var playbackProgress: Double = 0
}
```

---

## 5. Navigation Architecture

### 5.1 Route Definitions

```swift
// Navigation/Route.swift
enum Route: Hashable {
    // Auth Flow
    case signIn
    case signUp
    case forgotPassword
    case confirmSignUp(email: String)
    
    // Main Tabs
    case home
    case moodTracker
    case meditation
    case journal
    case profile
    case social
    
    // Mood Tracker Flow
    case logMood
    case moodHistory
    case moodStats
    case moodDetail(entryId: String)
    
    // Meditation Flow
    case meditationList(category: MeditationCategory?)
    case sessionPlayer(sessionId: String)
    case breathingExercise(exerciseId: String)
    
    // Journal Flow
    case journalList
    case createEntry(promptId: String?)
    case entryDetail(entryId: String)
    case editEntry(entryId: String)
    
    // Profile Flow
    case settings
    case notifications
    case achievements
    case editProfile
    
    // Deep Links
    case sharedMeditation(sessionId: String)
    case dailyReminder
    case streakCelebration
}

enum TabRoute: String, CaseIterable {
    case home = "Home"
    case moodTracker = "Mood"
    case meditation = "Meditate"
    case journal = "Journal"
    case profile = "Profile"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .moodTracker: return "face.smiling.fill"
        case .meditation: return "sparkles"
        case .journal: return "book.fill"
        case .profile: return "person.fill"
        }
    }
}
```

### 5.2 Navigation Router

```swift
// Navigation/AppRouter.swift
@Observable
final class AppRouter {
    var path = NavigationPath()
    var selectedTab: TabRoute = .home
    var presentedSheet: Route?
    var presentedFullScreen: Route?
    
    // MARK: - Navigation Actions
    func navigate(to route: Route) {
        path.append(route)
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ route: Route) {
        presentedSheet = route
    }
    
    func presentFullScreen(_ route: Route) {
        presentedFullScreen = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func dismissFullScreen() {
        presentedFullScreen = nil
    }
}

// MARK: - View Factory
extension AppRouter {
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .signIn:
            SignInView()
        case .signUp:
            SignUpView()
        case .forgotPassword:
            ForgotPasswordView()
        case .home:
            HomeView()
        case .moodTracker:
            MoodHistoryView()
        case .meditation:
            MeditationListView()
        case .journal:
            JournalListView()
        case .profile:
            ProfileView()
        case .logMood:
            LogMoodView()
        case .sessionPlayer(let sessionId):
            SessionPlayerView(sessionId: sessionId)
        case .createEntry(let promptId):
            CreateEntryView(promptId: promptId)
        // ... other cases
        default:
            EmptyView()
        }
    }
}
```

### 5.3 Deep Link Handler

```swift
// Navigation/DeepLinkHandler.swift
final class DeepLinkHandler {
    private let router: AppRouter
    private let authService: AuthServiceProtocol
    
    init(router: AppRouter, authService: AuthServiceProtocol) {
        self.router = router
        self.authService = authService
    }
    
    func handle(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        let path = components.path.split(separator: "/").map(String.init)
        
        switch host {
        case "meditation":
            if let sessionId = path.first {
                router.navigate(to: .sharedMeditation(sessionId: sessionId))
            }
        case "mood":
            router.navigate(to: .logMood)
        case "reminder":
            router.navigate(to: .dailyReminder)
        case "streak":
            router.navigate(to: .streakCelebration)
        default:
            break
        }
    }
    
    func handleNotification(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if let routeString = userInfo["route"] as? String,
           let route = Route(from: routeString) {
            router.navigate(to: route)
        }
    }
}
```

---

## 6. Services Layer

### 6.1 AWS Amplify Integration

```swift
// Services/Amplify/AmplifyConfiguration.swift
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSDataStorePlugin
import AWSS3StoragePlugin

final class AmplifyConfiguration {
    static let shared = AmplifyConfiguration()
    
    private init() {}
    
    func configure() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSDataStorePlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            Logger.info("Amplify configured successfully")
        } catch {
            Logger.error("Failed to configure Amplify: \(error)")
        }
    }
}

// Services/Amplify/Auth/AmplifyAuthService.swift
protocol AuthServiceProtocol {
    var isSignedIn: Bool { get }
    var currentUser: User? { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, username: String) async throws -> AuthSignUpResult
    func confirmSignUp(email: String, code: String) async throws
    func signOut() async throws
    func resetPassword(email: String) async throws
    func fetchCurrentUser() async throws -> User?
}

class AmplifyAuthService: AuthServiceProtocol {
    var isSignedIn: Bool {
        return Amplify.Auth.getCurrentUser() != nil
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await Amplify.Auth.signIn(username: email, password: password)
        guard result.isSignedIn else {
            throw AuthError.signInFailed
        }
        return try await fetchCurrentUser()!
    }
    
    func signUp(email: String, password: String, username: String) async throws -> AuthSignUpResult {
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        return try await Amplify.Auth.signUp(
            username: email,
            password: password,
            options: options
        )
    }
    
    func fetchCurrentUser() async throws -> User? {
        guard let authUser = Amplify.Auth.getCurrentUser() else { return nil }
        // Fetch additional user attributes
        let attributes = try await Amplify.Auth.fetchUserAttributes()
        return UserMapper.map(authUser: authUser, attributes: attributes)
    }
}
```

### 6.2 DataStore Service

```swift
// Services/Amplify/Data/AmplifyDataStore.swift
protocol DataStoreServiceProtocol {
    func save<T: Model>(_ model: T) async throws
    func query<T: Model>(_ type: T.Type, predicate: QueryPredicate?) async throws -> [T]
    func delete<T: Model>(_ model: T) async throws
    func observe<T: Model>(_ type: T.Type) -> AnyPublisher<DataStoreQuerySnapshot<T>, Error>
    func startSync() async throws
    func stopSync() async throws
}

class AmplifyDataStore: DataStoreServiceProtocol {
    func save<T: Model>(_ model: T) async throws {
        try await Amplify.DataStore.save(model)
    }
    
    func query<T: Model>(_ type: T.Type, predicate: QueryPredicate? = nil) async throws -> [T] {
        if let predicate = predicate {
            return try await Amplify.DataStore.query(type, where: predicate)
        }
        return try await Amplify.DataStore.query(type)
    }
    
    func observe<T: Model>(_ type: T.Type) -> AnyPublisher<DataStoreQuerySnapshot<T>, Error> {
        return Amplify.DataStore.observeQuery(for: type)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    func startSync() async throws {
        try await Amplify.DataStore.start()
    }
    
    func stopSync() async throws {
        try await Amplify.DataStore.stop()
    }
}
```

### 6.3 Sync Manager

```swift
// Services/Amplify/Data/SyncManager.swift
@Observable
final class SyncManager {
    enum SyncState {
        case idle
        case syncing
        case synced
        case error(Error)
    }
    
    private(set) var state: SyncState = .idle
    private(set) var pendingChanges: Int = 0
    
    private let dataStore: DataStoreServiceProtocol
    private let networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    init(dataStore: DataStoreServiceProtocol, networkMonitor: NetworkMonitor) {
        self.dataStore = dataStore
        self.networkMonitor = networkMonitor
        setupObservers()
    }
    
    private func setupObservers() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    self?.startSync()
                }
            }
            .store(in: &cancellables)
    }
    
    func startSync() {
        state = .syncing
        Task {
            do {
                try await dataStore.startSync()
                state = .synced
            } catch {
                state = .error(error)
            }
        }
    }
    
    func queueOfflineChange<T: Model>(_ model: T, operation: SyncOperation) {
        pendingChanges += 1
        // Store in local queue for later sync
    }
}

enum SyncOperation {
    case create
    case update
    case delete
}
```

### 6.4 Notification Service

```swift
// Services/Notifications/NotificationService.swift
protocol NotificationServiceProtocol {
    func requestAuthorization() async throws -> Bool
    func scheduleNotification(_ notification: AppNotification) async
    func cancelNotification(id: String)
    func cancelAllNotifications()
}

struct AppNotification {
    let id: String
    let title: String
    let body: String
    let date: Date
    let route: Route?
    let userInfo: [String: Any]
}

class LocalNotificationManager: NotificationServiceProtocol {
    private let center = UNUserNotificationCenter.current)
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await center.requestAuthorization(options: options)
    }
    
    func scheduleNotification(_ notification: AppNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.userInfo = notification.userInfo
        
        if let route = notification.route {
            content.userInfo["route"] = route.stringValue
        }
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: notification.date
            ),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        
        try? await center.add(request)
    }
    
    func scheduleDailyReminders() {
        // Morning reminder
        scheduleNotification(AppNotification(
            id: "morning-reminder",
            title: "Good Morning! 🌅",
            body: "Start your day with a quick mood check and meditation.",
            date: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!,
            route: .logMood,
            userInfo: [:]
        ))
        
        // Evening reminder
        scheduleNotification(AppNotification(
            id: "evening-reminder",
            title: "Wind Down 🌙",
            body: "Take a moment to reflect on your day.",
            date: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!,
            route: .journal,
            userInfo: [:]
        ))
    }
}
```

### 6.5 Analytics Service

```swift
// Services/Analytics/AnalyticsService.swift
protocol AnalyticsServiceProtocol {
    func logEvent(_ event: AnalyticsEvent)
    func logScreenView(screenName: String, screenClass: String?)
    func setUserProperty(_ value: String?, forName: String)
    func setUserId(_ userId: String?)
}

enum AnalyticsEvent {
    case moodLogged(mood: MoodType, intensity: Int)
    case meditationStarted(sessionId: String, duration: TimeInterval)
    case meditationCompleted(sessionId: String, completedDuration: TimeInterval)
    case journalEntryCreated(hasPrompt: Bool)
    case streakAchieved(days: Int)
    case subscriptionStarted(plan: String)
    
    var name: String {
        switch self {
        case .moodLogged: return "mood_logged"
        case .meditationStarted: return "meditation_started"
        case .meditationCompleted: return "meditation_completed"
        case .journalEntryCreated: return "journal_entry_created"
        case .streakAchieved: return "streak_achieved"
        case .subscriptionStarted: return "subscription_started"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .moodLogged(let mood, let intensity):
            return ["mood": mood.rawValue, "intensity": intensity]
        case .meditationStarted(let sessionId, let duration):
            return ["session_id": sessionId, "duration": duration]
        case .meditationCompleted(let sessionId, let completedDuration):
            return ["session_id": sessionId, "completed_duration": completedDuration]
        case .journalEntryCreated(let hasPrompt):
            return ["has_prompt": hasPrompt]
        case .streakAchieved(let days):
            return ["days": days]
        case .subscriptionStarted(let plan):
            return ["plan": plan]
        }
    }
}

class AmplitudeAnalyticsService: AnalyticsServiceProtocol {
    private let amplitude: Amplitude
    
    init(apiKey: String) {
        let configuration = Configuration(apiKey: apiKey)
        self.amplitude = Amplitude(configuration: configuration)
    }
    
    func logEvent(_ event: AnalyticsEvent) {
        amplitude.track(eventType: event.name, eventProperties: event.parameters)
    }
    
    func logScreenView(screenName: String, screenClass: String?) {
        var properties: [String: Any] = ["screen_name": screenName]
        if let screenClass = screenClass {
            properties["screen_class"] = screenClass
        }
        amplitude.track(eventType: "screen_view", eventProperties: properties)
    }
    
    func setUserProperty(_ value: String?, forName: String) {
        let identify = Identify()
        if let value = value {
            identify.set(property: forName, value: value)
        } else {
            identify.clear(property: forName)
        }
        amplitude.identify(identify: identify)
    }
    
    func setUserId(_ userId: String?) {
        amplitude.setUserId(userId: userId)
    }
}
```

### 6.6 Audio Service

```swift
// Services/Audio/AudioPlayerService.swift
import AVFoundation
import Combine

protocol AudioPlayerServiceProtocol {
    var isPlaying: AnyPublisher<Bool, Never> { get }
    var currentTime: AnyPublisher<TimeInterval, Never> { get }
    var duration: AnyPublisher<TimeInterval, Never> { get }
    var progress: AnyPublisher<Double, Never> { get }
    
    func play(url: URL) async throws
    func pause()
    func resume()
    func stop()
    func seek(to time: TimeInterval)
    func setVolume(_ volume: Float)
}

class AudioPlayerService: AudioPlayerServiceProtocol {
    private var player: AVAudioPlayer?
    private var timer: Timer?
    
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let currentTimeSubject = CurrentValueSubject<TimeInterval, Never>(0)
    private let durationSubject = CurrentValueSubject<TimeInterval, Never>(0)
    
    var isPlaying: AnyPublisher<Bool, Never> { isPlayingSubject.eraseToAnyPublisher() }
    var currentTime: AnyPublisher<TimeInterval, Never> { currentTimeSubject.eraseToAnyPublisher() }
    var duration: AnyPublisher<TimeInterval, Never> { durationSubject.eraseToAnyPublisher() }
    var progress: AnyPublisher<Double, Never> {
        Publishers.CombineLatest(currentTimeSubject, durationSubject)
            .map { current, duration in
                duration > 0 ? current / duration : 0
            }
            .eraseToAnyPublisher()
    }
    
    func play(url: URL) async throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
        
        let data = try Data(contentsOf: url)
        player = try AVAudioPlayer(data: data)
        player?.prepareToPlay()
        player?.play()
        
        durationSubject.send(player?.duration ?? 0)
        isPlayingSubject.send(true)
        startProgressTimer()
    }
    
    func pause() {
        player?.pause()
        isPlayingSubject.send(false)
        timer?.invalidate()
    }
    
    func resume() {
        player?.play()
        isPlayingSubject.send(true)
        startProgressTimer()
    }
    
    func stop() {
        player?.stop()
        player = nil
        isPlayingSubject.send(false)
        timer?.invalidate()
        currentTimeSubject.send(0)
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTimeSubject.send(time)
    }
    
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
    
    private func startProgressTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            self.currentTimeSubject.send(player.currentTime)
        }
    }
}
```

---

## 7. Dependency Injection

```swift
// Core/DI/DependencyContainer.swift
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private var dependencies: [String: Any] = [:]
    
    private init() {
        registerDependencies()
    }
    
    func register<T>(_ dependency: T, for type: T.Type) {
        let key = String(describing: type)
        dependencies[key] = dependency
    }
    
    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return dependencies[key] as? T
    }
    
    private func registerDependencies() {
        // Services
        register(AmplifyAuthService() as AuthServiceProtocol, for: AuthServiceProtocol.self)
        register(AmplifyDataStore() as DataStoreServiceProtocol, for: DataStoreServiceProtocol.self)
        register(LocalNotificationManager() as NotificationServiceProtocol, for: NotificationServiceProtocol.self)
        register(AudioPlayerService() as AudioPlayerServiceProtocol, for: AudioPlayerServiceProtocol.self)
        
        // Repositories
        register(AuthRepository() as AuthRepositoryProtocol, for: AuthRepositoryProtocol.self)
        register(MoodRepository() as MoodRepositoryProtocol, for: MoodRepositoryProtocol.self)
        register(MeditationRepository() as MeditationRepositoryProtocol, for: MeditationRepositoryProtocol.self)
        register(JournalRepository() as JournalRepositoryProtocol, for: JournalRepositoryProtocol.self)
        
        // Use Cases
        register(SignInUseCase() as SignInUseCaseProtocol, for: SignInUseCaseProtocol.self)
        register(SignUpUseCase() as SignUpUseCaseProtocol, for: SignUpUseCaseProtocol.self)
        register(LogMoodUseCase() as LogMoodUseCaseProtocol, for: LogMoodUseCaseProtocol.self)
        register(GetMoodHistoryUseCase() as GetMoodHistoryUseCaseProtocol, for: GetMoodHistoryUseCaseProtocol.self)
        register(GetMeditationsUseCase() as GetMeditationsUseCaseProtocol, for: GetMeditationsUseCaseProtocol.self)
        register(StartSessionUseCase() as StartSessionUseCaseProtocol, for: StartSessionUseCaseProtocol.self)
        register(CreateEntryUseCase() as CreateEntryUseCaseProtocol, for: CreateEntryUseCaseProtocol.self)
        register(GetEntriesUseCase() as GetEntriesUseCaseProtocol, for: GetEntriesUseCaseProtocol.self)
    }
}

// Property Wrapper for Injection
@propertyWrapper
struct Inject<T> {
    let wrappedValue: T
    
    init() {
        guard let value = DependencyContainer.shared.resolve(T.self) else {
            fatalError("No dependency registered for \(T.self)")
        }
        self.wrappedValue = value
    }
}

// Usage in ViewModels
class SignInViewModel: BaseViewModel {
    @Inject private var signInUseCase: SignInUseCaseProtocol
    @Inject private var analytics: AnalyticsServiceProtocol
    
    func signIn(email: String, password: String) async {
        analytics.logEvent(.userAction("sign_in_attempted"))
        
        await execute {
            let user = try await signInUseCase.execute(email: email, password: password)
            analytics.logEvent(.userSignedIn)
            return user
        }
    }
}
```

---

## 8. Testing Strategy

### 8.1 Test Structure

```
Tests/
├── 📁 UnitTests/
│   ├── 📁 Core/
│   │   ├── DependencyContainerTests.swift
│   │   └── ViewStateTests.swift
│   │
│   ├── 📁 Features/
│   │   ├── 📁 Authentication/
│   │   │   ├── SignInViewModelTests.swift
│   │   │   ├── SignUpViewModelTests.swift
│   │   │   └── AuthRepositoryTests.swift
│   │   │
│   │   ├── 📁 MoodTracker/
│   │   │   ├── LogMoodViewModelTests.swift
│   │   │   ├── MoodRepositoryTests.swift
│   │   │   └── LogMoodUseCaseTests.swift
│   │   │
│   │   ├── 📁 Meditation/
│   │   │   ├── MeditationListViewModelTests.swift
│   │   │   └── SessionPlayerViewModelTests.swift
│   │   │
│   │   └── 📁 Journal/
│   │       ├── JournalListViewModelTests.swift
│   │       └── CreateEntryViewModelTests.swift
│   │
│   └── 📁 Services/
│       ├── AmplifyAuthServiceTests.swift
│       ├── AudioPlayerServiceTests.swift
│       └── NotificationServiceTests.swift
│
├── 📁 IntegrationTests/
│   ├── AmplifyIntegrationTests.swift
│   ├── SyncManagerTests.swift
│   └── EndToEndFlowTests.swift
│
├── 📁 UITests/
│   ├── AuthenticationFlowUITests.swift
│   ├── MoodTrackingUITests.swift
│   └── MeditationSessionUITests.swift
│
└── 📁 Mocks/
    ├── 📁 MockRepositories/
    │   ├── MockAuthRepository.swift
    │   ├── MockMoodRepository.swift
    │   └── MockMeditationRepository.swift
    │
    ├── 📁 MockServices/
    │   ├── MockAuthService.swift
    │   ├── MockDataStore.swift
    │   └── MockAnalyticsService.swift
    │
    └── 📁 TestData/
        ├── UserTestData.swift
        ├── MoodEntryTestData.swift
        └── MeditationSessionTestData.swift
```

### 8.2 Mock Implementations

```swift
// Tests/Mocks/MockRepositories/MockAuthRepository.swift
class MockAuthRepository: AuthRepositoryProtocol {
    var shouldSucceed = true
    var mockUser: User?
    var error: Error?
    
    func signIn(email: String, password: String) async throws -> User {
        if shouldSucceed {
            return mockUser ?? User.mock
        } else {
            throw error ?? AuthError.invalidCredentials
        }
    }
    
    func signUp(email: String, password: String, username: String) async throws -> AuthSignUpResult {
        if shouldSucceed {
            return AuthSignUpResult(confirmationRequired: true)
        } else {
            throw error ?? AuthError.signUpFailed
        }
    }
    
    func signOut() async throws {
        if !shouldSucceed {
            throw error ?? AuthError.signOutFailed
        }
    }
}

// Tests/Mocks/MockServices/MockAnalyticsService.swift
class MockAnalyticsService: AnalyticsServiceProtocol {
    var loggedEvents: [AnalyticsEvent] = []
    var screenViews: [(String, String?)] = []
    
    func logEvent(_ event: AnalyticsEvent) {
        loggedEvents.append(event)
    }
    
    func logScreenView(screenName: String, screenClass: String?) {
        screenViews.append((screenName, screenClass))
    }
    
    func setUserProperty(_ value: String?, forName: String) {}
    func setUserId(_ userId: String?) {}
}
```

### 8.3 ViewModel Tests

```swift
// Tests/UnitTests/Features/Authentication/SignInViewModelTests.swift
import XCTest
@testable import CapybaraWellness

final class SignInViewModelTests: XCTestCase {
    var sut: SignInViewModel!
    var mockAuthRepository: MockAuthRepository!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockAuthRepository = MockAuthRepository()
        mockAnalytics = MockAnalyticsService()
        sut = SignInViewModel(
            authRepository: mockAuthRepository,
            analytics: mockAnalytics
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAuthRepository = nil
        mockAnalytics = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testSignIn_WithValidCredentials_UpdatesStateToSuccess() async {
        // Given
        mockAuthRepository.shouldSucceed = true
        mockAuthRepository.mockUser = User.mock
        
        // When
        await sut.signIn(email: "test@example.com", password: "password123")
        
        // Then
        XCTAssertEqual(sut.state, .loaded)
        XCTAssertNotNil(sut.user)
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 2)
    }
    
    func testSignIn_WithValidCredentials_LogsAnalyticsEvent() async {
        // Given
        mockAuthRepository.shouldSucceed = true
        
        // When
        await sut.signIn(email: "test@example.com", password: "password123")
        
        // Then
        XCTAssertTrue(mockAnalytics.loggedEvents.contains { event in
            if case .userSignedIn = event { return true }
            return false
        })
    }
    
    // MARK: - Failure Cases
    
    func testSignIn_WithInvalidCredentials_UpdatesStateToError() async {
        // Given
        mockAuthRepository.shouldSucceed = false
        mockAuthRepository.error = AuthError.invalidCredentials
        
        // When
        await sut.signIn(email: "test@example.com", password: "wrong")
        
        // Then
        XCTAssertEqual(sut.state, .error)
        XCTAssertNotNil(sut.errorMessage)
    }
    
    func testSignIn_WhileLoading_PreventsDuplicateRequests() async {
        // Given
        sut.state = .loading
        
        // When
        await sut.signIn(email: "test@example.com", password: "password123")
        
        // Then
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 0)
    }
    
    // MARK: - Validation Tests
    
    func testValidateEmail_WithInvalidEmail_ReturnsFalse() {
        XCTAssertFalse(sut.validateEmail("invalid"))
        XCTAssertFalse(sut.validateEmail(""))
        XCTAssertFalse(sut.validateEmail("test@"))
    }
    
    func testValidateEmail_WithValidEmail_ReturnsTrue() {
        XCTAssertTrue(sut.validateEmail("test@example.com"))
        XCTAssertTrue(sut.validateEmail("user+tag@domain.co.uk"))
    }
}
```

### 8.4 Use Case Tests

```swift
// Tests/UnitTests/Features/MoodTracker/LogMoodUseCaseTests.swift
import XCTest
@testable import CapybaraWellness

final class LogMoodUseCaseTests: XCTestCase {
    var sut: LogMoodUseCase!
    var mockRepository: MockMoodRepository!
    var mockAnalytics: MockAnalyticsService!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockMoodRepository()
        mockAnalytics = MockAnalyticsService()
        sut = LogMoodUseCase(
            repository: mockRepository,
            analytics: mockAnalytics
        )
    }
    
    func testExecute_SavesMoodEntry() async throws {
        // Given
        let mood = MoodType.joyful
        let intensity = 8
        
        // When
        let entry = try await sut.execute(
            mood: mood,
            intensity: intensity,
            note: "Great day!",
            tags: ["work", "exercise"]
        )
        
        // Then
        XCTAssertEqual(entry.mood, mood)
        XCTAssertEqual(entry.intensity, intensity)
        XCTAssertTrue(mockRepository.savedEntries.contains { $0.id == entry.id })
    }
    
    func testExecute_LogsAnalyticsEvent() async throws {
        // When
        _ = try await sut.execute(mood: .calm, intensity: 7, note: nil, tags: [])
        
        // Then
        XCTAssertTrue(mockAnalytics.loggedEvents.contains { event in
            if case .moodLogged(let loggedMood, let loggedIntensity) = event {
                return loggedMood == .calm && loggedIntensity == 7
            }
            return false
        })
    }
}
```

### 8.5 UI Tests

```swift
// Tests/UITests/MoodTrackingUITests.swift
import XCTest

final class MoodTrackingUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--mock-auth"]
        app.launch()
    }
    
    func testLogMoodFlow() {
        // Navigate to mood tracker
        app.tabBars.buttons["Mood"].tap()
        
        // Tap log mood button
        app.buttons["logMoodButton"].tap()
        
        // Select mood
        app.buttons["mood_joyful"].tap()
        
        // Adjust intensity
        app.sliders["intensitySlider"].adjust(toNormalizedSliderPosition: 0.8)
        
        // Add note
        app.textViews["noteTextView"].tap()
        app.typeText("Feeling great today!")
        
        // Save
        app.buttons["saveButton"].tap()
        
        // Verify success
        XCTAssertTrue(app.staticTexts["Mood logged successfully"].exists)
    }
    
    func testMoodHistoryDisplay() {
        // Navigate to mood tracker
        app.tabBars.buttons["Mood"].tap()
        
        // Verify calendar is displayed
        XCTAssertTrue(app.otherElements["moodCalendar"].exists)
        
        // Tap on a date
        app.buttons["calendarDate_15"].tap()
        
        // Verify mood detail appears
        XCTAssertTrue(app.staticTexts["moodDetail"].exists)
    }
}
```

### 8.6 Test Coverage Strategy

| Layer | Coverage Target | Strategy |
|-------|-----------------|----------|
| ViewModels | 95%+ | Unit tests with mocked dependencies |
| Use Cases | 100% | Unit tests with mocked repositories |
| Repositories | 90%+ | Unit tests with mocked data sources |
| Services | 85%+ | Unit + Integration tests |
| Views | 70%+ | UI Tests + Snapshot tests |
| Mappers | 100% | Unit tests with edge cases |

---

## 9. AWS Amplify Gen 2 Schema

```graphql
# amplify/data/resource.ts
const schema = a.schema({
  User: a.model({
    id: a.id().required(),
    email: a.string().required(),
    username: a.string().required(),
    profilePicture: a.string(),
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
    preferences: a.hasOne('UserPreferences', 'userId'),
    moodEntries: a.hasMany('MoodEntry', 'userId'),
    journalEntries: a.hasMany('JournalEntry', 'userId'),
    meditationProgress: a.hasMany('MeditationProgress', 'userId'),
    achievements: a.hasMany('UserAchievement', 'userId'),
    streak: a.hasOne('UserStreak', 'userId'),
  }).authorization(allow => [
    allow.ownerDefinedIn('id')
  ]),

  UserPreferences: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    dailyReminderTime: a.time(),
    eveningReminderTime: a.time(),
    notificationsEnabled: a.boolean().default(true),
    soundEnabled: a.boolean().default(true),
    hapticEnabled: a.boolean().default(true),
    theme: a.enum(['light', 'dark', 'system']),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),

  MoodEntry: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    mood: a.enum(['joyful', 'calm', 'anxious', 'sad', 'angry', 'tired', 'excited', 'grateful']),
    intensity: a.integer().required(),
    note: a.string(),
    tags: a.string().array(),
    timestamp: a.datetime().required(),
    context: a.customType({
      location: a.string(),
      activity: a.string(),
      weather: a.string(),
      sleepHours: a.float(),
    }),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),

  JournalEntry: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    title: a.string().required(),
    content: a.string().required(),
    mood: a.enum(['joyful', 'calm', 'anxious', 'sad', 'angry', 'tired', 'excited', 'grateful']),
    promptId: a.id(),
    images: a.string().array(),
    isFavorite: a.boolean().default(false),
    createdAt: a.datetime().required(),
    updatedAt: a.datetime().required(),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),

  MeditationSession: a.model({
    id: a.id().required(),
    title: a.string().required(),
    description: a.string(),
    duration: a.integer().required(),
    category: a.enum(['mindfulness', 'sleep', 'focus', 'anxiety', 'gratitude', 'bodyScan']),
    difficulty: a.enum(['beginner', 'intermediate', 'advanced']),
    audioKey: a.string(),
    imageKey: a.string(),
    instructor: a.string(),
    tags: a.string().array(),
    isPremium: a.boolean().default(false),
  }).authorization(allow => [
    allow.authenticated()
  ]),

  MeditationProgress: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    sessionId: a.id().required(),
    session: a.belongsTo('MeditationSession', 'sessionId'),
    completedAt: a.datetime().required(),
    completedDuration: a.integer(),
    rating: a.integer(),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),

  UserStreak: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    currentStreak: a.integer().default(0),
    longestStreak: a.integer().default(0),
    lastActivityDate: a.datetime(),
    totalSessions: a.integer().default(0),
    totalMeditationMinutes: a.integer().default(0),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),

  Achievement: a.model({
    id: a.id().required(),
    name: a.string().required(),
    description: a.string().required(),
    iconKey: a.string(),
    requirement: a.customType({
      type: a.enum(['streak', 'sessions', 'minutes', 'moods', 'entries']),
      value: a.integer().required(),
    }),
  }).authorization(allow => [
    allow.authenticated()
  ]),

  UserAchievement: a.model({
    userId: a.id().required(),
    user: a.belongsTo('User', 'userId'),
    achievementId: a.id().required(),
    achievement: a.belongsTo('Achievement', 'achievementId'),
    unlockedAt: a.datetime().required(),
  }).authorization(allow => [
    allow.ownerDefinedIn('userId')
  ]),
});
```

---

## 10. Key Architectural Decisions Summary

### 10.1 MVVM + Clean Architecture Hybrid
- **Decision**: Use MVVM for UI layer with Clean Architecture domain/data separation
- **Rationale**: Balances SwiftUI's Observable pattern with testability and maintainability
- **Trade-off**: Slightly more boilerplate than pure MVVM, but better separation of concerns

### 10.2 Dependency Injection
- **Decision**: Custom DI container with property wrapper
- **Rationale**: No external dependencies, full control, Swift-friendly
- **Alternative Considered**: Swinject (rejected to minimize dependencies)

### 10.3 State Management
- **Decision**: @Observable for view models, centralized AppState for global state
- **Rationale**: Native SwiftUI support, minimal boilerplate, excellent performance
- **Alternative Considered**: Redux/ObservableObject (rejected for complexity)

### 10.4 AWS Amplify Integration
- **Decision**: Repository pattern with Amplify-specific data sources
- **Rationale**: Easy to swap Amplify later, testable, follows Clean Architecture
- **Pattern**: RemoteDataSource -> Repository -> UseCase -> ViewModel

### 10.5 Navigation
- **Decision**: Programmatic navigation with Route enum and AppRouter
- **Rationale**: Type-safe, testable, supports deep linking
- **Deep Linking**: URL scheme `capybara://` with dedicated handler

### 10.6 Testing Strategy
- **Decision**: 3-layer testing (Unit, Integration, UI)
- **Target Coverage**: >90% (95% ViewModels, 100% Use Cases, 85% Services)
- **Mocking**: Protocol-based mocks for all dependencies

### 10.7 Offline Support
- **Decision**: Amplify DataStore with local-first architecture
- **Rationale**: Automatic offline support, conflict resolution, sync
- **Queue**: Pending changes tracked in SyncManager

---

## 11. Implementation Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Project setup with folder structure
- [ ] Core architecture (BaseViewModel, ViewState, AppState)
- [ ] Dependency Injection container
- [ ] Design system components
- [ ] AWS Amplify configuration

### Phase 2: Authentication (Week 2-3)
- [ ] Sign In/Sign Up flows
- [ ] Auth state management
- [ ] User session handling
- [ ] Unit tests for auth (target: 95% coverage)

### Phase 3: Core Features (Week 3-5)
- [ ] Home dashboard
- [ ] Mood tracking (log, history, stats)
- [ ] Meditation list and player
- [ ] Journal (create, list, detail)
- [ ] Profile and settings

### Phase 4: Polish & Integration (Week 5-6)
- [ ] Push notifications
- [ ] Analytics integration
- [ ] Deep linking
- [ ] UI tests
- [ ] Performance optimization

### Phase 5: Testing & Launch (Week 6-7)
- [ ] Integration tests
- [ ] End-to-end testing
- [ ] Accessibility audit
- [ ] App Store preparation

---

## 12. File Count Estimate

| Category | Estimated Files |
|----------|----------------|
| Core (DI, Extensions, Utilities) | 15-20 |
| Design System | 15-20 |
| Features (6 features × 8 files avg) | 50-60 |
| Services (Amplify, Analytics, etc.) | 15-20 |
| Navigation | 5-8 |
| Models/Enums | 10-15 |
| Tests (Unit + UI) | 40-50 |
| **Total** | **150-180** |

---

*Document Version: 1.0*
*Last Updated: 2024*
*Author: iOS Architecture Team*

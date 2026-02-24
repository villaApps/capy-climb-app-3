//
//  DataService.swift
//  Capybara Wellness
//
//  Data service for GraphQL operations
//

import Foundation
import Amplify
import AWSAPIPlugin

/// Data service for wellness app models
@MainActor
class DataService: ObservableObject {
    
    static let shared = DataService()
    
    @Published var moodEntries: [MoodEntry] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var meditationSessions: [MeditationSession] = []
    @Published var goals: [Goal] = []
    @Published var streaks: [Streak] = []
    
    private var subscriptions: [AnyCancellable] = []
    
    private init() {}
    
    // MARK: - User Profile
    
    /// Create or update user profile
    func saveUserProfile(_ profile: UserProfile) async throws -> UserProfile {
        let result = try await Amplify.API.mutate(request: .create(profile))
        
        switch result {
        case .success(let savedProfile):
            return savedProfile
        case .failure(let error):
            throw error
        }
    }
    
    /// Get user profile by ID
    func getUserProfile(id: String) async throws -> UserProfile? {
        let result = try await Amplify.API.query(
            request: .get(UserProfile.self, byId: id)
        )
        
        switch result {
        case .success(let profile):
            return profile
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Mood Entries
    
    /// Create a mood entry
    func createMoodEntry(
        mood: MoodType,
        intensity: Int,
        notes: String? = nil,
        tags: [String] = [],
        triggers: [String] = [],
        activities: [String] = []
    ) async throws -> MoodEntry {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw AuthError.sessionExpired
        }
        
        let entry = MoodEntry(
            mood: mood,
            intensity: intensity,
            notes: notes,
            tags: tags,
            triggers: triggers,
            activities: activities,
            entryDate: Temporal.Date.now(),
            userProfileId: userId
        )
        
        let result = try await Amplify.API.mutate(request: .create(entry))
        
        switch result {
        case .success(let savedEntry):
            await fetchMoodEntries()
            return savedEntry
        case .failure(let error):
            throw error
        }
    }
    
    /// Fetch mood entries for current user
    func fetchMoodEntries(limit: Int = 50) async {
        do {
            let result = try await Amplify.API.query(
                request: .list(MoodEntry.self, limit: limit)
            )
            
            switch result {
            case .success(let entries):
                self.moodEntries = entries.elements.sorted {
                    $0.entryDate > $1.entryDate
                }
            case .failure(let error):
                print("Failed to fetch mood entries: \(error)")
            }
        } catch {
            print("Error fetching mood entries: \(error)")
        }
    }
    
    /// Subscribe to mood entry changes
    func subscribeToMoodEntries() {
        let subscription = Amplify.API.subscribe(
            request: .subscription(of: MoodEntry.self, type: .onCreate)
        )
        
        subscription.receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Subscription error: \(error)")
                    }
                },
                receiveValue: { [weak self] event in
                    switch event {
                    case .connection(let connectionState):
                        print("Connection state: \(connectionState)")
                    case .data(let entry):
                        self?.moodEntries.insert(entry, at: 0)
                    }
                }
            )
            .store(in: &subscriptions)
    }
    
    // MARK: - Journal Entries
    
    /// Create a journal entry
    func createJournalEntry(
        title: String? = nil,
        content: String,
        mood: MoodType? = nil,
        moodIntensity: Int? = nil,
        tags: [String] = [],
        category: JournalCategory = .daily,
        isFavorite: Bool = false
    ) async throws -> JournalEntry {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw AuthError.sessionExpired
        }
        
        let entry = JournalEntry(
            title: title,
            content: content,
            mood: mood,
            moodIntensity: moodIntensity,
            tags: tags,
            category: category,
            isFavorite: isFavorite,
            wordCount: content.split(separator: " ").count,
            entryDate: Temporal.Date.now(),
            userProfileId: userId
        )
        
        let result = try await Amplify.API.mutate(request: .create(entry))
        
        switch result {
        case .success(let savedEntry):
            await fetchJournalEntries()
            return savedEntry
        case .failure(let error):
            throw error
        }
    }
    
    /// Fetch journal entries
    func fetchJournalEntries(limit: Int = 50) async {
        do {
            let result = try await Amplify.API.query(
                request: .list(JournalEntry.self, limit: limit)
            )
            
            switch result {
            case .success(let entries):
                self.journalEntries = entries.elements.sorted {
                    $0.entryDate > $1.entryDate
                }
            case .failure(let error):
                print("Failed to fetch journal entries: \(error)")
            }
        } catch {
            print("Error fetching journal entries: \(error)")
        }
    }
    
    // MARK: - Meditation Sessions
    
    /// Create a meditation session
    func createMeditationSession(
        type: MeditationType,
        title: String? = nil,
        description: String? = nil,
        plannedDuration: Int,
        moodBefore: MoodType? = nil
    ) async throws -> MeditationSession {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw AuthError.sessionExpired
        }
        
        let session = MeditationSession(
            type: type,
            title: title,
            description: description,
            plannedDuration: plannedDuration,
            moodBefore: moodBefore,
            sessionDate: Temporal.Date.now(),
            userProfileId: userId
        )
        
        let result = try await Amplify.API.mutate(request: .create(session))
        
        switch result {
        case .success(let savedSession):
            return savedSession
        case .failure(let error):
            throw error
        }
    }
    
    /// Complete a meditation session
    func completeMeditationSession(
        _ session: MeditationSession,
        actualDuration: Int,
        moodAfter: MoodType? = nil,
        notes: String? = nil
    ) async throws -> MeditationSession {
        var updatedSession = session
        updatedSession.actualDuration = actualDuration
        updatedSession.moodAfter = moodAfter
        updatedSession.notes = notes
        updatedSession.completed = true
        updatedSession.completionPercentage = min(100, (actualDuration * 100) / session.plannedDuration)
        updatedSession.endedAt = Temporal.DateTime.now()
        
        let result = try await Amplify.API.mutate(request: .update(updatedSession))
        
        switch result {
        case .success(let savedSession):
            return savedSession
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Goals
    
    /// Create a goal
    func createGoal(
        title: String,
        description: String? = nil,
        type: GoalType,
        targetValue: Int? = nil,
        unit: String? = nil,
        endDate: Temporal.Date? = nil
    ) async throws -> Goal {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw AuthError.sessionExpired
        }
        
        let goal = Goal(
            title: title,
            description: description,
            type: type,
            targetValue: targetValue,
            unit: unit,
            startDate: Temporal.Date.now(),
            endDate: endDate,
            userProfileId: userId
        )
        
        let result = try await Amplify.API.mutate(request: .create(goal))
        
        switch result {
        case .success(let savedGoal):
            await fetchGoals()
            return savedGoal
        case .failure(let error):
            throw error
        }
    }
    
    /// Fetch goals
    func fetchGoals() async {
        do {
            let result = try await Amplify.API.query(
                request: .list(Goal.self, limit: 50)
            )
            
            switch result {
            case .success(let goals):
                self.goals = goals.elements.sorted {
                    $0.createdAt > $1.createdAt
                }
            case .failure(let error):
                print("Failed to fetch goals: \(error)")
            }
        } catch {
            print("Error fetching goals: \(error)")
        }
    }
    
    // MARK: - Wellness Summary
    
    /// Get wellness summary
    func getWellnessSummary(
        startDate: Temporal.Date? = nil,
        endDate: Temporal.Date? = nil
    ) async throws -> WellnessSummary? {
        guard let userId = AuthService.shared.currentUser?.userId else {
            throw AuthError.sessionExpired
        }
        
        let query = """
        query GetWellnessSummary($userProfileId: ID!, $startDate: Date, $endDate: Date) {
            getWellnessSummary(
                userProfileId: $userProfileId
                startDate: $startDate
                endDate: $endDate
            ) {
                moodStats { ... }
                meditationStats { ... }
                journalStats { ... }
                streakInfo { ... }
                goalsProgress { ... }
            }
        }
        """
        
        let request = GraphQLRequest<WellnessSummary>(
            document: query,
            variables: [
                "userProfileId": userId,
                "startDate": startDate?.iso8601String,
                "endDate": endDate?.iso8601String
            ],
            responseType: WellnessSummary.self,
            decodePath: "getWellnessSummary"
        )
        
        let result = try await Amplify.API.query(request: request)
        
        switch result {
        case .success(let summary):
            return summary
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Model Types (Placeholders - generate from schema)

struct MoodEntry: Model {
    var id: String
    var mood: MoodType
    var intensity: Int
    var notes: String?
    var tags: [String]
    var triggers: [String]
    var activities: [String]
    var entryDate: Temporal.Date
    var userProfileId: String
    var createdAt: Temporal.DateTime
    var updatedAt: Temporal.DateTime
}

enum MoodType: String, Enum {
    case amazing, good, neutral, bad, terrible
    case anxious, stressed, calm, energetic, tired
}

// Additional model definitions would be generated by Amplify CLI

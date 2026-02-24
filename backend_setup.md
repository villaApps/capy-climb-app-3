# Capybara Wellness iOS App - AWS Amplify Gen 2 Backend Setup Guide

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Installation & Setup](#installation--setup)
5. [Authentication Configuration](#authentication-configuration)
6. [Data Models](#data-models)
7. [API & Storage](#api--storage)
8. [Authorization Rules](#authorization-rules)
9. [Lambda Functions](#lambda-functions)
10. [Deployment](#deployment)
11. [iOS Integration](#ios-integration)
12. [Environment Variables](#environment-variables)

---

## Overview

This AWS Amplify Gen 2 backend powers the **Capybara Wellness iOS App**, providing:

- **Authentication**: Email/password, Apple Sign In, Google OAuth with MFA support
- **Data Layer**: GraphQL API with 7 data models for wellness tracking
- **Storage**: S3 buckets for avatars, journal media, and meditation audio
- **Serverless Functions**: Notification delivery and streak aggregation
- **Security**: Owner-based access control with proper authorization rules

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Capybara Wellness iOS App                     │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                      AWS Amplify Gen 2                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Cognito     │  │   AppSync    │  │       S3 Storage     │  │
│  │  (Auth)      │  │  (GraphQL)   │  │  (Files & Media)     │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│         │                 │                    │                │
│         ▼                 ▼                    ▼                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Lambda Functions                             │  │
│  │  ┌─────────────────┐    ┌─────────────────────────────┐  │  │
│  │  │  Notifications  │    │  Streak Aggregation         │  │  │
│  │  │  (SES/SNS)      │    │  (Stats & Analytics)        │  │  │
│  │  └─────────────────┘    └─────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                      DynamoDB Tables                             │
│  UserProfile │ MoodEntry │ JournalEntry │ MeditationSession    │
│  Goal        │ Streak    │ Notification │                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

### Required Tools
- **Node.js** 18.x or higher
- **npm** 9.x or higher
- **AWS CLI** configured with appropriate credentials
- **Amplify CLI** (`npm install -g @aws-amplify/backend-cli`)

### AWS Account Setup
1. AWS account with appropriate permissions
2. IAM user with permissions for:
   - Cognito
   - AppSync
   - S3
   - Lambda
   - DynamoDB
   - SES (for email)
   - SNS (for push notifications)

### iOS Development
- Xcode 15.0+
- iOS 16.0+ target
- Apple Developer Account (for Sign In with Apple)

---

## Project Structure

```
/mnt/okcomputer/output/amplify/
├── amplify/
│   ├── auth/
│   │   └── resource.ts          # Cognito configuration
│   ├── data/
│   │   └── resource.ts          # Data models & GraphQL schema
│   ├── functions/
│   │   ├── notification/        # Push/email notifications
│   │   │   ├── resource.ts
│   │   │   └── handler.ts
│   │   └── streak-aggregation/  # Streak & stats calculation
│   │       ├── resource.ts
│   │       └── handler.ts
│   ├── storage/
│   │   └── resource.ts          # S3 bucket configuration
│   └── backend.ts               # Main backend definition
├── package.json                 # Dependencies
├── tsconfig.json               # TypeScript configuration
├── amplify.yml                 # CI/CD configuration
├── .env.example                # Environment variables template
└── .gitignore                  # Git ignore rules
```

---

## Installation & Setup

### Step 1: Install Dependencies

```bash
cd /mnt/okcomputer/output/amplify
npm install
```

### Step 2: Configure Environment Variables

```bash
cp .env.example .env
# Edit .env with your actual values
```

### Step 3: Initialize Amplify Backend

```bash
# Start local sandbox environment
npx ampx sandbox

# Or deploy to AWS
npx ampx deploy
```

---

## Authentication Configuration

### Features Implemented

| Feature | Status | Configuration |
|---------|--------|---------------|
| Email/Password | ✅ | With verification code |
| Apple Sign In | ✅ | OAuth 2.0 |
| Google Sign In | ✅ | OAuth 2.0 |
| MFA (SMS) | ✅ | Optional |
| MFA (TOTP) | ✅ | Optional |
| Password Recovery | ✅ | Email-based |
| Device Tracking | ✅ | Challenge on new device |

### User Attributes

```typescript
// Standard attributes
givenName: string      // First name
familyName: string     // Last name
nickname: string       // Display name
birthdate: string      // Date of birth
gender: string         // Gender
phoneNumber: string    // Phone for MFA
picture: string        // Avatar URL

// Custom attributes (via UserProfile model)
displayName: string
bio: string
preferredLanguage: string
timezone: string
theme: 'LIGHT' | 'DARK' | 'AUTO'
```

### Password Policy

- Minimum 8 characters
- Requires lowercase, uppercase, numbers, and special characters

### Social Login Setup

#### Google OAuth
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create OAuth 2.0 credentials
3. Add authorized redirect URIs:
   - `capybarawellness://callback`
   - `http://localhost:3000/auth/callback`

#### Apple Sign In
1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Configure Sign In with Apple
3. Create Service ID for your app
4. Generate private key
5. Add redirect URIs matching your app scheme

---

## Data Models

### 1. UserProfile

Extended user information linked to Cognito identity.

```typescript
{
  id: string;                    // Unique identifier
  owner: string;                 // Cognito sub (auto-set)
  displayName?: string;
  bio?: string;
  avatarUrl?: string;
  
  // Preferences
  preferredLanguage: string;     // default: 'en'
  timezone: string;              // default: 'UTC'
  theme: 'LIGHT' | 'DARK' | 'AUTO';
  
  // Notification settings
  dailyReminderTime?: string;
  meditationReminderTime?: string;
  journalReminderTime?: string;
  enablePushNotifications: boolean;
  enableEmailNotifications: boolean;
  
  // Wellness goals
  meditationGoalMinutes: number; // default: 10
  dailyJournalGoal: boolean;
  dailyMoodCheckGoal: boolean;
  
  // Computed stats
  currentStreak: number;
  longestStreak: number;
  totalMeditationMinutes: number;
  totalJournalEntries: number;
  totalMoodEntries: number;
  
  // Relationships
  moodEntries: MoodEntry[];
  journalEntries: JournalEntry[];
  meditationSessions: MeditationSession[];
  goals: Goal[];
  streaks: Streak[];
  notifications: Notification[];
  
  createdAt: DateTime;
  updatedAt: DateTime;
  lastActiveAt?: DateTime;
}
```

### 2. MoodEntry

Daily mood tracking with context.

```typescript
{
  id: string;
  owner: string;
  
  // Mood data
  mood: 'AMAZING' | 'GOOD' | 'NEUTRAL' | 'BAD' | 'TERRIBLE' |
        'ANXIOUS' | 'STRESSED' | 'CALM' | 'ENERGETIC' | 'TIRED';
  intensity: number;              // 1-10 scale
  notes?: string;
  
  // Context
  tags: string[];                 // e.g., ['work', 'exercise']
  triggers: string[];             // What triggered this mood
  activities: string[];           // Activities at the time
  location?: string;
  weather?: string;
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  // Timestamps
  entryDate: Date;                // User-selected date
  entryTime?: Time;
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### 3. JournalEntry

Personal journal entries with media support.

```typescript
{
  id: string;
  owner: string;
  
  // Content
  title?: string;
  content: string;                // Markdown supported
  
  // Mood context
  mood?: MoodType;
  moodIntensity?: number;
  
  // Categorization
  tags: string[];
  category: 'GRATITUDE' | 'REFLECTION' | 'GOALS' | 
            'DREAMS' | 'DAILY' | 'VENTING' | 'OTHER';
  
  // Media
  mediaUrls: string[];            // S3 URLs for images/audio
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  // Metadata
  entryDate: Date;
  isFavorite: boolean;
  wordCount?: number;
  
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### 4. MeditationSession

Meditation practice tracking.

```typescript
{
  id: string;
  owner: string;
  
  // Session details
  type: 'BREATHING' | 'BODY_SCAN' | 'LOVING_KINDNESS' |
        'MINDFULNESS' | 'GUIDED' | 'SILENT' | 'SLEEP' | 'FOCUS';
  title?: string;
  description?: string;
  
  // Duration
  plannedDuration: number;        // Minutes
  actualDuration?: number;        // Minutes (may differ)
  
  // Status
  completed: boolean;
  completionPercentage?: number;  // 0-100
  
  // Experience
  moodBefore?: MoodType;
  moodAfter?: MoodType;
  notes?: string;
  
  // Audio content
  audioUrl?: string;              // S3 URL for guided meditation
  guideName?: string;
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  // Timestamps
  sessionDate: Date;
  startedAt?: DateTime;
  endedAt?: DateTime;
  
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### 5. Goal

User goals and achievements.

```typescript
{
  id: string;
  owner: string;
  
  // Goal details
  title: string;
  description?: string;
  type: 'DAILY_MOOD' | 'DAILY_JOURNAL' | 'DAILY_MEDITATION' |
        'WEEKLY_MEDITATION' | 'STREAK_GOAL' | 'CUSTOM';
  status: 'ACTIVE' | 'COMPLETED' | 'ARCHIVED';
  
  // Target
  targetValue?: number;
  currentValue: number;
  unit?: string;                  // 'days', 'minutes', 'entries'
  
  // Timeframe
  startDate: Date;
  endDate?: Date;
  
  // Progress
  progressPercentage: number;
  lastUpdatedAt?: DateTime;
  
  // Achievement
  achievedAt?: DateTime;
  achievementBadge?: string;
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### 6. Streak

Consecutive activity tracking.

```typescript
{
  id: string;
  owner: string;
  
  // Streak type
  type: 'MOOD' | 'JOURNAL' | 'MEDITATION' | 'OVERALL';
  
  // Counts
  currentCount: number;
  longestCount: number;
  
  // Dates
  startedAt: Date;
  lastActivityAt: Date;
  longestStreakStartedAt?: Date;
  longestStreakEndedAt?: Date;
  
  // Status
  isActive: boolean;
  
  // History
  activityDates: string[];        // YYYY-MM-DD format
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

### 7. Notification

User notification records.

```typescript
{
  id: string;
  owner: string;
  
  // Content
  type: 'DAILY_REMINDER' | 'STREAK_REMINDER' | 'GOAL_ACHIEVED' |
        'WEEKLY_SUMMARY' | 'MEDITATION_REMINDER' | 
        'JOURNAL_REMINDER' | 'SYSTEM';
  title: string;
  body: string;
  
  // Data
  data?: JSON;                    // Custom payload
  actionUrl?: string;
  
  // Status
  isRead: boolean;
  isDelivered: boolean;
  
  // Timing
  scheduledFor?: DateTime;
  deliveredAt?: DateTime;
  readAt?: DateTime;
  
  // Relationships
  userProfileId: string;
  userProfile: UserProfile;
  
  createdAt: DateTime;
  updatedAt: DateTime;
}
```

---

## API & Storage

### GraphQL API Configuration

```typescript
// amplify/data/resource.ts
export const data = defineData({
  schema,
  authorizationModes: {
    defaultAuthorizationMode: 'userPool',
    apiKeyAuthorizationMode: {
      expiresInDays: 30,
    },
  },
});
```

### S3 Storage Buckets

| Path | Purpose | Access |
|------|---------|--------|
| `avatars/{user_id}/*` | User profile pictures | Owner: RWD, Auth: R |
| `journal-media/{user_id}/*` | Journal attachments | Owner: RWD |
| `meditation-audio/{user_id}/*` | Custom meditation audio | Owner: RWD, Auth: R |
| `app-assets/*` | Static assets (badges, icons) | Public: R, Admin: RWD |
| `exports/{user_id}/*` | User data exports | Owner: RWD |

### Custom Queries

```graphql
# Get wellness summary
query GetWellnessSummary(
  $userProfileId: ID!
  $startDate: Date
  $endDate: Date
) {
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

# Get mood statistics
query GetMoodStats(
  $userProfileId: ID!
  $period: Period!
) {
  getMoodStats(
    userProfileId: $userProfileId
    period: $period
  ) {
    totalEntries
    moodDistribution
    averageIntensity
    mostCommonMood
    streakDays
    weeklyTrend { ... }
  }
}
```

---

## Authorization Rules

### Owner-Based Access Control

All user data models use owner-based authorization:

```typescript
.authorization((allow) => [
  allow.owner().to(['read', 'create', 'update', 'delete']),
])
```

### Public Access

App assets are publicly readable:

```typescript
'app-assets/*': [
  allow.guest().to(['read']),
  allow.authenticated().to(['read']),
  allow.groups(['admin']).to(['read', 'write', 'delete']),
]
```

### Admin Group

Administrators have elevated permissions:

```typescript
allow.groups(['admin']).to(['read', 'write', 'delete'])
```

### Authorization Summary

| Resource | Owner | Authenticated | Guest | Admin |
|----------|-------|---------------|-------|-------|
| UserProfile | RWD | R | - | RWD |
| MoodEntry | RWD | - | - | - |
| JournalEntry | RWD | - | - | - |
| MeditationSession | RWD | - | - | - |
| Goal | RWD | - | - | - |
| Streak | RWD | - | - | - |
| Notification | RWD | - | - | - |
| Avatars | RWD | R | - | - |
| Journal Media | RWD | - | - | - |
| App Assets | - | R | R | RWD |

---

## Lambda Functions

### 1. Notification Function

**Purpose**: Send push notifications and emails

**Triggers**:
- Direct invocation from app
- EventBridge scheduled events
- DynamoDB stream events

**Features**:
- SES email delivery
- SNS push notifications (APNS/FCM)
- Scheduled reminders
- Batch notification processing

**Environment Variables**:
```
SES_FROM_EMAIL=noreply@capybarawellness.app
SES_REGION=us-east-1
SNS_PLATFORM_APPLICATION_ARN=arn:aws:sns:...
APP_NAME=Capybara Wellness
```

### 2. Streak Aggregation Function

**Purpose**: Calculate streaks and generate wellness summaries

**Triggers**:
- GraphQL queries (custom resolvers)
- EventBridge scheduled events
- DynamoDB stream events

**Features**:
- Streak calculation
- Mood statistics aggregation
- Wellness summary generation
- Goal progress tracking

**Environment Variables**:
```
STREAK_BREAK_THRESHOLD_HOURS=48
AGGREGATION_BATCH_SIZE=100
```

### Scheduled Events

```typescript
// Daily at 9 AM - Send daily reminders
// Daily at 11 PM - Break inactive streaks
// Weekly on Sunday - Send weekly summaries
```

---

## Deployment

### Local Development (Sandbox)

```bash
# Start local sandbox
npx ampx sandbox

# The sandbox creates temporary AWS resources
# All changes are deployed automatically
```

### Production Deployment

```bash
# Deploy to Amplify Console
npx ampx pipeline-deploy

# Or use Amplify Console CI/CD
# Push to main branch triggers automatic deployment
```

### Environment Management

```bash
# Create new environment
npx ampx env add production

# Switch environment
npx ampx env checkout production

# Deploy to specific environment
npx ampx deploy --env production
```

---

## iOS Integration

### Swift Package Dependencies

```swift
// Package.swift or Xcode SPM
dependencies: [
    .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0")
]
```

### Amplify Configuration

```swift
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

// Configure in AppDelegate or App init
func configureAmplify() {
    do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSAPIPlugin())
        try Amplify.add(plugin: AWSS3StoragePlugin())
        try Amplify.configure()
        print("Amplify configured successfully")
    } catch {
        print("Failed to configure Amplify: \(error)")
    }
}
```

### Authentication Example

```swift
import Amplify

// Sign up
func signUp(email: String, password: String) async throws {
    let options = AuthSignUpRequest.Options(
        userAttributes: [
            .email(email),
            .givenName("John"),
            .familyName("Doe")
        ]
    )
    let result = try await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: options
    )
    print("Sign up result: \(result)")
}

// Sign in
func signIn(email: String, password: String) async throws {
    let result = try await Amplify.Auth.signIn(
        username: email,
        password: password
    )
    print("Sign in result: \(result.isSignedIn)")
}

// Social sign in (Apple)
func signInWithApple() async throws {
    let result = try await Amplify.Auth.signInWithWebUI(
        for: .apple,
        presentationAnchor: window
    )
    print("Apple sign in: \(result.isSignedIn)")
}
```

### Data Operations Example

```swift
import Amplify

// Create mood entry
func createMoodEntry(mood: MoodType, intensity: Int, notes: String?) async throws {
    let entry = MoodEntry(
        mood: mood,
        intensity: intensity,
        notes: notes,
        entryDate: Temporal.Date.now(),
        userProfileId: currentUserProfileId
    )
    let result = try await Amplify.API.mutate(request: .create(entry))
    print("Created mood entry: \(result)")
}

// Query mood entries
func getMoodEntries() async throws -> [MoodEntry] {
    let request = GraphQLRequest<MoodEntry>.list(MoodEntry.self)
    let result = try await Amplify.API.query(request: request)
    return result.data?.items ?? []
}

// Subscribe to mood entries
func subscribeToMoodEntries() -> AnyCancellable {
    let subscription = Amplify.API.subscribe(
        request: .subscription(of: MoodEntry.self, type: .onCreate)
    )
    // Handle subscription events
    return subscription
}
```

### Storage Operations Example

```swift
import Amplify

// Upload avatar
func uploadAvatar(imageData: Data) async throws -> String {
    let key = "avatars/\(userId)/avatar.jpg"
    let result = try await Amplify.Storage.uploadData(
        key: key,
        data: imageData,
        options: .init(accessLevel: .protected)
    )
    print("Uploaded to: \(result)")
    return key
}

// Download avatar
func downloadAvatar(key: String) async throws -> Data {
    let result = try await Amplify.Storage.downloadData(
        key: key,
        options: .init(accessLevel: .protected)
    )
    return result
}
```

---

## Environment Variables

### Required Variables

| Variable | Description | Source |
|----------|-------------|--------|
| `AWS_REGION` | AWS region | AWS Console |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID | Google Cloud Console |
| `GOOGLE_CLIENT_SECRET` | Google OAuth secret | Google Cloud Console |
| `APPLE_CLIENT_ID` | Apple Service ID | Apple Developer Portal |
| `APPLE_TEAM_ID` | Apple Team ID | Apple Developer Portal |
| `APPLE_KEY_ID` | Apple private key ID | Apple Developer Portal |
| `APPLE_PRIVATE_KEY` | Apple private key | Apple Developer Portal |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SES_FROM_EMAIL` | noreply@capybarawellness.app | Email sender |
| `SES_REGION` | us-east-1 | SES region |
| `SNS_PLATFORM_APPLICATION_ARN` | - | SNS app ARN |
| `STREAK_BREAK_THRESHOLD_HOURS` | 48 | Streak break time |

---

## Troubleshooting

### Common Issues

#### 1. Social Login Not Working
- Verify redirect URIs match exactly
- Check OAuth credentials are correct
- Ensure app scheme is registered in iOS

#### 2. Push Notifications Not Delivering
- Verify SNS platform application ARN
- Check device tokens are registered correctly
- Ensure APNS certificates are valid

#### 3. Streak Calculation Incorrect
- Verify activity dates are in correct format
- Check timezone handling
- Review streak break threshold

#### 4. GraphQL Errors
- Check authorization rules
- Verify model relationships
- Review query syntax

### Debug Commands

```bash
# Check Amplify status
npx ampx status

# View logs
npx ampx logs --function notificationFunction

# Pull latest backend
npx ampx pull

# Generate GraphQL client code
npx ampx generate graphql-client-code
```

---

## Security Best Practices

1. **Never commit `.env` files** - Use `.env.example` as template
2. **Rotate credentials regularly** - Especially OAuth secrets
3. **Enable MFA** - For all admin accounts
4. **Use least privilege** - IAM roles with minimal permissions
5. **Enable CloudTrail** - For audit logging
6. **Encrypt at rest** - DynamoDB and S3 encryption enabled
7. **Use HTTPS only** - All API endpoints

---

## Support & Resources

- [AWS Amplify Documentation](https://docs.amplify.aws/)
- [Amplify iOS SDK](https://github.com/aws-amplify/amplify-swift)
- [AWS Cognito Docs](https://docs.aws.amazon.com/cognito/)
- [AppSync Documentation](https://docs.aws.amazon.com/appsync/)

---

## License

This backend configuration is proprietary to the Capybara Wellness project.

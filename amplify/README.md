# Capybara Wellness - AWS Amplify Gen 2 Backend

🦫 A comprehensive wellness tracking backend for the Capybara Wellness iOS app.

## Features

### Authentication
- ✅ Email/password authentication with verification
- ✅ Sign In with Apple (OAuth 2.0)
- ✅ Google Sign In (OAuth 2.0)
- ✅ Multi-Factor Authentication (SMS & TOTP)
- ✅ Password recovery
- ✅ Device tracking

### Data Models
- **UserProfile** - Extended user information and preferences
- **MoodEntry** - Daily mood tracking with context
- **JournalEntry** - Personal journal with media support
- **MeditationSession** - Meditation practice tracking
- **Goal** - User goals and achievements
- **Streak** - Consecutive activity tracking
- **Notification** - User notification records

### API & Storage
- GraphQL API with real-time subscriptions
- S3 storage for avatars, journal media, and meditation audio
- Owner-based access control
- Public read access for app assets

### Serverless Functions
- **Notification Function** - Push notifications (APNS) and email (SES)
- **Streak Aggregation** - Streak calculation and wellness summaries

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your credentials
```

### 3. Start Local Development

```bash
npx ampx sandbox
```

### 4. Deploy to Production

```bash
npx ampx deploy
```

## Project Structure

```
amplify/
├── auth/
│   └── resource.ts          # Cognito configuration
├── data/
│   └── resource.ts          # Data models & GraphQL schema
├── functions/
│   ├── notification/        # Push/email notifications
│   └── streak-aggregation/  # Streak & stats calculation
├── storage/
│   └── resource.ts          # S3 bucket configuration
├── backend.ts               # Main backend definition
ios-integration/             # Swift code for iOS integration
├── AmplifyConfig.swift
├── AuthService.swift
├── DataService.swift
└── StorageService.swift
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_REGION` | Yes | AWS region (e.g., us-east-1) |
| `GOOGLE_CLIENT_ID` | Yes | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Yes | Google OAuth secret |
| `APPLE_CLIENT_ID` | Yes | Apple Service ID |
| `APPLE_TEAM_ID` | Yes | Apple Team ID |
| `APPLE_KEY_ID` | Yes | Apple private key ID |
| `APPLE_PRIVATE_KEY` | Yes | Apple private key |
| `SES_FROM_EMAIL` | No | Email sender address |
| `SNS_PLATFORM_APPLICATION_ARN` | No | SNS push notification ARN |

## iOS Integration

See the `ios-integration/` directory for Swift code examples:

- `AmplifyConfig.swift` - Amplify configuration
- `AuthService.swift` - Authentication operations
- `DataService.swift` - GraphQL data operations
- `StorageService.swift` - S3 file operations

## Documentation

See `backend_setup.md` for complete setup and configuration documentation.

## License

Proprietary - Capybara Wellness Project

# GymPass App - AWS Amplify Gen 2 Backend Setup

Complete backend configuration for a Gym Membership App using AWS Amplify Gen 2.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Authentication Setup](#authentication-setup)
4. [Data Models](#data-models)
5. [Storage Configuration](#storage-configuration)
6. [Authorization Rules](#authorization-rules)
7. [Custom Queries & Mutations](#custom-queries--mutations)
8. [iOS Integration](#ios-integration)
9. [Deployment Guide](#deployment-guide)
10. [Environment Variables](#environment-variables)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        GymPass App Backend                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │  Cognito    │  │  AppSync    │  │  S3 Storage             │ │
│  │  (Auth)     │  │  (GraphQL)  │  │  (Images/Files)         │ │
│  │             │  │             │  │                         │ │
│  │ • Email/PW  │  │ • 8 Models  │  │ • gym-images            │ │
│  │ • Apple     │  │ • 15+ Types │  │ • user-avatars          │ │
│  │ • Google    │  │ • Queries   │  │ • pass-qr-codes         │ │
│  │ • MFA       │  │ • Mutations │  │ • shop-items            │ │
│  │ • 5 Groups  │  │ • 6 Buckets │  │ • community-content     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
amplify/
├── auth/
│   └── resource.ts          # Cognito configuration
├── data/
│   └── resource.ts          # GraphQL schema (8 models)
├── storage/
│   └── resource.ts          # S3 bucket configurations
├── functions/               # Lambda functions (if needed)
└── backend.ts               # Main backend configuration

ios-integration/
├── AmplifyConfiguration.swift   # Amplify setup
├── AuthService.swift            # Authentication
├── GymDataService.swift         # GraphQL operations
├── StorageService.swift         # File uploads/downloads
├── QRCodeService.swift          # QR code generation
└── Models.swift                 # Swift data models
```

---

## Authentication Setup

### Features

| Feature | Description |
|---------|-------------|
| Email/Password | Standard sign up with verification code |
| Apple Sign In | OAuth 2.0 with Apple |
| Google Sign In | OAuth 2.0 with Google |
| MFA | Optional SMS and TOTP |
| Password Policy | Min 8 chars, uppercase, lowercase, digits, symbols |

### User Groups

| Group | Permissions |
|-------|-------------|
| `SUPER_ADMIN` | Full platform access |
| `GYM_ADMIN` | Manage their gym, passes, staff |
| `GYM_STAFF` | Validate passes, process check-ins |
| `MEMBER` | Regular gym members |
| `PREMIUM_MEMBER` | Premium tier benefits |

### Custom Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `custom:membership_tier` | String | FREE, BASIC, PREMIUM, ELITE |
| `custom:total_checkins` | Number | Lifetime check-ins |
| `custom:preferred_gym_id` | String | User's favorite gym |
| `custom:fitness_goals` | String | JSON array of goals |
| `custom:emergency_contact` | String | Emergency contact info |

---

## Data Models

### Model 1: User

Extended user profile with membership information.

```typescript
User {
  // Identity
  id: ID!                    // Cognito sub
  email: Email!              // Primary identifier
  
  // Profile
  firstName: String!
  lastName: String!
  displayName: String
  bio: String
  avatarUrl: URL
  phoneNumber: Phone
  dateOfBirth: Date
  
  // Membership
  membershipTier: MembershipTier  // FREE, BASIC, PREMIUM, ELITE, CORPORATE
  membershipStartDate: Date
  membershipEndDate: Date
  autoRenew: Boolean
  
  // Fitness Profile
  fitnessGoals: [String]
  preferredWorkoutTime: Time
  emergencyContactName: String
  emergencyContactPhone: Phone
  
  // Stats
  totalCheckIns: Int
  totalPassesPurchased: Int
  favoriteGymId: String
  
  // Preferences
  notificationsEnabled: Boolean
  marketingEmailsEnabled: Boolean
  locationSharingEnabled: Boolean
  
  // Relations
  userPasses: [UserPass]
  checkIns: [CheckIn]
  communityPosts: [CommunityPost]
  favorites: [UserFavorite]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
  lastLoginAt: DateTime
}
```

### Model 2: Gym

Gym locations with complete details.

```typescript
Gym {
  // Identity
  id: ID!
  name: String!
  slug: String!              // URL-friendly name
  
  // Description
  description: String
  shortDescription: String
  
  // Location
  address: String!
  city: String!
  state: String!
  zipCode: String!
  country: String           // default: US
  latitude: Float
  longitude: Float
  
  // Contact
  phoneNumber: Phone
  email: Email
  website: URL
  
  // Media
  logoUrl: URL
  coverImageUrl: URL
  galleryImages: [URL]
  
  // Details
  hours: JSON               // { monday: { open, close }, ... }
  amenities: [String]       // ["Pool", "Sauna", "Parking", ...]
  equipment: [String]       // ["Treadmills", "Free Weights", ...]
  
  // Status
  status: GymStatus         // ACTIVE, INACTIVE, MAINTENANCE, CLOSED
  isFeatured: Boolean
  
  // Capacity
  maxCapacity: Int
  currentOccupancy: Int
  
  // Ratings
  averageRating: Float
  totalReviews: Int
  
  // Relations
  passes: [Pass]
  facilities: [Facility]
  checkIns: [CheckIn]
  reviews: [GymReview]
  staff: [GymStaff]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 3: Pass

Different pass types available at gyms.

```typescript
Pass {
  // Identity
  id: ID!
  name: String!             // "Day Pass", "Monthly Unlimited"
  description: String
  
  // Type & Duration
  passType: PassType!       // DAY, WEEK, MONTH, QUARTER, YEAR, PUNCH_CARD, GUEST
  durationDays: Int!        // How long pass is valid
  
  // Pricing
  price: Float!             // Current price
  originalPrice: Float      // For showing discounts
  currency: String          // default: USD
  
  // Features
  features: [String]        // ["Unlimited Access", "Classes Included"]
  includesClasses: Boolean
  includesPool: Boolean
  includesSpa: Boolean
  guestPassesIncluded: Int
  
  // Usage
  maxVisits: Int            // null = unlimited
  maxCheckInsPerDay: Int    // default: 1
  
  // Availability
  isActive: Boolean
  validFrom: Date
  validUntil: Date
  
  // Relations
  gymId: String!
  gym: Gym
  userPasses: [UserPass]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 4: UserPass

User's purchased passes with QR codes.

```typescript
UserPass {
  // Identity
  id: ID!
  
  // QR Code
  qrCodeData: String!       // Encoded pass data
  qrCodeImageUrl: URL       // Generated QR image
  
  // Status
  status: PassStatus        // ACTIVE, USED, EXPIRED, CANCELLED, PENDING
  
  // Usage tracking
  totalVisitsAllowed: Int
  visitsUsed: Int
  visitsRemaining: Int
  
  // Validity
  purchaseDate: DateTime!
  activationDate: DateTime
  expirationDate: DateTime!
  
  // Payment
  paymentId: String
  paymentStatus: String
  amountPaid: Float
  discountApplied: Float
  
  // Relations
  userId: String!
  user: User
  passId: String!
  pass: Pass
  gymId: String!
  checkIns: [CheckIn]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 5: CheckIn

QR code check-in records.

```typescript
CheckIn {
  // Identity
  id: ID!
  
  // Check-in details
  checkInTime: DateTime!
  checkOutTime: DateTime
  status: CheckInStatus     // CHECKED_IN, CHECKED_OUT, NO_SHOW
  
  // QR validation
  qrCodeScanned: String!
  validatedBy: String       // Staff member ID
  validationMethod: String  // QR_SCAN, MANUAL, NFC, BIOMETRIC
  
  // Location
  checkInLatitude: Float
  checkInLongitude: Float
  checkOutLatitude: Float
  checkOutLongitude: Float
  
  // Session
  durationMinutes: Int
  notes: String
  
  // Relations
  userId: String!
  user: User
  gymId: String!
  gym: Gym
  userPassId: String!
  userPass: UserPass
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 6: Facility

Gym facilities and equipment areas.

```typescript
Facility {
  // Identity
  id: ID!
  name: String!             // "Cardio Zone", "Weight Room"
  
  // Type
  facilityType: FacilityType  // CARDIO, STRENGTH, POOL, STUDIO, COURT, SPA, LOCKER, PARKING
  
  // Description
  description: String
  rules: String
  
  // Media
  imageUrl: URL
  
  // Capacity
  capacity: Int
  currentUsers: Int
  
  // Availability
  isOpen: Boolean
  hours: JSON
  requiresBooking: Boolean
  
  // Equipment
  equipmentList: JSON       // [{ name, count, brand }, ...]
  
  // Relations
  gymId: String!
  gym: Gym
  bookings: [FacilityBooking]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 7: ShopItem

Items available in the shop.

```typescript
ShopItem {
  // Identity
  id: ID!
  name: String!
  
  // Type
  itemType: ShopItemType    // PASS, MERCHANDISE, SUPPLEMENT, SERVICE, GIFT_CARD
  
  // Description
  description: String
  shortDescription: String
  
  // Media
  imageUrl: URL
  galleryImages: [URL]
  
  // Pricing
  price: Float!
  originalPrice: Float
  currency: String
  
  // Inventory
  inStock: Boolean
  stockQuantity: Int
  
  // For passes
  linkedPassId: String
  
  // For merchandise
  sku: String
  weight: String
  dimensions: String
  
  // Features
  tags: [String]
  isFeatured: Boolean
  isNew: Boolean
  
  // Ratings
  averageRating: Float
  totalReviews: Int
  
  // Relations
  reviews: [ShopItemReview]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

### Model 8: CommunityPost

Community posts and events.

```typescript
CommunityPost {
  // Identity
  id: ID!
  
  // Content
  title: String!
  content: String!
  postType: PostType        // GENERAL, EVENT, ANNOUNCEMENT, TIP, CHALLENGE
  
  // Media
  imageUrl: URL
  videoUrl: URL
  
  // Engagement
  likes: Int
  comments: Int
  shares: Int
  views: Int
  
  // For events
  eventDate: DateTime
  eventLocation: String
  eventGymId: String
  maxAttendees: Int
  currentAttendees: Int
  
  // Status
  isPinned: Boolean
  isActive: Boolean
  
  // Relations
  authorId: String!
  author: User
  commentsList: [CommunityComment]
  attendees: [EventAttendee]
  
  // Timestamps
  createdAt: DateTime!
  updatedAt: DateTime!
}
```

---

## Storage Configuration

### S3 Buckets

| Bucket | Purpose | Access |
|--------|---------|--------|
| `gym-images` | Gym photos, logos, cover images | Public read, Admin write |
| `user-avatars` | User profile pictures | Owner write, Public read |
| `pass-qr-codes` | Generated QR codes | Owner read, Staff read |
| `shop-items` | Shop item images | Public read, Admin write |
| `community-content` | Post images/videos | Owner write, Public read |
| `documents` | Legal docs, certificates | Varies by type |

### Path Structure

```
gym-images/
├── gyms/{gym_id}/
│   ├── logo.jpg
│   ├── cover.jpg
│   └── gallery/
│       ├── image_1.jpg
│       └── image_2.jpg
└── featured/
    └── promo_banner.jpg

user-avatars/
└── avatars/{user_id}/
    └── avatar_{uuid}.jpg

pass-qr-codes/
└── codes/{user_id}/
    └── qr_{pass_id}.png
```

---

## Authorization Rules

### User Model

```typescript
.authorization((allow) => [
  allow.owner().to(['read', 'update', 'delete']),
  allow.groups(['SUPER_ADMIN']).to(['read', 'update', 'delete']),
  allow.authenticated().to(['read']),
])
```

### Gym Model

```typescript
.authorization((allow) => [
  allow.groups(['GYM_ADMIN', 'SUPER_ADMIN']).to(['read', 'update', 'delete']),
  allow.authenticated().to(['read']),
  allow.guest().to(['read']),
])
```

### UserPass Model

```typescript
.authorization((allow) => [
  allow.owner().to(['read', 'update']),
  allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'update']),
])
```

### CheckIn Model

```typescript
.authorization((allow) => [
  allow.owner().to(['read']),
  allow.groups(['GYM_ADMIN', 'GYM_STAFF', 'SUPER_ADMIN']).to(['read', 'create', 'update']),
])
```

---

## Custom Queries & Mutations

### Queries

| Query | Description | Auth |
|-------|-------------|------|
| `searchGymsByLocation` | Find gyms near coordinates | Public |
| `getActivePasses` | Get user's active passes | Owner |
| `getPassHistory` | Get user's pass history | Owner |
| `getCheckInHistory` | Get user's check-in history | Owner |
| `validateQRCode` | Validate QR for check-in | Staff |
| `getFeaturedGyms` | Get featured gyms | Public |
| `getShopItemsByType` | Filter shop items | Public |

### Mutations

| Mutation | Description | Auth |
|----------|-------------|------|
| `purchasePass` | Purchase a new pass | Authenticated |
| `processCheckIn` | Process QR check-in | Staff |
| `processCheckOut` | Process check-out | Staff |
| `joinEvent` | Register for event | Authenticated |
| `cancelEventRegistration` | Cancel registration | Owner |

---

## iOS Integration

### Required Dependencies

```swift
// Package.swift or Podfile
dependencies: [
    .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0")
]

// Required plugins
- AWSCognitoAuthPlugin
- AWSAPIPlugin
- AWSS3StoragePlugin
```

### Configuration

```swift
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

// In AppDelegate or App init
func configureAmplify() {
    do {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSAPIPlugin())
        try Amplify.add(plugin: AWSS3StoragePlugin())
        try Amplify.configure()
    } catch {
        print("Failed to configure Amplify: \(error)")
    }
}
```

### Usage Examples

#### Sign In

```swift
let result = await AuthService.shared.signIn(
    email: "user@example.com",
    password: "password"
)
```

#### List Gyms

```swift
await GymDataService.shared.listGyms(limit: 20)
let gyms = GymDataService.shared.gyms
```

#### Purchase Pass

```swift
let userPass = await GymDataService.shared.purchasePass(
    passId: "pass-id",
    paymentMethodId: "pm_id",
    discountCode: "SAVE10"
)
```

#### Generate QR Code

```swift
let qrImage = QRCodeService.shared.generatePassQRCode(
    userPass: userPass,
    size: 300
)
```

---

## Deployment Guide

### Prerequisites

```bash
# Install Node.js 18+
nvm install 18
nvm use 18

# Install Amplify CLI
npm install -g @aws-amplify/backend-cli

# Configure AWS credentials
aws configure
```

### Setup

```bash
# 1. Create project directory
mkdir gympass-backend && cd gympass-backend

# 2. Copy all files from output/amplify/
cp -r /path/to/output/amplify/* .

# 3. Install dependencies
npm install

# 4. Set environment variables
cp .env.example .env
# Edit .env with your values
```

### Environment Variables

Create `.env` file:

```bash
# AWS Region
AWS_REGION=us-east-1

# OAuth Providers
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

APPLE_CLIENT_ID=your-apple-client-id
APPLE_TEAM_ID=your-apple-team-id
APPLE_KEY_ID=your-apple-key-id
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"

# SES (for email)
SES_EMAIL_ARN=arn:aws:ses:region:account:identity/noreply@gympass-app.com

# SNS (for SMS)
SNS_SMS_ARN=arn:aws:iam::account:role/SNSSMSRole
SNS_EXTERNAL_ID=your-external-id

# AppSync
APPSYNC_LOGS_ROLE_ARN=arn:aws:iam::account:role/AppSyncLogsRole
```

### Deploy

```bash
# Development sandbox
npx amplify sandbox

# Deploy to cloud
npx amplify deploy

# Generate client code
npx amplify generate
```

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `AWS_REGION` | Yes | AWS region for deployment |
| `GOOGLE_CLIENT_ID` | Yes | Google OAuth client ID |
| `GOOGLE_CLIENT_SECRET` | Yes | Google OAuth client secret |
| `APPLE_CLIENT_ID` | Yes | Apple Sign In client ID |
| `APPLE_TEAM_ID` | Yes | Apple Developer Team ID |
| `APPLE_KEY_ID` | Yes | Apple Sign In key ID |
| `APPLE_PRIVATE_KEY` | Yes | Apple Sign In private key |
| `SES_EMAIL_ARN` | No | SES identity ARN |
| `SNS_SMS_ARN` | No | SNS SMS role ARN |
| `SNS_EXTERNAL_ID` | No | SNS external ID |
| `APPSYNC_LOGS_ROLE_ARN` | No | CloudWatch logs role |

---

## API Usage Examples

### GraphQL Queries

```graphql
# List gyms
query ListGyms {
  listGyms(limit: 10) {
    items {
      id
      name
      address
      city
      averageRating
    }
  }
}

# Get gym details
query GetGym($id: ID!) {
  getGym(id: $id) {
    id
    name
    passes {
      items {
        id
        name
        price
        passType
      }
    }
  }
}

# Get user's passes
query GetUserPasses {
  listUserPasses {
    items {
      id
      status
      qrCodeData
      expirationDate
      pass {
        name
        gym {
          name
        }
      }
    }
  }
}
```

### GraphQL Mutations

```graphql
# Purchase pass
mutation PurchasePass {
  purchasePass(
    passId: "pass-id"
    userId: "user-id"
    paymentMethodId: "pm_id"
  ) {
    id
    qrCodeData
    status
  }
}

# Process check-in
mutation ProcessCheckIn {
  processCheckIn(
    qrCode: "GYM:PASS:abc123:1699999999"
    gymId: "gym-id"
  ) {
    id
    checkInTime
    status
  }
}
```

---

## Security Best Practices

1. **Use least privilege access** - Only grant necessary permissions
2. **Enable MFA** - For admin and staff accounts
3. **Validate QR codes server-side** - Never trust client validation
4. **Rate limiting** - Implement on check-in endpoints
5. **Audit logging** - Log all admin actions
6. **Data encryption** - At rest and in transit
7. **Regular backups** - Enable point-in-time recovery

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| OAuth redirect fails | Check callback URLs in Cognito |
| QR codes not scanning | Verify QR data format |
| Images not loading | Check S3 bucket permissions |
| API unauthorized | Verify auth mode and tokens |

### Debug Commands

```bash
# Check Amplify status
npx amplify status

# View logs
npx amplify logs

# Reset sandbox
npx amplify sandbox delete
n```

---

## Summary

This backend provides:

- **8 Core Models**: User, Gym, Pass, UserPass, CheckIn, Facility, ShopItem, CommunityPost
- **5 User Groups**: SUPER_ADMIN, GYM_ADMIN, GYM_STAFF, MEMBER, PREMIUM_MEMBER
- **3 Auth Methods**: Email/Password, Apple Sign In, Google Sign In
- **6 S3 Buckets**: For images, avatars, QR codes, shop items, community content, documents
- **7 Custom Queries**: For location search, pass history, check-ins
- **5 Custom Mutations**: For purchases, check-ins, event registration

Total: **~2000 lines** of TypeScript backend code + **~1500 lines** of Swift iOS integration code.

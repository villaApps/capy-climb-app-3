# Capybara Gym - Setup Guide

Complete step-by-step guide to set up the Capybara Gym iOS app development environment.

---

## Prerequisites

### Required Software

| Software | Version | Purpose |
|----------|---------|---------|
| macOS | 13.0+ | Operating System |
| Xcode | 15.0+ | iOS Development IDE |
| Swift | 5.9+ | Programming Language |
| Node.js | 18.x+ | Amplify CLI runtime |
| npm | 9.x+ | Package manager |
| AWS CLI | 2.x+ | AWS command line tools |
| Git | 2.40+ | Version control |

### Check Prerequisites

```bash
# Check macOS version
sw_vers -productVersion

# Check Xcode version
xcodebuild -version

# Check Swift version
swift --version

# Check Node.js version
node --version

# Check npm version
npm --version

# Check AWS CLI version
aws --version

# Check Git version
git --version
```

---

## Step 1: Install Xcode

### Option A: Mac App Store (Recommended)

1. Open Mac App Store
2. Search for "Xcode"
3. Click "Get" and install
4. Launch Xcode to complete installation
5. Install additional components when prompted

### Option B: Apple Developer Portal

1. Visit [Apple Developer Downloads](https://developer.apple.com/download/)
2. Sign in with Apple ID
3. Download Xcode 15.x
4. Extract and move to `/Applications`

### Install Command Line Tools

```bash
xcode-select --install
```

### Accept License Agreement

```bash
sudo xcodebuild -license accept
```

---

## Step 2: Install Node.js

### Option A: Using Homebrew (Recommended)

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js
brew install node@18

# Link Node.js
brew link node@18
```

### Option B: Using nvm (Node Version Manager)

```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell configuration
source ~/.zshrc

# Install Node.js 18
nvm install 18
nvm use 18
nvm alias default 18
```

### Verify Installation

```bash
node --version  # Should show v18.x.x
npm --version   # Should show 9.x.x
```

---

## Step 3: Install AWS CLI

### Using Homebrew

```bash
brew install awscli
```

### Using Official Installer

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
rm AWSCLIV2.pkg
```

### Configure AWS CLI

```bash
# Configure with your AWS credentials
aws configure

# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)
```

### Verify Installation

```bash
aws --version
aws sts get-caller-identity
```

---

## Step 4: Install Amplify CLI

```bash
# Install Amplify CLI globally
npm install -g @aws-amplify/cli

# Verify installation
amplify --version
```

### Configure Amplify CLI

```bash
# Configure with your AWS profile
amplify configure

# Follow the prompts:
# 1. Sign in to AWS Console
# 2. Specify AWS region
# 3. Create IAM user (or use existing)
# 4. Enter access key ID and secret
```

---

## Step 5: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/capybara-gym-ios.git

# Navigate to project directory
cd capybara-gym-ios

# Verify project structure
ls -la
```

---

## Step 6: AWS Amplify Initialization

### Initialize Amplify Project

```bash
# Initialize Amplify in the project
amplify init

# Answer the prompts:
# ? Enter a name for the project: capybaragym
# ? Enter a name for the environment: dev
# ? Choose your default editor: Xcode
# ? Choose the type of app that you're building: ios
# ? Do you want to use an AWS profile? Yes
# ? Please choose the profile you want to use: default
```

### Add Authentication

```bash
# Add Cognito authentication
amplify add auth

# Configuration options:
# ? Do you want to use the default authentication and security configuration? Default configuration
# ? How do you want users to be able to sign in? Email
# ? Do you want to configure advanced settings? No, I am done.
```

### Add API (GraphQL)

```bash
# Add GraphQL API
amplify add api

# Configuration options:
# ? Please select from one of the below mentioned services: GraphQL
# ? Provide API name: capybaragymapi
# ? Choose the default authorization type for the API: Amazon Cognito User Pool
# ? Do you want to configure advanced settings for the GraphQL API: No, I am done.
# ? Do you have an annotated GraphQL schema? No
# ? Choose a schema template: Single object with fields (e.g., "Todo" with ID, name, description)
# ? Do you want to edit the schema now? Yes
```

### Edit GraphQL Schema

Open `amplify/backend/api/capybaragymapi/schema.graphql` and replace with:

```graphql
type User @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  email: String!
  firstName: String!
  lastName: String!
  phone: String
  profileImage: String
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type Gym @model @auth(rules: [{ allow: public }, { allow: owner }]) {
  id: ID!
  name: String!
  address: String!
  city: String!
  state: String!
  zipCode: String!
  latitude: Float!
  longitude: Float!
  phone: String
  amenities: [String]
  hours: GymHours
  images: [String]
  rating: Float
  capacity: Int
  currentOccupancy: Int
}

type GymHours {
  monday: String
  tuesday: String
  wednesday: String
  thursday: String
  friday: String
  saturday: String
  sunday: String
}

type Pass @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  userId: ID!
  gymId: ID!
  type: PassType!
  status: PassStatus!
  startDate: AWSDateTime!
  endDate: AWSDateTime!
  price: Float!
  qrCode: String
  checkIns: [CheckIn] @hasMany
  autoRenew: Boolean!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

enum PassType {
  DAY_PASS
  WEEKLY
  MONTHLY
  ANNUAL
}

enum PassStatus {
  ACTIVE
  EXPIRED
  CANCELLED
  PENDING
}

type CheckIn @model @auth(rules: [{ allow: owner }]) {
  id: ID!
  passId: ID!
  gymId: ID!
  timestamp: AWSDateTime!
  latitude: Float
  longitude: Float
}

type PassTypeConfig @model @auth(rules: [{ allow: public }]) {
  id: ID!
  type: PassType!
  name: String!
  description: String!
  basePrice: Float!
  durationDays: Int!
  features: [String]
}
```

### Add Storage (S3)

```bash
# Add S3 storage for images
amplify add storage

# Configuration options:
# ? Please select from one of the below mentioned services: Content (Images, audio, video, etc.)
# ? Please provide a friendly name for your resource that will be used to label this category in the project: capybaragymstorage
# ? Please provide bucket name: capybaragym-storage
# ? Who should have access: Auth and guest users
# ? What kind of access do you want for Authenticated users? create, update, read, delete
# ? What kind of access do you want for Guest users? read
```

### Push Amplify Changes

```bash
# Deploy all Amplify resources
amplify push

# Confirm when prompted
# ? Are you sure you want to continue? Yes
```

### Generate Amplify Configuration

```bash
# Generate amplifyconfiguration.json and awsconfiguration.json
amplify pull

# Files will be generated in the project root
# Move them to Resources folder:
mv amplifyconfiguration.json Resources/
mv awsconfiguration.json Resources/
```

---

## Step 7: Open Project in Xcode

### Option A: Open Package.swift (Recommended)

```bash
# Open the Swift Package Manager project
open Package.swift
```

### Option B: Create Xcode Project (Alternative)

```bash
# Generate Xcode project from Package.swift
swift package generate-xcodeproj

# Open generated project
open CapybaraGym.xcodeproj
```

---

## Step 8: Resolve Dependencies

Xcode will automatically resolve Swift Package Manager dependencies when you open the project. To manually resolve:

```bash
# Resolve dependencies
swift package resolve

# Update dependencies
swift package update
```

---

## Step 9: Configure Info.plist

Create or update `Info.plist` in the project root:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <true/>
    </dict>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- Required Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Capybara Gym needs camera access to scan QR codes for gym check-in.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Capybara Gym needs location access to find nearby gyms.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Capybara Gym needs location access to find nearby gyms even when the app is in the background.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Capybara Gym needs photo library access to upload profile pictures.</string>
    <key>NSFaceIDUsageDescription</key>
    <string>Capybara Gym uses Face ID for secure authentication.</string>
</dict>
</plist>
```

---

## Step 10: Build and Run

### Build Project

```bash
# Build the project
swift build

# Or in Xcode: Cmd+B
```

### Run Tests

```bash
# Run all tests
swift test

# Or in Xcode: Cmd+U
```

### Run on Simulator

1. Select target device in Xcode (e.g., iPhone 15 Pro)
2. Press `Cmd+R` to run

### Run on Physical Device

1. Connect iPhone to Mac
2. Select your device in Xcode
3. Trust the computer on your iPhone
4. Sign in with your Apple ID in Xcode
5. Update signing configuration
6. Press `Cmd+R` to run

---

## Running Tests

### Unit Tests

```bash
# Run unit tests only
xcodebuild test \
  -scheme CapybaraGym \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:CapybaraGymTests/UnitTests
```

### UI Tests

```bash
# Run UI tests only
xcodebuild test \
  -scheme CapybaraGym \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:CapybaraGymTests/UITests
```

### All Tests

```bash
# Run all tests
xcodebuild test \
  -scheme CapybaraGym \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### With Code Coverage

```bash
# Run tests with code coverage
xcodebuild test \
  -scheme CapybaraGym \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES \
  -derivedDataPath ./DerivedData
```

---

## Deployment

### TestFlight Deployment

#### 1. Archive the App

```bash
# Archive for TestFlight
xcodebuild archive \
  -scheme CapybaraGym \
  -archivePath ./build/CapybaraGym.xcarchive \
  -destination 'generic/platform=iOS'
```

#### 2. Export IPA

```bash
# Create export options plist
cat > exportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOF

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/CapybaraGym.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist exportOptions.plist
```

#### 3. Upload to App Store Connect

```bash
# Upload using altool (included with Xcode)
xcrun altool --upload-app \
  --type ios \
  --file ./build/CapybaraGym.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

Or use Xcode:
1. Open Organizer (Window → Organizer)
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow the prompts

### App Store Deployment

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Create new app or select existing
3. Fill in app metadata:
   - App name
   - Subtitle
   - Description
   - Keywords
   - Screenshots
   - App Preview
4. Submit for review

---

## Environment Configuration

### Development Environment

```bash
# Create development config
cat > Config.xcconfig << EOF
// Development Configuration
API_BASE_URL = https://dev-api.capybaragym.com
AMPLIFY_ENV = dev
ENABLE_LOGGING = YES
EOF
```

### Staging Environment

```bash
# Create staging config
cat > Config-Staging.xcconfig << EOF
// Staging Configuration
API_BASE_URL = https://staging-api.capybaragym.com
AMPLIFY_ENV = staging
ENABLE_LOGGING = YES
EOF
```

### Production Environment

```bash
# Create production config
cat > Config-Production.xcconfig << EOF
// Production Configuration
API_BASE_URL = https://api.capybaragym.com
AMPLIFY_ENV = production
ENABLE_LOGGING = NO
EOF
```

---

## Troubleshooting

### Common Issues

#### Issue: "No such module 'Amplify'"

**Solution:**
```bash
# Clean build folder
rm -rf ~/Library/Developer/Xcode/DerivedData

# Resolve packages again
swift package resolve
```

#### Issue: "amplifyconfiguration.json not found"

**Solution:**
```bash
# Pull Amplify configuration
amplify pull

# Verify files exist
ls Resources/amplifyconfiguration.json
ls Resources/awsconfiguration.json
```

#### Issue: "Signing certificate not found"

**Solution:**
1. Open Xcode → Preferences → Accounts
2. Sign in with Apple ID
3. Download manual profiles
4. Update signing in project settings

#### Issue: "Build failed with exit code 1"

**Solution:**
```bash
# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf .build
swift package clean
swift package resolve
```

#### Issue: "Tests fail with timeout"

**Solution:**
```bash
# Reset simulator
xcrun simctl erase all

# Or use specific device
xcrun simctl erase "iPhone 15"
```

---

## Development Workflow

### Daily Development

```bash
# Pull latest changes
git pull origin main

# Run tests before making changes
swift test

# Make your changes
# ...

# Run tests again
swift test

# Commit changes
git add .
git commit -m "Your commit message"
git push origin feature/your-feature
```

### Creating a Pull Request

1. Push your branch to GitHub
2. Create Pull Request on GitHub
3. Ensure all CI checks pass
4. Request code review
5. Merge after approval

---

## Additional Resources

- [Swift Documentation](https://swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/documentation/swiftui/app-essentials)
- [AWS Amplify iOS](https://docs.amplify.aws/lib/q/platform/ios/)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode/)

---

## Support

For setup issues or questions:
- Email: dev-support@capybaragym.com
- Slack: #ios-dev channel
- GitHub Issues: [Create an issue](https://github.com/yourusername/capybara-gym-ios/issues)

---

**Happy Coding!** 🦫💪

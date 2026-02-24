# Capybara Gym iOS App

A modern iOS fitness app built with SwiftUI and AWS Amplify Gen 2.

## Features

- **Authentication**: Secure sign-up/sign-in with AWS Cognito
- **Gym Discovery**: Find nearby gyms with interactive map
- **Pass Management**: Purchase and manage gym passes
- **QR Code Check-in**: Quick and easy gym entry
- **Shop**: Buy day passes, memberships, and promotions
- **Community**: Share workouts, join challenges, and compete on leaderboards
- **Profile**: Track stats, achievements, and manage settings

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
CapybaraGym/
├── App/                    # App entry point and configuration
├── Core/                   # Core utilities and design system
│   ├── DesignSystem/       # Colors, Typography, Components
│   ├── Extensions/         # Swift extensions
│   ├── Utilities/          # Helper utilities
│   └── Architecture/       # ViewState, protocols
├── Features/               # Feature modules
│   ├── Authentication/
│   ├── Home/
│   ├── GymMap/
│   ├── PassManagement/
│   ├── QRCode/
│   ├── Shop/
│   ├── Community/
│   └── Profile/
├── Services/               # Business logic services
│   ├── Amplify/            # AWS Amplify services
│   ├── Location/           # Location services
│   └── QRCode/             # QR code services
├── Navigation/             # Navigation router and root view
└── Resources/              # Assets and configuration files
```

## Design System

### Colors
- **Primary**: #7d3e3a (red-brown)
- **Background**: #f4f4f9 (light gray-blue)
- **Card Background**: #e8e9f2
- **Text Primary**: #0e0c0b
- **Text Secondary**: #6d6f82

### Typography
- **Primary Font**: Outfit
- **Display Font**: Merriweather

### Components
- `CapyButton`: Primary button component with multiple styles
- `CapyTextField`: Text input with validation support
- `CapyCard`: Card component with various styles
- `CapyTabBar`: Custom tab bar

## Dependencies

### Swift Package Manager

```swift
// AWS Amplify
.package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.25.0")

// QR Code Scanner
.package(url: "https://github.com/twostraws/CodeScanner", from: "2.3.0")

// Image Loading
.package(url: "https://github.com/kean/Nuke", from: "12.0.0")
```

### Amplify Plugins
- AWSCognitoAuthPlugin: Authentication
- AWSAPIPlugin: GraphQL API
- AWSS3StoragePlugin: File storage

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/capybara-gym-ios.git
cd capybara-gym-ios
```

### 2. Install Dependencies

Open the project in Xcode and let it resolve Swift Package Manager dependencies automatically.

### 3. Configure AWS Amplify

1. Install Amplify CLI:
```bash
npm install -g @aws-amplify/cli
```

2. Initialize Amplify:
```bash
amplify init
```

3. Add authentication:
```bash
amplify add auth
```

4. Add API:
```bash
amplify add api
```

5. Push changes:
```bash
amplify push
```

6. Update configuration files:
   - `Resources/amplifyconfiguration.json`
   - `Resources/awsconfiguration.json`

### 4. Build and Run

Select your target device/simulator and press `Cmd+R` to build and run.

## Configuration

### Info.plist

The app requires the following permissions:

- **NSCameraUsageDescription**: For QR code scanning
- **NSLocationWhenInUseUsageDescription**: For finding nearby gyms
- **NSPhotoLibraryUsageDescription**: For profile picture upload

### Environment Variables

Create a `Config.xcconfig` file for environment-specific settings:

```
API_BASE_URL = https://api.capybaragym.com
AMPLIFY_ENV = dev
```

## Testing

Run tests using Xcode's test navigator or command line:

```bash
xcodebuild test -scheme CapybaraGym -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Deployment

### App Store Connect

1. Archive the app in Xcode
2. Upload to App Store Connect
3. Configure app metadata
4. Submit for review

### TestFlight

1. Upload build to App Store Connect
2. Add internal/external testers
3. Distribute for testing

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [AWS Amplify](https://aws.amazon.com/amplify/)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [CodeScanner](https://github.com/twostraws/CodeScanner)
- [Nuke](https://github.com/kean/Nuke)

## Support

For support, email support@capybaragym.com or join our Slack channel.

---

Made with ❤️ by the Capybara Gym Team

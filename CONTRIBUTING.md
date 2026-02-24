# Contributing to Capybara Gym

Thank you for your interest in contributing to Capybara Gym! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Making Changes](#making-changes)
- [Submitting Contributions](#submitting-contributions)
- [Issue Reporting](#issue-reporting)
- [Questions?](#questions)

---

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to:

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Respect different viewpoints and experiences

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

**For iOS Development:**
- macOS 14.0+
- Xcode 15.0+
- iOS 16.0+ Simulator
- SwiftLint (`brew install swiftlint`)

**For Web Development:**
- Node.js 20+
- npm or yarn
- Playwright (`npx playwright install`)

**For Backend:**
- AWS CLI configured
- Node.js 18+

### Repository Structure

```
capy-climb-app-3/
├── CapybaraGym/          # iOS SwiftUI Application
├── app/                  # Web React Application
├── amplify/              # AWS Amplify Backend
└── docs/                 # Documentation
```

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/capy-climb-app-3.git
cd capy-climb-app-3

# Add upstream remote
git remote add upstream https://github.com/villaApps/capy-climb-app-3.git
```

### 2. iOS App Setup

```bash
cd CapybaraGym

# Open in Xcode
open CapybaraGym.xcodeproj

# Or build from command line
xcodebuild -scheme CapybaraGym -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 3. Web App Setup

```bash
cd app

# Install dependencies
npm install

# Run development server
npm run dev

# Run tests
npm run test:e2e
```

### 4. Backend Setup

```bash
cd amplify

# Install dependencies
npm install

# Configure AWS credentials
aws configure

# Deploy sandbox environment
npx ampx sandbox
```

---

## Coding Standards

### Test-Driven Development (TDD)

**ALL contributions must follow TDD:**

1. **Write a failing test first**
2. **Write minimal implementation to pass**
3. **Refactor while keeping tests green**

```swift
// Example: Adding a new feature

// Step 1: Write failing test
func testEarnBeadIncreasesCount() async {
    let viewModel = BeadViewModel()
    let initialCount = viewModel.totalBeads
    
    await viewModel.earnBead(.firstCheckIn)
    
    XCTAssertEqual(viewModel.totalBeads, initialCount + 1)
}

// Step 2: Implement to pass
func earnBead(_ type: BeadType) async {
    // Implementation
}

// Step 3: Refactor if needed
```

### Test Coverage Requirements

- **Overall coverage must remain above 90%**
- New code must not lower coverage below threshold
- All new behavior requires tests
- Bug fixes require regression tests

```bash
# Check coverage (iOS)
xcodebuild test -scheme CapybaraGym -enableCodeCoverage YES

# Check coverage (Web)
npm run test:e2e
```

### Swift/SwiftUI Standards

```swift
// ✅ Good: Clear naming, small functions, testable
struct BeadService {
    func earnBead(_ type: BeadType, for userId: String) async throws -> Bead {
        // Implementation
    }
}

// ❌ Bad: Unclear naming, large functions
class bead_svc {
    func doStuff() { /* 100 lines */ }
}
```

**Guidelines:**
- Use `PascalCase` for types, `camelCase` for functions/variables
- Functions should be small and focused (max 30 lines)
- Prefer value types (`struct`, `enum`) over classes
- Use `async/await` for asynchronous code
- Mark functions that can throw with `throws`

### React/TypeScript Standards

```typescript
// ✅ Good: Typed props, pure function, testable
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ label, onClick, disabled }) => {
  return (
    <button onClick={onClick} disabled={disabled}>
      {label}
    </button>
  );
};

// ❌ Bad: Untyped, side effects, hard to test
function btn(props) {
  useEffect(() => { fetchData(); }, []);
  return <button>{props.txt}</button>;
}
```

**Guidelines:**
- Use explicit TypeScript types
- Prefer functional components with hooks
- Keep components small and focused
- Use custom hooks for reusable logic

### Git Commit Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Adding or updating tests
- `refactor:` Code refactoring
- `style:` Formatting changes
- `chore:` Maintenance tasks

**Examples:**
```bash
feat(beads): add legendary bead type for 100-day streak

fix(auth): resolve crash on sign out when offline

test(pass): add UI tests for QR code scanner

docs(readme): update setup instructions for contributors
```

---

## Making Changes

### 1. Create a Feature Branch

```bash
# Pull latest changes
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feat/add-bead-leaderboard

# Or for bug fixes
git checkout -b fix/sync-error-message
```

**Branch Naming:**
- `feat/<description>` - New features
- `fix/<description>` - Bug fixes
- `docs/<description>` - Documentation
- `test/<description>` - Tests
- `refactor/<description>` - Refactoring

### 2. Write Tests First

Before writing any implementation code:

```swift
// CapybaraGymTests/Features/Beads/BeadLeaderboardTests.swift

import XCTest
@testable import CapybaraGym

final class BeadLeaderboardTests: XCTestCase {
    func testLeaderboardSortedByBeadCount() {
        // Arrange
        let viewModel = BeadLeaderboardViewModel()
        
        // Act
        let leaderboard = viewModel.getLeaderboard()
        
        // Assert
        XCTAssertEqual(leaderboard.first?.beadCount, 50)
    }
}
```

### 3. Implement the Feature

Write minimal code to make tests pass:

```swift
// CapybaraGym/Features/Beads/BeadLeaderboardViewModel.swift

@Observable
final class BeadLeaderboardViewModel {
    func getLeaderboard() -> [LeaderboardEntry] {
        // Implementation
    }
}
```

### 4. Run Tests

```bash
# iOS tests
xcodebuild test -scheme CapybaraGym -only-testing:CapybaraGymTests

# Web tests
npm run test:e2e

# Specific test file
npm run test:e2e -- auth.spec.ts
```

### 5. Verify Coverage

```bash
# Generate coverage report
xcodebuild test -scheme CapybaraGym -enableCodeCoverage YES

# Check coverage meets 90% threshold
```

### 6. Lint and Format

```bash
# SwiftLint (iOS)
swiftlint

# ESLint (Web)
npm run lint

# Prettier (Web)
npx prettier --write .
```

---

## Submitting Contributions

### Pull Request Process

1. **Push your branch:**
   ```bash
   git push origin feat/your-feature
   ```

2. **Create Pull Request on GitHub:**
   - Use clear, descriptive title following conventional commits
   - Link related issues: `Closes #123`
   - Fill out the PR template
   - Add screenshots for UI changes

3. **PR Requirements:**
   - All tests must pass
   - Coverage ≥ 90%
   - Code review approval required
   - No merge conflicts
   - CI checks green

4. **Address Review Feedback:**
   ```bash
   # Make requested changes
   git add .
   git commit -m "refactor: address PR feedback"
   git push origin feat/your-feature
   ```

5. **Squash and Merge:**
   - Maintainer will squash commits before merging
   - Keep commit history clean

### PR Template

```markdown
## Description
Brief description of changes

## Related Issue
Closes #123

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Testing
- [ ] Unit tests added/updated
- [ ] UI tests added/updated
- [ ] E2E tests added/updated
- [ ] All tests pass locally

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings

## Screenshots (if applicable)
Add screenshots for UI changes
```

---

## Issue Reporting

### Bug Reports

Use the bug report template and include:

1. **Description:** Clear description of the bug
2. **Steps to Reproduce:** Numbered steps
3. **Expected Behavior:** What should happen
4. **Actual Behavior:** What actually happens
5. **Environment:** iOS version, device, app version
6. **Screenshots/Videos:** If applicable
7. **Logs:** Relevant error logs

**Example:**
```markdown
**Bug:** App crashes when syncing beads offline

**Steps:**
1. Turn off WiFi/cellular
2. Earn a new bead
3. Tap sync button
4. App crashes

**Expected:** Show friendly error message
**Actual:** App crashes to home screen

**Environment:**
- iOS 17.2
- iPhone 15 Pro
- App version 1.2.0
```

### Feature Requests

Use the feature request template:

1. **Description:** What feature and why
2. **Use Case:** Who benefits and how
3. **Proposed Solution:** Your idea
4. **Alternatives:** Other approaches considered
5. **Additional Context:** Mockups, examples

---

## Testing Guidelines

### Unit Tests

```swift
// Test one thing per test
func testBeadServiceEarnsBead() async {
    // Given
    let service = MockBeadService()
    
    // When
    let bead = try await service.earnBead(.firstCheckIn)
    
    // Then
    XCTAssertEqual(bead.type, .firstCheckIn)
}
```

### UI Tests

```swift
func testSignInFlow() {
    let emailField = app.textFields["emailTextField"]
    let passwordField = app.secureTextFields["passwordTextField"]
    
    emailField.tap()
    emailField.typeText("test@example.com")
    
    passwordField.tap()
    passwordField.typeText("password123")
    
    app.buttons["signInButton"].tap()
    
    XCTAssertTrue(app.otherElements["homeView"].waitForExistence(timeout: 5))
}
```

### E2E Tests (Web)

```typescript
test('user can sign in', async ({ page }) => {
  await page.goto('/signin');
  await page.getByPlaceholder('name@example.com').fill('test@example.com');
  await page.getByPlaceholder('Enter your password').fill('password123');
  await page.getByRole('button', { name: 'Sign In' }).click();
  await expect(page).toHaveURL('/');
});
```

---

## Questions?

- **General Questions:** Open a [Discussion](https://github.com/villaApps/capy-climb-app-3/discussions)
- **Bug Reports:** [Create an Issue](https://github.com/villaApps/capy-climb-app-3/issues/new?template=bug_report.md)
- **Feature Requests:** [Create an Issue](https://github.com/villaApps/capy-climb-app-3/issues/new?template=feature_request.md)
- **Security Issues:** Email security@capybaragym.com (do not open public issues)

---

## Recognition

Contributors will be:
- Listed in the README
- Mentioned in release notes
- Added to the contributors page

Thank you for contributing to Capybara Gym! 🏋️‍♂️

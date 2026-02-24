# Quick Start for Contributors

Get started contributing to Capybara Gym in 5 minutes!

## 🚀 Quick Setup

### 1. Fork & Clone

```bash
# Fork on GitHub, then clone
git clone https://github.com/YOUR_USERNAME/capy-climb-app-3.git
cd capy-climb-app-3
git remote add upstream https://github.com/villaApps/capy-climb-app-3.git
```

### 2. Choose Your Platform

#### iOS (SwiftUI)

```bash
cd CapybaraGym
open CapybaraGym.xcodeproj

# Run tests: Cmd+U in Xcode
# Or command line:
xcodebuild test -scheme CapybaraGym
```

#### Web (React + TypeScript)

```bash
cd app
npm install
npm run dev        # Start dev server
npm run test:e2e   # Run E2E tests
```

#### Backend (AWS Amplify)

```bash
cd amplify
npm install
npx ampx sandbox   # Start local backend
```

---

## 📝 Making Your First Contribution

### 1. Find an Issue

Look for issues labeled:
- `good first issue` - Great for beginners
- `help wanted` - Looking for contributors
- `priority:low` - Lower risk

### 2. Create a Branch

```bash
git checkout main
git pull upstream main
git checkout -b feat/your-feature-name
```

### 3. Write Tests First (TDD!)

```swift
// Example: Test first
func testNewFeature() {
    let result = myNewFeature()
    XCTAssertEqual(result, expected)
}
```

### 4. Implement

```swift
// Then implement
func myNewFeature() -> Result {
    // Minimal code to pass test
}
```

### 5. Verify

```bash
# iOS
swiftlint
xcodebuild test -scheme CapybaraGym

# Web
npm run lint
npm run test:e2e
```

### 6. Commit & Push

```bash
git add .
git commit -m "feat: add new feature description"
git push origin feat/your-feature-name
```

### 7. Create Pull Request

Go to GitHub → Click "New Pull Request" → Fill out template

---

## ✅ Before Submitting

- [ ] All tests pass
- [ ] Coverage ≥ 90%
- [ ] No lint errors
- [ ] Follows coding standards
- [ ] PR description is complete

---

## 💡 Tips

- **Start small:** Fix a typo, add a test, improve docs
- **Ask questions:** Comment on issues if unclear
- **Join discussions:** Check GitHub Discussions
- **Be patient:** Reviews take time

---

## 📚 Resources

- [Full Contributing Guide](./CONTRIBUTING.md)
- [Code of Conduct](./CODE_OF_CONDUCT.md)
- [Architecture Docs](./architecture.md)
- [GitHub Issues](https://github.com/villaApps/capy-climb-app-3/issues)

---

## ❓ Need Help?

- **General questions:** [Discussions](https://github.com/villaApps/capy-climb-app-3/discussions)
- **Bug reports:** [New Issue](https://github.com/villaApps/capy-climb-app-3/issues/new)
- **Feature ideas:** [New Issue](https://github.com/villaApps/capy-climb-app-3/issues/new)

Happy contributing! 🎉

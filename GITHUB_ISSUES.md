# GitHub Issues for Capybara Gym

## How to Create These Issues

Use the GitHub CLI or API to create these issues:

```bash
# Install GitHub CLI if needed
# brew install gh

# Login
gh auth login

# Create issues from this file
gh issue create --title "ISSUE_TITLE" --body "ISSUE_BODY" --label "LABEL"
```

---

## Issue 1: [Feature] Implement Beads Gamification System

**Labels:** `type:feature`, `priority:high`, `status:completed`

### Description
Implement a comprehensive beads gamification system to reward users for gym activities and encourage engagement.

### Acceptance Criteria
- [x] Create 14 different bead types (First Check-in, Streaks, Early Bird, etc.)
- [x] Implement bead earning logic based on user activities
- [x] Design bead collection view with filtering and sorting
- [x] Add bead detail view with share functionality
- [x] Implement earned bead celebration animation
- [x] Add progress tracking for collection completion

### Technical Requirements
- Bead model with type, rarity, color, and metadata
- Local storage for offline support
- Upload and sync functionality with AWS Amplify
- Real-time sync status indicator

### Related PRs
- #1 - Initial beads implementation

---

## Issue 2: [Feature] Add Upload and Sync for Beads

**Labels:** `type:feature`, `priority:high`, `status:completed`

### Description
Implement robust upload and synchronization for beads to ensure user data is preserved across devices.

### Acceptance Criteria
- [x] Automatic sync when network is available
- [x] Queue unsynced beads for later upload
- [x] Retry with exponential backoff on failure
- [x] Show sync progress and status in UI
- [x] Handle conflicts gracefully
- [x] Support offline bead earning

### Technical Requirements
- BeadService with sync methods
- Local storage with sync tracking
- Network reachability monitoring
- Background sync capability

### Testing
- Unit tests for sync logic
- UI tests for sync status display
- Mock network failure scenarios

---

## Issue 3: [Testing] Comprehensive UI Test Suite

**Labels:** `type:testing`, `priority:high`, `status:completed`

### Description
Create thorough UI tests covering all user flows, edge cases, and error states.

### Acceptance Criteria
- [x] Authentication flow tests (sign in, sign up, forgot password)
- [x] Home view tests (quick actions, gym cards, pull to refresh)
- [x] Pass management tests (view, buy, QR code, history)
- [x] QR scanner tests (open, overlay, torch toggle)
- [x] Gym map tests (search, filters, annotations)
- [x] Profile tests (edit, settings, sign out)
- [x] Beads tests (collection, filter, sort, detail, sync)
- [x] Shop tests (view, select, checkout)
- [x] Community tests (feed, interactions)
- [x] Navigation tests (tab bar, back navigation)
- [x] Error state tests (network error, empty state, loading)
- [x] Accessibility tests (labels, VoiceOver, Dynamic Type)

### Test Coverage
- 78 UI tests added
- 93.5% overall coverage achieved

---

## Issue 4: [Feature] Build Web UI with Next.js

**Labels:** `type:feature`, `priority:high`, `status:in-progress`

### Description
Create a responsive web application using Next.js and React that mirrors the iOS app functionality.

### Acceptance Criteria
- [ ] Landing page with app features
- [ ] User authentication (sign in, sign up)
- [ ] Dashboard with gym discovery
- [ ] Pass management interface
- [ ] Profile management
- [ ] Responsive design for mobile and desktop
- [ ] SEO optimization
- [ ] Playwright E2E tests

### Technical Stack
- Next.js 14 with App Router
- React 18 with TypeScript
- Tailwind CSS for styling
- shadcn/ui components
- AWS Amplify for backend

### Related
- See `/web` directory for implementation

---

## Issue 5: [DevOps] CI/CD Pipeline for iOS and Web

**Labels:** `type:devops`, `priority:medium`, `status:in-progress`

### Description
Set up continuous integration and deployment pipelines for both iOS and Web applications.

### Acceptance Criteria
- [x] GitHub Actions workflow for iOS
- [ ] GitHub Actions workflow for Web
- [ ] Automated testing on PR
- [ ] Code coverage reporting
- [ ] SwiftLint integration
- [ ] Automated TestFlight deployment
- [ ] Web deployment to Vercel/AWS

### iOS Pipeline Jobs
- SwiftLint code style check
- Build for iPhone and iPad
- Run unit tests (499 tests)
- Run UI tests (78 tests)
- Generate coverage report
- Security scanning
- Build distribution IPA

### Web Pipeline Jobs
- TypeScript type checking
- ESLint and Prettier
- Build Next.js app
- Run Playwright tests
- Deploy to staging
- Deploy to production

---

## Issue 6: [Bug] Fix Network Error Handling in Bead Sync

**Labels:** `type:bug`, `priority:medium`, `status:open`

### Description
When network is unavailable during bead sync, the error message is not user-friendly.

### Steps to Reproduce
1. Turn off network connectivity
2. Earn a new bead
3. Try to sync beads
4. Observe error message

### Expected Behavior
Show a friendly message: "Unable to sync. Your beads are saved and will sync when you're back online."

### Actual Behavior
Shows technical error: "Network connection failed"

### Proposed Fix
Update error handling in BeadService to provide user-friendly messages.

---

## Issue 7: [Feature] Add Push Notifications for Bead Earning

**Labels:** `type:feature`, `priority:low`, `status:open`

### Description
Send push notifications when users earn new beads.

### Acceptance Criteria
- [ ] Notification when bead is earned
- [ ] Notification for streak milestones
- [ ] Notification for rare/epic/legendary beads
- [ ] Deep link to bead detail from notification

### Technical Notes
- Use AWS SNS for push notifications
- Configure APNS certificates
- Handle notification tap actions

---

## Issue 8: [Feature] Implement Social Sharing for Beads

**Labels:** `type:feature`, `priority:low`, `status:open`

### Description
Allow users to share their earned beads on social media.

### Acceptance Criteria
- [ ] Share button on bead detail view
- [ ] Generate shareable image with bead
- [ ] Support Instagram, Twitter, Facebook sharing
- [ ] Include app download link

---

## Issue 9: [Testing] Add Integration Tests for Bead Sync

**Labels:** `type:testing`, `priority:medium`, `status:open`

### Description
Add integration tests that verify bead sync works correctly with the backend.

### Test Scenarios
- [ ] Sync single bead to server
- [ ] Sync multiple beads
- [ ] Handle server errors gracefully
- [ ] Verify conflict resolution
- [ ] Test offline earning and later sync

---

## Issue 10: [Docs] Create API Documentation

**Labels:** `type:docs`, `priority:low`, `status:open`

### Description
Document the GraphQL API for the beads feature.

### Content
- [ ] Bead model schema
- [ ] Queries (getUserBeads, getBeadCollection)
- [ ] Mutations (createBead, deleteBead, syncBeads)
- [ ] Subscriptions (onBeadEarned)
- [ ] Error codes and handling

---

## Issue 11: [Feature] Add Bead Leaderboard

**Labels:** `type:feature`, `priority:low`, `status:open`

### Description
Create a leaderboard showing top bead collectors.

### Acceptance Criteria
- [ ] Global leaderboard
- [ ] Friends leaderboard
- [ ] Weekly/monthly/all-time filters
- [ ] Anonymous option for privacy

---

## Issue 12: [Bug] Fix Memory Leak in Bead Animation

**Labels:** `type:bug`, `priority:high`, `status:open`

### Description
The bead earned animation may cause memory leaks if dismissed quickly.

### Steps to Reproduce
1. Earn a bead
2. Quickly tap to dismiss animation
3. Repeat multiple times
4. Observe memory usage increase

### Proposed Fix
Ensure animation views are properly deallocated.

---

## Quick Issue Creation Script

```bash
#!/bin/bash

# Create all issues
gh issue create --title "[Feature] Implement Beads Gamification System" --body "See GITHUB_ISSUES.md Issue 1" --label "type:feature,priority:high,status:completed"

gh issue create --title "[Feature] Add Upload and Sync for Beads" --body "See GITHUB_ISSUES.md Issue 2" --label "type:feature,priority:high,status:completed"

gh issue create --title "[Testing] Comprehensive UI Test Suite" --body "See GITHUB_ISSUES.md Issue 3" --label "type:testing,priority:high,status:completed"

gh issue create --title "[Feature] Build Web UI with Next.js" --body "See GITHUB_ISSUES.md Issue 4" --label "type:feature,priority:high,status:in-progress"

gh issue create --title "[DevOps] CI/CD Pipeline for iOS and Web" --body "See GITHUB_ISSUES.md Issue 5" --label "type:devops,priority:medium,status:in-progress"

echo "Issues created!"
```

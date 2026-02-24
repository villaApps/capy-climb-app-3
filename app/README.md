# Capybara Gym Web

A modern web application for Capybara Gym built with React, TypeScript, and Tailwind CSS.

## Features

- **Authentication**: Sign in, Sign up, Forgot password with social login (Google, Apple)
- **Home Dashboard**: Stats, quick actions, nearby gyms, weekly progress
- **Gym Map**: Search and filter gyms, view on map
- **Pass Management**: View active/expired passes, QR code display
- **Shop**: Browse and purchase gym passes
- **Community**: Feed, posts, leaderboard, trending topics
- **Beads**: Gamification system with collectible beads
- **Profile**: Edit profile, settings, notifications

## Tech Stack

- **Framework**: React 19 + Vite
- **Language**: TypeScript
- **Styling**: Tailwind CSS 3.4
- **UI Components**: shadcn/ui (40+ components)
- **Routing**: React Router DOM 6
- **State**: React Context
- **Icons**: Lucide React
- **Notifications**: Sonner
- **Testing**: Playwright

## Getting Started

### Prerequisites

- Node.js 20+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

### Running Tests

```bash
# Run all E2E tests
npm run test:e2e

# Run tests with UI
npm run test:e2e:ui

# Debug tests
npm run test:e2e:debug
```

## Project Structure

```
src/
├── components/
│   ├── ui/           # shadcn/ui components
│   └── custom/       # Custom components
├── contexts/         # React contexts (Auth, Theme)
├── layouts/          # Page layouts
├── pages/            # Route pages
│   ├── auth/         # Sign in, Sign up, Forgot password
│   └── ...           # Main pages
├── hooks/            # Custom hooks
├── lib/              # Utilities
└── types/            # TypeScript types
```

## Design System

### Colors

- Primary: `#7d3e3a` (red-brown)
- Background: `#f4f4f9` (light gray-blue)
- Card Background: `#e8e9f2`
- Text Primary: `#0e0c0b`
- Text Secondary: `#6d6f82`

### Typography

- Font: System UI (Inter on web)
- Headings: Semibold
- Body: Regular

## E2E Tests

Tests are written with Playwright and cover:

- Authentication flows
- Navigation
- Home page features
- Pass management
- Beads collection
- Shop functionality
- Community features
- Profile management

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## License

MIT

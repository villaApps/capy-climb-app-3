# Capybara Mobile App - Design Specification

## File Information
- **File Name:** UXRS, Capybara - Mobile App | Client File
- **Last Modified:** 2025-11-14T10:13:49Z
- **Canvas:** 🛠️ Ready for dev
- **Screen Dimensions:** 375 x 812 px (iPhone X standard)

---

## 1. Screens & Navigation Flow

### Primary Screens (25 total)

#### Authentication Flow
| Screen | Components | Description |
|--------|------------|-------------|
| Log in | 6 children | Login with social auth options |
| Sign up | 6 children | Registration screen |

#### Main App Flow
| Screen | Components | Description |
|--------|------------|-------------|
| Home - approved | 2 children | Main dashboard |
| Overview | 5 children | App overview |
| Gym Map | 6 children | Gym location map |
| Boards | 4 children | Community boards |
| Facilities | 4 children | Gym facilities list |

#### Pass Management Flow
| Screen | Components | Description |
|--------|------------|-------------|
| Pass Management - My passes | 6 children | User's active passes |
| Pass Management - Buy passes | 5-7 children | Purchase new passes |
| My Pass, QR code disabled | 7 children | Disabled QR state |
| My Pass, QR code used | 9 children | Used QR state |
| My Pass, History | 4 children | Pass usage history |

#### Shop Flow
| Screen | Components | Description |
|--------|------------|-------------|
| Shop Banner (multiple variants) | 3-6 children | Shop promotional banners |

#### Profile Flow
| Screen | Components | Description |
|--------|------------|-------------|
| Profile Header | 3 children | User profile header |
| Settings Header | 4 children | App settings |
| Join Community Header | 3 children | Community join page |

### Navigation Structure
```
┌─────────────────────────────────────────────────────────────┐
│                         AUTH FLOW                            │
│  Log in ────────────────> Sign up                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      MAIN NAVIGATION                         │
│  (Tab Bar: Home | Gym | QR Code | Community | Profile)      │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │  Home   │          │   Gym   │          │   QR    │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                    │                    │
        ▼                    ▼                    ▼
   Overview ──> Gym Map ──> Boards ──> Facilities
   │
   ▼
   Shop Banner (multiple)

   Pass Management
   │
   ├── My passes
   ├── Buy passes
   ├── QR code (disabled/used)
   └── History

   Profile
   │
   ├── Profile Header
   ├── Settings Header
   └── Join Community Header
```

---

## 2. Color Palette

### Primary Colors
| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Primary Red | `#7d3e3a` | rgb(125, 62, 58) | Primary buttons, brand accents |
| Primary Dark | `#a9332c` | rgb(169, 51, 44) | Logo, emphasis |
| Accent Red | `#bf1b16` | rgb(191, 27, 22) | Alerts, important actions |
| Bright Red | `#e03732` | rgb(224, 55, 50) | Error states |

### Secondary Colors
| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Green | `#618e22` | rgb(97, 142, 34) | Success states |
| Dark Green | `#4b6d1e` | rgb(75, 109, 30) | Success dark |
| Yellow | `#f3c700` | rgb(243, 199, 0) | Warnings, highlights |
| Orange | `#f97c16` | rgb(249, 124, 22) | Secondary accent |
| Brown | `#97580b` | rgb(151, 88, 11) | Tertiary accent |

### Background Colors
| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Background Light | `#f4f4f9` | rgb(244, 244, 249) | Main background |
| Background Blue | `#e8e9f2` | rgb(232, 233, 242) | Card backgrounds |
| Background Blue Alt | `#e8eaf3` | rgb(232, 234, 243) | Input backgrounds |
| Background Green | `#d6ecad` | rgb(214, 236, 173) | Success backgrounds |
| Background Yellow | `#fff5a7` | rgb(255, 245, 167) | Warning backgrounds |
| Background Orange | `#ffe5c2` | rgb(255, 229, 194) | Highlight backgrounds |
| Background Pink | `#ffdedd` | rgb(255, 222, 221) | Error backgrounds |
| Background Rose | `#f4e0df` | rgb(244, 224, 223) | Soft error backgrounds |

### Text Colors
| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Text Primary | `#0e0c0b` | rgb(14, 12, 11) | Main text |
| Text Secondary | `#6d6f82` | rgb(109, 111, 130) | Secondary text |
| Text Tertiary | `#5d5e6c` | rgb(93, 94, 108) | Captions, hints |
| Text Muted | `#636073` | rgb(99, 96, 115) | Disabled text |
| White | `#ffffff` | rgb(255, 255, 255) | Text on dark |

### Border & Stroke Colors
| Color Name | Hex Code | RGB | Usage |
|------------|----------|-----|-------|
| Border Light | `#c7d1e1` | rgb(199, 209, 225) | Input borders |
| Border Lighter | `#d5dbe8` | rgb(213, 219, 232) | Card borders |
| Border Default | `#dbd9d8` | rgb(219, 217, 216) | Divider lines |
| Dark Stroke | `#636366` | rgb(99, 99, 102) | Status bar icons |

---

## 3. Typography Specifications

### Font Families
1. **Outfit** - Primary UI font (Light 300, Regular 400, Medium 500)
2. **Merriweather** - Display/heading font (Regular 400)
3. **SF Pro** - System font for native elements (Semibold 590)

### Type Scale

| Style | Font | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|------|--------|-------------|----------------|-------|
| Display | Merriweather | 34px | 400 | 38px | -0.3px | Large headings |
| H1 | Outfit | 20px | 400 | 24px | -0.4px | Page titles |
| H2 | Outfit | 18px | 500 | 24px | -0.18px | Section headers |
| H3 | Outfit | 16px | 500 | 18px | 0 | Subsection headers |
| Body Large | Outfit | 16px | 300 | 24px | -0.15px | Primary body |
| Body | Outfit | 14px | 300 | 20px | 0 | Standard body |
| Body Medium | Outfit | 14px | 400 | 18px | 0 | Emphasized body |
| Caption | Outfit | 12px | 300 | 14px | -0.15px | Labels, captions |
| Caption Medium | Outfit | 12px | 500 | 14px | 0 | Emphasized captions |
| Small | Outfit | 10px | 300 | 12px | -0.15px | Fine print |
| Button | Outfit | 14px | 500 | 16px | 0 | Button text |
| Nav Label | Outfit | 12px | 400 | 14px | 0 | Tab bar labels |

---

## 4. UI Components

### Buttons

#### Primary Button
- **Size:** 342 x 48 px
- **Background:** `#7d3e3a`
- **Text Color:** `#ffffff`
- **Corner Radius:** 100 px (fully rounded)
- **Padding:** 12px 16px
- **Font:** Outfit 14px Medium

#### Secondary Button (Social Auth)
- **Size:** 342 x 48 px
- **Background:** `#ffffff` with border
- **Text Color:** `#7d3e3a`
- **Corner Radius:** 100 px
- **Icon Size:** 16 x 16 px
- **Padding:** 12px 16px

#### Small Button
- **Size:** 106 x 44 px
- **Background:** `#7d3e3a`
- **Text Color:** `#7d3e3a` (outlined variant)
- **Corner Radius:** 100 px
- **Padding:** 12px 16px

### Input Fields

#### Standard Input
- **Size:** 342 x 50 px
- **Background:** `#e8eaf3`
- **Corner Radius:** 12 px
- **Padding:** 16px
- **Label Font:** Outfit 12px Regular
- **Placeholder Font:** Outfit 14px Light
- **Caption Font:** Outfit 12px Light
- **Icon Size:** 24 x 24 px

#### Input States
- **Default:** `#e8eaf3` background
- **Focused:** Border color `#c7d1e1`
- **Error:** Background `#ffdedd`

### Cards

#### Gym Card
- **Size:** 343 x 432 px
- **Background:** `#f4f4f9`
- **Corner Radius:** 16 px
- **Padding:** 16px

#### Occupancy Card
- **Size:** 343 x 136 px (large) / 167.5 x 94 px (small)
- **Background:** `#e8eaf3`
- **Corner Radius:** 16 px
- **Padding:** 16px

### Tab Bar

#### Navigation Bar
- **Size:** 375 x 64 px
- **Background:** `#e8eaf3`
- **Item Size:** 68 x 48 px
- **Icon Size:** 24 x 24 px
- **Label Font:** Outfit 12px Regular
- **Active Color:** `#0e0c0b`
- **Inactive Color:** `#636073`

#### Home Indicator
- **Size:** 134 x 5 px
- **Background:** `#0e0c0b`
- **Corner Radius:** 100 px

### Icons

#### Standard Icon
- **Size:** 24 x 24 px
- **Stroke Width:** 1.5-2px
- **Color:** Inherits from parent

#### Small Icon
- **Size:** 16 x 16 px
- **Usage:** Button icons, inline icons

#### Tab Icons
- Buildings (Home)
- ShoppingCartSimple (Shop)
- QrCode (QR Scanner)
- UsersFour (Community)
- User (Profile)

### Status Bar
- **Size:** 375 x 53 px
- **Time Font:** SF Pro 17px Semibold
- **Icons:** Cellular, WiFi, Battery

---

## 5. Spacing & Layout

### Spacing Scale
| Token | Value | Usage |
|-------|-------|-------|
| space-2 | 2px | Micro spacing |
| space-4 | 4px | Tight spacing |
| space-8 | 8px | Compact spacing |
| space-12 | 12px | Default spacing |
| space-16 | 16px | Standard padding |
| space-20 | 20px | Medium spacing |
| space-24 | 24px | Large spacing |
| space-30 | 30px | Section spacing |
| space-60 | 60px | Large section gaps |

### Padding Patterns
- **Card Padding:** 16px (all sides)
- **Button Padding:** 12px 16px (vertical/horizontal)
- **Input Padding:** 16px
- **Screen Padding:** 16px horizontal

### Corner Radius Scale
| Token | Value | Usage |
|-------|-------|-------|
| radius-sm | 4px | Small elements |
| radius-md | 8px | Inputs, small cards |
| radius-lg | 12px | Cards, modals |
| radius-xl | 16px | Large cards |
| radius-full | 100px | Buttons, pills |

### Layout Grid
- **Screen Width:** 375px
- **Content Width:** 343px (with 16px margins)
- **Columns:** Flexible based on content
- **Gutter:** 16px

---

## 6. Image Assets & Icons

### Required Icons (2593+ vectors in design)

#### Navigation Icons (24x24)
- Buildings (Home tab)
- ShoppingCartSimple (Shop tab)
- QrCode (QR tab)
- UsersFour (Community tab)
- User (Profile tab)

#### Action Icons (24x24)
- ArrowLeft (Back navigation)
- Headphones (Support)
- MagnifyingGlass (Search)
- EyeClosed (Password visibility)

#### Social Icons (16x16)
- GoogleLogo
- AppleLogo
- LineLogo

#### Status Icons (16x16)
- Asterisk (Decorative)
- info (Information)

### Image Assets
- **Gym Logo:** 36 x 36 px
- **Shop Banners:** Various sizes (375px width)
- **Profile Images:** Circular, various sizes

---

## 7. Animation & Interaction Specifications

### Button Interactions
- **Hover:** Opacity 0.8
- **Active/Press:** Scale 0.98
- **Disabled:** Opacity 0.5

### Tab Bar Interactions
- **Active State:** Color change + optional scale
- **Transition:** 200ms ease-out

### Input Interactions
- **Focus:** Border highlight
- **Transition:** 150ms ease

### Card Interactions
- **Press:** Elevation/shadow change
- **Transition:** 200ms ease

### Screen Transitions
- **Default:** Slide from right (push)
- **Modal:** Slide from bottom
- **Duration:** 300ms
- **Easing:** ease-in-out

---

## 8. Responsive Design Requirements

### Breakpoints
| Device | Width | Height | Notes |
|--------|-------|--------|-------|
| iPhone SE | 375px | 667px | Minimum support |
| iPhone X/11/12 | 375px | 812px | Primary design |
| iPhone 14/15 | 393px | 852px | Scale up |
| iPhone 14/15 Pro Max | 430px | 932px | Maximum width |

### Responsive Rules
1. **Content scales proportionally** within 375-430px width
2. **Safe areas** respected for notch devices
3. **Tab bar** stays fixed at bottom
4. **Status bar** adapts to device
5. **Images** use aspect ratio preservation
6. **Text** scales with Dynamic Type support

### Safe Area Insets
- **Top:** 44px (notch area)
- **Bottom:** 34px (home indicator)
- **Horizontal:** 0px (full width content)

---

## 9. Component Hierarchy Example

```
Screen (375x812)
├── Status Bar (375x53)
│   ├── Time
│   └── Indicators (Cellular, WiFi, Battery)
├── Header (if applicable)
│   ├── Logo
│   └── Action Icons
├── Content Area
│   ├── Cards
│   ├── Lists
│   └── Forms
└── Tab Bar (375x64 + 20 home indicator)
    ├── Navigation Items (5 tabs)
    └── Home Indicator
```

---

## 10. Design Tokens Summary

### Colors
```css
--color-primary: #7d3e3a;
--color-primary-dark: #a9332c;
--color-accent-red: #bf1b16;
--color-success: #618e22;
--color-warning: #f3c700;
--color-background: #f4f4f9;
--color-background-card: #e8e9f2;
--color-text-primary: #0e0c0b;
--color-text-secondary: #6d6f82;
--color-text-muted: #636073;
--color-border: #c7d1e1;
```

### Typography
```css
--font-primary: 'Outfit', sans-serif;
--font-display: 'Merriweather', serif;
--font-system: 'SF Pro', -apple-system, sans-serif;

--text-display: 34px/38px;
--text-h1: 20px/24px;
--text-h2: 18px/24px;
--text-body: 14px/20px;
--text-caption: 12px/14px;
--text-small: 10px/12px;
```

### Spacing
```css
--space-4: 4px;
--space-8: 8px;
--space-12: 12px;
--space-16: 16px;
--space-24: 24px;
--space-32: 32px;
```

### Border Radius
```css
--radius-sm: 4px;
--radius-md: 8px;
--radius-lg: 12px;
--radius-xl: 16px;
--radius-full: 100px;
```

---

*Generated from Figma file: UXRS, Capybara - Mobile App | Client File*
*Node ID: 2001-63*
*Last Updated: 2025-11-14*

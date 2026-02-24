import { test, expect } from '@playwright/test'

test.describe('Home Page', () => {
  test.beforeEach(async ({ page }) => {
    // Sign in first
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
  })

  test('should display home page with welcome message', async ({ page }) => {
    await expect(page.getByRole('heading', { name: /Welcome back/ })).toBeVisible()
    await expect(page.getByText('Ready for your next workout?')).toBeVisible()
  })

  test('should display stats cards', async ({ page }) => {
    await expect(page.getByText('Streak')).toBeVisible()
    await expect(page.getByText('Weekly Goal')).toBeVisible()
    await expect(page.getByText('Beads')).toBeVisible()
    await expect(page.getByText('This Week')).toBeVisible()
  })

  test('should display quick action buttons', async ({ page }) => {
    await expect(page.getByRole('link', { name: 'Find Gym' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'My Pass' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'Buy Pass' })).toBeVisible()
    await expect(page.getByRole('link', { name: 'My Beads' })).toBeVisible()
  })

  test('should display nearby gyms', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Nearby Gyms' })).toBeVisible()
    await expect(page.getByText('Downtown Fitness')).toBeVisible()
    await expect(page.getByText('Sunset Gym')).toBeVisible()
  })

  test('should display weekly progress', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Weekly Progress' })).toBeVisible()
    await expect(page.getByRole('progressbar')).toBeVisible()
  })

  test('should display recent activity', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Recent Activity' })).toBeVisible()
  })
})

test.describe('Navigation', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
  })

  test('should navigate to Map page', async ({ page }) => {
    await page.getByRole('link', { name: 'Map' }).first().click()
    await expect(page).toHaveURL('/map')
    await expect(page.getByPlaceholder('Search gyms...')).toBeVisible()
  })

  test('should navigate to Passes page', async ({ page }) => {
    await page.getByRole('link', { name: 'My Pass' }).click()
    await expect(page).toHaveURL('/passes')
    await expect(page.getByRole('heading', { name: 'My Passes' })).toBeVisible()
  })

  test('should navigate to Community page', async ({ page }) => {
    await page.getByRole('link', { name: 'Community' }).first().click()
    await expect(page).toHaveURL('/community')
    await expect(page.getByRole('heading', { name: 'Community' })).toBeVisible()
  })

  test('should navigate to Profile page', async ({ page }) => {
    await page.getByRole('link', { name: 'Profile' }).first().click()
    await expect(page).toHaveURL('/profile')
    await expect(page.getByRole('heading', { name: /Profile|My Profile/ })).toBeVisible()
  })

  test('should navigate to Beads page', async ({ page }) => {
    await page.goto('/beads')
    await expect(page.getByRole('heading', { name: 'My Beads' })).toBeVisible()
  })
})

test.describe('Pass Management', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
    await page.goto('/passes')
  })

  test('should display pass tabs', async ({ page }) => {
    await expect(page.getByRole('tab', { name: 'Active' })).toBeVisible()
    await expect(page.getByRole('tab', { name: 'Expired' })).toBeVisible()
    await expect(page.getByRole('tab', { name: 'History' })).toBeVisible()
  })

  test('should switch between tabs', async ({ page }) => {
    await page.getByRole('tab', { name: 'Expired' }).click()
    await expect(page.getByRole('tabpanel', { name: 'Expired' })).toBeVisible()
    
    await page.getByRole('tab', { name: 'History' }).click()
    await expect(page.getByRole('tabpanel', { name: 'History' })).toBeVisible()
  })

  test('should navigate to shop from passes page', async ({ page }) => {
    await page.getByRole('button', { name: 'Buy Pass' }).click()
    await expect(page).toHaveURL('/shop')
  })
})

test.describe('Beads Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
    await page.goto('/beads')
  })

  test('should display beads collection', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'My Beads' })).toBeVisible()
    await expect(page.getByText('Total Beads')).toBeVisible()
    await expect(page.getByText('Unique Types')).toBeVisible()
    await expect(page.getByText('Complete')).toBeVisible()
  })

  test('should display progress bar', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Collection Progress' })).toBeVisible()
    await expect(page.getByRole('progressbar')).toBeVisible()
  })

  test('should filter beads by rarity', async ({ page }) => {
    await page.getByRole('button', { name: 'Filter' }).click()
    await page.getByRole('menuitem', { name: 'Rare' }).click()
    // Check that filter is applied
  })

  test('should sort beads', async ({ page }) => {
    await page.getByRole('button', { name: 'Sort' }).click()
    await page.getByRole('menuitem', { name: 'By Rarity' }).click()
    // Check that sorting is applied
  })
})

test.describe('Shop Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
    await page.goto('/shop')
  })

  test('should display pass options', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Pass Shop' })).toBeVisible()
    await expect(page.getByText('Day Pass')).toBeVisible()
    await expect(page.getByText('Monthly Pass')).toBeVisible()
    await expect(page.getByText('Annual Pass')).toBeVisible()
  })

  test('should display prices', async ({ page }) => {
    await expect(page.getByText('$15')).toBeVisible()
    await expect(page.getByText('$99')).toBeVisible()
  })

  test('should switch between tabs', async ({ page }) => {
    await page.getByRole('tab', { name: 'Short Term' }).click()
    await expect(page.getByRole('tabpanel', { name: 'Short Term' })).toBeVisible()
  })
})

test.describe('Community Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
    await page.goto('/community')
  })

  test('should display community stats', async ({ page }) => {
    await expect(page.getByText('Members')).toBeVisible()
    await expect(page.getByText('Active Today')).toBeVisible()
    await expect(page.getByText('Total Check-ins')).toBeVisible()
  })

  test('should display posts', async ({ page }) => {
    await expect(page.getByPlaceholder('Share your fitness journey...')).toBeVisible()
  })

  test('should display leaderboard', async ({ page }) => {
    await expect(page.getByText("This Week's Leaders")).toBeVisible()
  })

  test('should like a post', async ({ page }) => {
    const likeButton = page.locator('button').filter({ has: page.locator('[data-liked="false"]') }).first()
    await likeButton.click()
    // Verify like is registered
  })
})

test.describe('Profile Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await page.waitForURL('/')
    await page.goto('/profile')
  })

  test('should display profile info', async ({ page }) => {
    await expect(page.getByText('Premium Member')).toBeVisible()
    await expect(page.getByText('Check-ins')).toBeVisible()
    await expect(page.getByText('Beads')).toBeVisible()
    await expect(page.getByText('Day Streak')).toBeVisible()
  })

  test('should display menu items', async ({ page }) => {
    await expect(page.getByText('My Beads')).toBeVisible()
    await expect(page.getByText('My Passes')).toBeVisible()
    await expect(page.getByText('Settings')).toBeVisible()
  })

  test('should display notification settings', async ({ page }) => {
    await expect(page.getByText('Push Notifications')).toBeVisible()
    await expect(page.getByText('Email Notifications')).toBeVisible()
  })

  test('should toggle notifications', async ({ page }) => {
    const toggle = page.locator('button[role="switch"]').first()
    const initialState = await toggle.getAttribute('aria-checked')
    await toggle.click()
    const newState = await toggle.getAttribute('aria-checked')
    expect(newState).not.toBe(initialState)
  })
})

test.describe('404 Page', () => {
  test('should display 404 for non-existent routes', async ({ page }) => {
    await page.goto('/non-existent-page')
    await expect(page.getByRole('heading', { name: 'Page Not Found' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Go Home' })).toBeVisible()
  })

  test('should navigate home from 404', async ({ page }) => {
    await page.goto('/non-existent-page')
    await page.getByRole('button', { name: 'Go Home' }).click()
    await expect(page).toHaveURL('/')
  })
})

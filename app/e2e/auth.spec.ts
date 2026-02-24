import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signin')
  })

  test('should display sign in page', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Welcome back' })).toBeVisible()
    await expect(page.getByPlaceholder('name@example.com')).toBeVisible()
    await expect(page.getByPlaceholder('Enter your password')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Sign In' })).toBeVisible()
  })

  test('should show error for invalid email', async ({ page }) => {
    await page.getByPlaceholder('name@example.com').fill('invalid-email')
    await page.getByPlaceholder('Enter your password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    
    await expect(page.getByText('Please enter a valid email')).toBeVisible()
  })

  test('should show error for empty fields', async ({ page }) => {
    await page.getByRole('button', { name: 'Sign In' }).click()
    await expect(page.getByText('Email is required')).toBeVisible()
  })

  test('should toggle password visibility', async ({ page }) => {
    const passwordInput = page.getByPlaceholder('Enter your password')
    const toggleButton = page.locator('button[aria-label="Toggle password visibility"]').first()
    
    await expect(passwordInput).toHaveAttribute('type', 'password')
    await toggleButton.click()
    await expect(passwordInput).toHaveAttribute('type', 'text')
  })

  test('should navigate to sign up page', async ({ page }) => {
    await page.getByRole('link', { name: 'Sign up' }).click()
    await expect(page).toHaveURL('/signup')
    await expect(page.getByRole('heading', { name: 'Create an account' })).toBeVisible()
  })

  test('should navigate to forgot password page', async ({ page }) => {
    await page.getByRole('link', { name: 'Forgot password?' }).click()
    await expect(page).toHaveURL('/forgot-password')
    await expect(page.getByRole('heading', { name: 'Forgot password?' })).toBeVisible()
  })
})

test.describe('Sign Up', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signup')
  })

  test('should display sign up page', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Create an account' })).toBeVisible()
    await expect(page.getByPlaceholder('John')).toBeVisible()
    await expect(page.getByPlaceholder('Doe')).toBeVisible()
    await expect(page.getByPlaceholder('name@example.com')).toBeVisible()
  })

  test('should validate password requirements', async ({ page }) => {
    await page.getByPlaceholder('John').fill('Test')
    await page.getByPlaceholder('Doe').fill('User')
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByPlaceholder('Create a password').fill('weak')
    await page.getByPlaceholder('Confirm your password').fill('weak')
    await page.getByRole('checkbox').check()
    await page.getByRole('button', { name: 'Create Account' }).click()
    
    await expect(page.getByText('Password must be at least 8 characters')).toBeVisible()
  })

  test('should validate password match', async ({ page }) => {
    await page.getByPlaceholder('Create a password').fill('Password123!')
    await page.getByPlaceholder('Confirm your password').fill('Different123!')
    await page.getByRole('button', { name: 'Create Account' }).click()
    
    await expect(page.getByText('Passwords do not match')).toBeVisible()
  })
})

test.describe('Forgot Password', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/forgot-password')
  })

  test('should display forgot password page', async ({ page }) => {
    await expect(page.getByRole('heading', { name: 'Forgot password?' })).toBeVisible()
    await expect(page.getByPlaceholder('name@example.com')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Send Reset Link' })).toBeVisible()
  })

  test('should show success message after submission', async ({ page }) => {
    await page.getByPlaceholder('name@example.com').fill('test@example.com')
    await page.getByRole('button', { name: 'Send Reset Link' }).click()
    
    await expect(page.getByRole('heading', { name: 'Check your email' })).toBeVisible()
  })
})

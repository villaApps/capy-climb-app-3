import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { Toaster } from '@/components/ui/sonner'
import { AuthProvider } from '@/contexts/AuthContext'
import { ThemeProvider } from '@/contexts/ThemeContext'
import { MainLayout } from '@/layouts/MainLayout'
import { AuthLayout } from '@/layouts/AuthLayout'

// Auth Pages
import { SignInPage } from '@/pages/auth/SignInPage'
import { SignUpPage } from '@/pages/auth/SignUpPage'
import { ForgotPasswordPage } from '@/pages/auth/ForgotPasswordPage'

// Main Pages
import { HomePage } from '@/pages/HomePage'
import { GymMapPage } from '@/pages/GymMapPage'
import { PassManagementPage } from '@/pages/PassManagementPage'
import { ShopPage } from '@/pages/ShopPage'
import { CommunityPage } from '@/pages/CommunityPage'
import { ProfilePage } from '@/pages/ProfilePage'
import { BeadsPage } from '@/pages/BeadsPage'

// Error Pages
import { NotFoundPage } from '@/pages/NotFoundPage'

function App() {
  return (
    <ThemeProvider defaultTheme="light" storageKey="capybara-theme">
      <AuthProvider>
        <Router>
          <Routes>
            {/* Auth Routes */}
            <Route element={<AuthLayout />}>
              <Route path="/signin" element={<SignInPage />} />
              <Route path="/signup" element={<SignUpPage />} />
              <Route path="/forgot-password" element={<ForgotPasswordPage />} />
            </Route>

            {/* Main Routes */}
            <Route element={<MainLayout />}>
              <Route path="/" element={<HomePage />} />
              <Route path="/map" element={<GymMapPage />} />
              <Route path="/passes" element={<PassManagementPage />} />
              <Route path="/shop" element={<ShopPage />} />
              <Route path="/community" element={<CommunityPage />} />
              <Route path="/profile" element={<ProfilePage />} />
              <Route path="/beads" element={<BeadsPage />} />
            </Route>

            {/* Redirects */}
            <Route path="/login" element={<Navigate to="/signin" replace />} />
            <Route path="/register" element={<Navigate to="/signup" replace />} />

            {/* 404 */}
            <Route path="*" element={<NotFoundPage />} />
          </Routes>
        </Router>
        <Toaster position="top-right" richColors />
      </AuthProvider>
    </ThemeProvider>
  )
}

export default App

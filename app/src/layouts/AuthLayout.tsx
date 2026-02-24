import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Loader2 } from 'lucide-react'

export function AuthLayout() {
  const { isAuthenticated, isLoading } = useAuth()
  const location = useLocation()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f4f4f9]">
        <Loader2 className="h-8 w-8 animate-spin text-[#7d3e3a]" />
      </div>
    )
  }

  if (isAuthenticated) {
    return <Navigate to="/" state={{ from: location }} replace />
  }

  return (
    <div className="min-h-screen bg-[#f4f4f9] flex flex-col">
      {/* Header */}
      <header className="w-full py-6 px-4">
        <div className="max-w-md mx-auto flex items-center justify-center">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-[#7d3e3a] flex items-center justify-center">
              <span className="text-white font-bold text-lg">C</span>
            </div>
            <span className="text-xl font-semibold text-[#0e0c0b]">Capybara Gym</span>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex items-center justify-center px-4 py-8">
        <div className="w-full max-w-md">
          <Outlet />
        </div>
      </main>

      {/* Footer */}
      <footer className="w-full py-6 px-4 text-center">
        <p className="text-sm text-[#6d6f82]">
          © 2024 Capybara Gym. All rights reserved.
        </p>
      </footer>
    </div>
  )
}

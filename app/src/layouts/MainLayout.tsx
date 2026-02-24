import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { MainNav } from '@/components/custom/MainNav'
import { MobileNav } from '@/components/custom/MobileNav'
import { Loader2 } from 'lucide-react'

export function MainLayout() {
  const { isAuthenticated, isLoading } = useAuth()
  const location = useLocation()

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#f4f4f9]">
        <Loader2 className="h-8 w-8 animate-spin text-[#7d3e3a]" />
      </div>
    )
  }

  if (!isAuthenticated) {
    return <Navigate to="/signin" state={{ from: location }} replace />
  }

  return (
    <div className="min-h-screen bg-[#f4f4f9] flex flex-col">
      {/* Desktop Navigation */}
      <MainNav />

      {/* Main Content */}
      <main className="flex-1 pb-20 md:pb-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <Outlet />
        </div>
      </main>

      {/* Mobile Navigation */}
      <MobileNav />
    </div>
  )
}

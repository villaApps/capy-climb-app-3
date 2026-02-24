import { Link, useLocation } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { Home, Map, QrCode, Users, User, LogOut, Settings, Trophy } from 'lucide-react'

const navItems = [
  { path: '/', label: 'Home', icon: Home },
  { path: '/map', label: 'Map', icon: Map },
  { path: '/community', label: 'Community', icon: Users },
]

export function MainNav() {
  const location = useLocation()
  const { user, signOut } = useAuth()

  return (
    <header className="hidden md:block sticky top-0 z-50 w-full bg-white border-b border-[#e8e9f2]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-full bg-[#7d3e3a] flex items-center justify-center">
              <span className="text-white font-bold text-sm">C</span>
            </div>
            <span className="font-semibold text-[#0e0c0b]">Capybara Gym</span>
          </Link>

          {/* Navigation */}
          <nav className="flex items-center gap-1">
            {navItems.map((item) => {
              const Icon = item.icon
              const isActive = location.pathname === item.path
              return (
                <Link key={item.path} to={item.path}>
                  <Button
                    variant="ghost"
                    className={`flex items-center gap-2 ${
                      isActive 
                        ? 'bg-[#f4f4f9] text-[#7d3e3a]' 
                        : 'text-[#6d6f82] hover:text-[#0e0c0b] hover:bg-[#f4f4f9]'
                    }`}
                  >
                    <Icon className="h-4 w-4" />
                    {item.label}
                  </Button>
                </Link>
              )
            })}
          </nav>

          {/* Right Side */}
          <div className="flex items-center gap-2">
            {/* Quick Actions */}
            <Link to="/passes">
              <Button variant="ghost" size="icon" className="text-[#6d6f82] hover:text-[#0e0c0b]">
                <QrCode className="h-5 w-5" />
              </Button>
            </Link>

            <Link to="/beads">
              <Button variant="ghost" size="icon" className="text-[#6d6f82] hover:text-[#0e0c0b]">
                <Trophy className="h-5 w-5" />
              </Button>
            </Link>

            {/* User Menu */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-full bg-[#7d3e3a] flex items-center justify-center text-white font-medium text-sm">
                    {user?.firstName?.[0] || 'U'}
                  </div>
                  <span className="text-sm text-[#0e0c0b] hidden lg:inline">{user?.displayName}</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuItem asChild>
                  <Link to="/profile" className="flex items-center gap-2 cursor-pointer">
                    <User className="h-4 w-4" />
                    Profile
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link to="/passes" className="flex items-center gap-2 cursor-pointer">
                    <QrCode className="h-4 w-4" />
                    My Passes
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link to="/beads" className="flex items-center gap-2 cursor-pointer">
                    <Trophy className="h-4 w-4" />
                    My Beads
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link to="/settings" className="flex items-center gap-2 cursor-pointer">
                    <Settings className="h-4 w-4" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem 
                  onClick={() => signOut()}
                  className="flex items-center gap-2 cursor-pointer text-red-600 focus:text-red-600"
                >
                  <LogOut className="h-4 w-4" />
                  Sign Out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </div>
    </header>
  )
}

import { Link, useLocation } from 'react-router-dom'
import { Home, Map, QrCode, Users, User } from 'lucide-react'
import { cn } from '@/lib/utils'

const navItems = [
  { path: '/', label: 'Home', icon: Home },
  { path: '/map', label: 'Map', icon: Map },
  { path: '/passes', label: 'Scan', icon: QrCode, isCenter: true },
  { path: '/community', label: 'Community', icon: Users },
  { path: '/profile', label: 'Profile', icon: User },
]

export function MobileNav() {
  const location = useLocation()

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-white border-t border-[#e8e9f2] pb-safe">
      <div className="flex items-center justify-around h-16">
        {navItems.map((item) => {
          const Icon = item.icon
          const isActive = location.pathname === item.path
          
          if (item.isCenter) {
            return (
              <Link
                key={item.path}
                to={item.path}
                className="relative -top-4"
              >
                <div className={cn(
                  "w-14 h-14 rounded-full flex items-center justify-center shadow-lg transition-all",
                  isActive 
                    ? "bg-[#7d3e3a] text-white scale-110" 
                    : "bg-[#7d3e3a] text-white hover:scale-105"
                )}>
                  <Icon className="h-6 w-6" />
                </div>
                <span className={cn(
                  "absolute -bottom-5 left-1/2 -translate-x-1/2 text-xs whitespace-nowrap",
                  isActive ? "text-[#7d3e3a] font-medium" : "text-[#6d6f82]"
                )}>
                  {item.label}
                </span>
              </Link>
            )
          }

          return (
            <Link
              key={item.path}
              to={item.path}
              className={cn(
                "flex flex-col items-center justify-center gap-1 flex-1 h-full transition-colors",
                isActive ? "text-[#7d3e3a]" : "text-[#6d6f82]"
              )}
            >
              <Icon className={cn("h-5 w-5", isActive && "fill-current")} />
              <span className={cn(
                "text-xs",
                isActive && "font-medium"
              )}>
                {item.label}
              </span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}

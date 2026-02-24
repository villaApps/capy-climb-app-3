import { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Separator } from '@/components/ui/separator'
import { Switch } from '@/components/ui/switch'
import { 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Trophy, 
  Ticket, 
  Settings, 
  Bell, 
  Shield, 
  LogOut,
  Edit,
  ChevronRight,
  Star
} from 'lucide-react'
import { toast } from 'sonner'
import { Link } from 'react-router-dom'

export function ProfilePage() {
  const { user, signOut } = useAuth()
  const [isEditing, setIsEditing] = useState(false)
  const [notifications, setNotifications] = useState({
    push: true,
    email: false,
    marketing: true
  })

  const handleSave = () => {
    setIsEditing(false)
    toast.success('Profile updated successfully!')
  }

  const handleSignOut = async () => {
    try {
      await signOut()
      toast.success('Signed out successfully!')
    } catch {
      toast.error('Failed to sign out')
    }
  }

  const menuItems = [
    { icon: Trophy, label: 'My Beads', href: '/beads', badge: '12' },
    { icon: Ticket, label: 'My Passes', href: '/passes' },
    { icon: Star, label: 'Achievements', href: '/achievements' },
    { icon: Settings, label: 'Settings', href: '/settings' },
  ]

  return (
    <div className="space-y-6">
      {/* Profile Header */}
      <Card className="bg-gradient-to-br from-[#7d3e3a] to-[#a9332c] text-white border-0">
        <CardContent className="p-6">
          <div className="flex items-center gap-4">
            <Avatar className="h-20 w-20 border-4 border-white/20">
              <AvatarImage src={user?.avatar} />
              <AvatarFallback className="bg-white/20 text-white text-2xl">
                {user?.firstName?.[0]}{user?.lastName?.[0]}
              </AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <h1 className="text-2xl font-bold">{user?.displayName}</h1>
              <p className="text-white/80">{user?.email}</p>
              <Badge className="mt-2 bg-white/20 text-white border-0">
                Premium Member
              </Badge>
            </div>
            <Button 
              variant="ghost" 
              size="icon"
              onClick={() => setIsEditing(!isEditing)}
              className="text-white hover:bg-white/20"
            >
              <Edit className="h-5 w-5" />
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#7d3e3a]">47</p>
            <p className="text-xs text-[#6d6f82]">Check-ins</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#618e22]">12</p>
            <p className="text-xs text-[#6d6f82]">Beads</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#f3c700]">7</p>
            <p className="text-xs text-[#6d6f82]">Day Streak</p>
          </CardContent>
        </Card>
      </div>

      {/* Edit Profile Form */}
      {isEditing && (
        <Card className="bg-white border-[#e8e9f2]">
          <CardHeader>
            <CardTitle className="text-lg">Edit Profile</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>First Name</Label>
                <Input defaultValue={user?.firstName} className="bg-[#e8eaf3] border-0" />
              </div>
              <div className="space-y-2">
                <Label>Last Name</Label>
                <Input defaultValue={user?.lastName} className="bg-[#e8eaf3] border-0" />
              </div>
            </div>
            <div className="space-y-2">
              <Label>Email</Label>
              <Input defaultValue={user?.email} className="bg-[#e8eaf3] border-0" />
            </div>
            <div className="space-y-2">
              <Label>Phone</Label>
              <Input placeholder="+1 (555) 000-0000" className="bg-[#e8eaf3] border-0" />
            </div>
            <div className="flex gap-2">
              <Button onClick={handleSave} className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white">
                Save Changes
              </Button>
              <Button variant="outline" onClick={() => setIsEditing(false)}>
                Cancel
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Menu Items */}
      <Card className="bg-white border-[#e8e9f2]">
        <CardContent className="p-0">
          {menuItems.map((item, index) => (
            <Link key={item.label} to={item.href}>
              <div className={`flex items-center justify-between p-4 hover:bg-[#f4f4f9] transition-colors ${
                index !== menuItems.length - 1 ? 'border-b border-[#e8e9f2]' : ''
              }`}>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-[#f4f4f9] flex items-center justify-center">
                    <item.icon className="h-5 w-5 text-[#7d3e3a]" />
                  </div>
                  <span className="font-medium text-[#0e0c0b]">{item.label}</span>
                </div>
                <div className="flex items-center gap-2">
                  {item.badge && (
                    <Badge className="bg-[#7d3e3a] text-white">{item.badge}</Badge>
                  )}
                  <ChevronRight className="h-5 w-5 text-[#6d6f82]" />
                </div>
              </div>
            </Link>
          ))}
        </CardContent>
      </Card>

      {/* Notifications */}
      <Card className="bg-white border-[#e8e9f2]">
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Notifications
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-[#0e0c0b]">Push Notifications</p>
              <p className="text-sm text-[#6d6f82]">Receive alerts on your device</p>
            </div>
            <Switch 
              checked={notifications.push} 
              onCheckedChange={(v) => setNotifications(p => ({ ...p, push: v }))}
            />
          </div>
          <Separator />
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-[#0e0c0b]">Email Notifications</p>
              <p className="text-sm text-[#6d6f82]">Receive updates via email</p>
            </div>
            <Switch 
              checked={notifications.email} 
              onCheckedChange={(v) => setNotifications(p => ({ ...p, email: v }))}
            />
          </div>
          <Separator />
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-[#0e0c0b]">Marketing Emails</p>
              <p className="text-sm text-[#6d6f82]">Receive offers and promotions</p>
            </div>
            <Switch 
              checked={notifications.marketing} 
              onCheckedChange={(v) => setNotifications(p => ({ ...p, marketing: v }))}
            />
          </div>
        </CardContent>
      </Card>

      {/* Sign Out */}
      <Button 
        variant="outline" 
        onClick={handleSignOut}
        className="w-full h-12 border-red-200 text-red-600 hover:bg-red-50"
      >
        <LogOut className="mr-2 h-4 w-4" />
        Sign Out
      </Button>
    </div>
  )
}

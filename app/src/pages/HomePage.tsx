import { useEffect, useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { 
  MapPin, 
  QrCode, 
  Ticket, 
  Trophy, 
  Flame, 
  TrendingUp,
  Calendar,
  Clock,
  ChevronRight,
  Star
} from 'lucide-react'
import { Link } from 'react-router-dom'
import { toast } from 'sonner'

interface Gym {
  id: string
  name: string
  address: string
  rating: number
  distance: string
  image: string
  occupancy: number
}

interface Activity {
  id: string
  type: 'checkin' | 'purchase' | 'bead'
  title: string
  description: string
  timestamp: string
}

export function HomePage() {
  const { user } = useAuth()
  const [gyms, setGyms] = useState<Gym[]>([])
  const [activities, setActivities] = useState<Activity[]>([])
  const [streak, setStreak] = useState(7)
  const [weeklyGoal, setWeeklyGoal] = useState({ current: 4, target: 5 })
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Mock data loading
    setTimeout(() => {
      setGyms([
        {
          id: '1',
          name: 'Downtown Fitness',
          address: '123 Main St, Downtown',
          rating: 4.8,
          distance: '0.5 mi',
          image: '/gyms/downtown.jpg',
          occupancy: 65
        },
        {
          id: '2',
          name: 'Sunset Gym',
          address: '456 Beach Ave, Sunset',
          rating: 4.6,
          distance: '1.2 mi',
          image: '/gyms/sunset.jpg',
          occupancy: 42
        },
        {
          id: '3',
          name: 'Powerhouse Gym',
          address: '789 Power St, Midtown',
          rating: 4.9,
          distance: '2.1 mi',
          image: '/gyms/powerhouse.jpg',
          occupancy: 78
        }
      ])

      setActivities([
        { id: '1', type: 'checkin', title: 'Checked in at Downtown Fitness', description: 'Great workout session!', timestamp: '2 hours ago' },
        { id: '2', type: 'bead', title: 'Earned Week Warrior bead', description: '7-day streak achieved!', timestamp: '1 day ago' },
        { id: '3', type: 'purchase', title: 'Purchased Monthly Pass', description: 'Valid until Dec 31, 2024', timestamp: '3 days ago' }
      ])

      setIsLoading(false)
    }, 1000)
  }, [])

  const getOccupancyColor = (occupancy: number) => {
    if (occupancy < 50) return 'bg-green-500'
    if (occupancy < 75) return 'bg-yellow-500'
    return 'bg-red-500'
  }

  const getOccupancyText = (occupancy: number) => {
    if (occupancy < 50) return 'Not busy'
    if (occupancy < 75) return 'Moderate'
    return 'Busy'
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#7d3e3a]"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[#0e0c0b]">
            Welcome back, {user?.firstName || 'User'}! 👋
          </h1>
          <p className="text-[#6d6f82]">Ready for your next workout?</p>
        </div>
        <Link to="/profile">
          <div className="w-12 h-12 rounded-full bg-[#7d3e3a] flex items-center justify-center text-white font-semibold">
            {user?.firstName?.[0] || 'U'}
          </div>
        </Link>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card className="bg-gradient-to-br from-[#7d3e3a] to-[#a9332c] text-white border-0">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Flame className="h-5 w-5" />
              <span className="text-sm opacity-90">Streak</span>
            </div>
            <p className="text-3xl font-bold">{streak}</p>
            <p className="text-xs opacity-75">days</p>
          </CardContent>
        </Card>

        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Calendar className="h-5 w-5 text-[#618e22]" />
              <span className="text-sm text-[#6d6f82]">Weekly Goal</span>
            </div>
            <p className="text-3xl font-bold text-[#0e0c0b]">{weeklyGoal.current}/{weeklyGoal.target}</p>
            <p className="text-xs text-[#6d6f82]">workouts</p>
          </CardContent>
        </Card>

        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Trophy className="h-5 w-5 text-[#f3c700]" />
              <span className="text-sm text-[#6d6f82]">Beads</span>
            </div>
            <p className="text-3xl font-bold text-[#0e0c0b]">12</p>
            <p className="text-xs text-[#6d6f82]">collected</p>
          </CardContent>
        </Card>

        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4">
            <div className="flex items-center gap-2 mb-2">
              <Clock className="h-5 w-5 text-[#4a90d9]" />
              <span className="text-sm text-[#6d6f82]">This Week</span>
            </div>
            <p className="text-3xl font-bold text-[#0e0c0b]">4.5h</p>
            <p className="text-xs text-[#6d6f82]">total time</p>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <Link to="/map">
          <Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center gap-2 border-[#e8e9f2] hover:bg-[#f4f4f9]">
            <MapPin className="h-6 w-6 text-[#7d3e3a]" />
            <span className="text-sm">Find Gym</span>
          </Button>
        </Link>
        <Link to="/passes">
          <Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center gap-2 border-[#e8e9f2] hover:bg-[#f4f4f9]">
            <QrCode className="h-6 w-6 text-[#618e22]" />
            <span className="text-sm">My Pass</span>
          </Button>
        </Link>
        <Link to="/shop">
          <Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center gap-2 border-[#e8e9f2] hover:bg-[#f4f4f9]">
            <Ticket className="h-6 w-6 text-[#f3c700]" />
            <span className="text-sm">Buy Pass</span>
          </Button>
        </Link>
        <Link to="/beads">
          <Button variant="outline" className="w-full h-20 flex flex-col items-center justify-center gap-2 border-[#e8e9f2] hover:bg-[#f4f4f9]">
            <Trophy className="h-6 w-6 text-[#f97c16]" />
            <span className="text-sm">My Beads</span>
          </Button>
        </Link>
      </div>

      {/* Weekly Progress */}
      <Card className="bg-white border-[#e8e9f2]">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg flex items-center gap-2">
            <TrendingUp className="h-5 w-5 text-[#7d3e3a]" />
            Weekly Progress
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-[#6d6f82]">{weeklyGoal.current} of {weeklyGoal.target} workouts</span>
              <span className="text-[#7d3e3a] font-medium">{Math.round((weeklyGoal.current / weeklyGoal.target) * 100)}%</span>
            </div>
            <Progress 
              value={(weeklyGoal.current / weeklyGoal.target) * 100} 
              className="h-3 bg-[#e8eaf3]"
            />
          </div>
          <div className="flex justify-between mt-4">
            {['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day, i) => (
              <div key={i} className="flex flex-col items-center gap-1">
                <div 
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${
                    i < weeklyGoal.current 
                      ? 'bg-[#7d3e3a] text-white' 
                      : 'bg-[#e8eaf3] text-[#6d6f82]'
                  }`}
                >
                  ✓
                </div>
                <span className="text-xs text-[#6d6f82]">{day}</span>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Nearby Gyms */}
      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-[#0e0c0b]">Nearby Gyms</h2>
          <Link to="/map" className="text-sm text-[#7d3e3a] hover:underline flex items-center gap-1">
            View all
            <ChevronRight className="h-4 w-4" />
          </Link>
        </div>
        
        <div className="space-y-3">
          {gyms.map((gym) => (
            <Link key={gym.id} to={`/map?gym=${gym.id}`}>
              <Card className="bg-white border-[#e8e9f2] hover:shadow-md transition-shadow">
                <CardContent className="p-4">
                  <div className="flex items-start gap-4">
                    <div className="w-20 h-20 rounded-lg bg-[#e8eaf3] flex items-center justify-center flex-shrink-0">
                      <MapPin className="h-8 w-8 text-[#7d3e3a]" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between">
                        <div>
                          <h3 className="font-semibold text-[#0e0c0b] truncate">{gym.name}</h3>
                          <p className="text-sm text-[#6d6f82] truncate">{gym.address}</p>
                        </div>
                        <Badge variant="secondary" className="flex items-center gap-1 bg-[#f4f4f9]">
                          <Star className="h-3 w-3 fill-[#f3c700] text-[#f3c700]" />
                          {gym.rating}
                        </Badge>
                      </div>
                      <div className="flex items-center gap-4 mt-2">
                        <span className="text-sm text-[#6d6f82]">{gym.distance}</span>
                        <div className="flex items-center gap-2">
                          <div className={`w-2 h-2 rounded-full ${getOccupancyColor(gym.occupancy)}`} />
                          <span className="text-sm text-[#6d6f82]">{getOccupancyText(gym.occupancy)}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </div>

      {/* Recent Activity */}
      <div>
        <h2 className="text-lg font-semibold text-[#0e0c0b] mb-4">Recent Activity</h2>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-0">
            {activities.map((activity, index) => (
              <div 
                key={activity.id} 
                className={`p-4 flex items-start gap-3 ${index !== activities.length - 1 ? 'border-b border-[#e8e9f2]' : ''}`}
              >
                <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                  activity.type === 'checkin' ? 'bg-green-100' :
                  activity.type === 'bead' ? 'bg-yellow-100' : 'bg-blue-100'
                }`}>
                  {activity.type === 'checkin' && <MapPin className="h-5 w-5 text-green-600" />}
                  {activity.type === 'bead' && <Trophy className="h-5 w-5 text-yellow-600" />}
                  {activity.type === 'purchase' && <Ticket className="h-5 w-5 text-blue-600" />}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="font-medium text-[#0e0c0b]">{activity.title}</p>
                  <p className="text-sm text-[#6d6f82]">{activity.description}</p>
                  <p className="text-xs text-[#6d6f82] mt-1">{activity.timestamp}</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

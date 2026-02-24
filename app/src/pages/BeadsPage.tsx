import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { 
  Trophy, 
  Filter, 
  ArrowUpDown, 
  Share2, 
  Flame,
  Sun,
  Moon,
  MapPin,
  Users,
  Ticket,
  Crown,
  Sparkles,
  Check
} from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { toast } from 'sonner'

interface Bead {
  id: string
  type: string
  name: string
  description: string
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary'
  color: string
  earnedAt: string
  icon: React.ElementType
}

const beads: Bead[] = [
  { id: '1', type: 'firstCheckIn', name: 'First Steps', description: 'Complete your first gym check-in', rarity: 'common', color: '#7d3e3a', earnedAt: '2024-01-15', icon: Check },
  { id: '2', type: 'streak3', name: '3-Day Streak', description: 'Check in 3 days in a row', rarity: 'common', color: '#618e22', earnedAt: '2024-01-20', icon: Flame },
  { id: '3', type: 'streak7', name: 'Week Warrior', description: 'Maintain a 7-day streak', rarity: 'uncommon', color: '#f3c700', earnedAt: '2024-01-25', icon: Flame },
  { id: '4', type: 'earlyBird', name: 'Early Bird', description: 'Check in before 7 AM', rarity: 'uncommon', color: '#4a90d9', earnedAt: '2024-02-01', icon: Sun },
  { id: '5', type: 'nightOwl', name: 'Night Owl', description: 'Check in after 9 PM', rarity: 'uncommon', color: '#6b5b95', earnedAt: '2024-02-05', icon: Moon },
  { id: '6', type: 'gymExplorer', name: 'Gym Explorer', description: 'Visit 5 different gyms', rarity: 'rare', color: '#d65076', earnedAt: '2024-02-10', icon: MapPin },
]

const rarityOrder = { common: 0, uncommon: 1, rare: 2, epic: 3, legendary: 4 }

export function BeadsPage() {
  const [filter, setFilter] = useState<string | null>(null)
  const [sortBy, setSortBy] = useState<'newest' | 'rarity' | 'type'>('newest')

  const filteredBeads = beads
    .filter(b => !filter || b.rarity === filter)
    .sort((a, b) => {
      if (sortBy === 'newest') return new Date(b.earnedAt).getTime() - new Date(a.earnedAt).getTime()
      if (sortBy === 'rarity') return rarityOrder[b.rarity] - rarityOrder[a.rarity]
      return a.name.localeCompare(b.name)
    })

  const totalBeads = 14
  const collectedBeads = beads.length
  const completionPercentage = (collectedBeads / totalBeads) * 100

  const getRarityColor = (rarity: string) => {
    switch (rarity) {
      case 'common': return 'bg-[#6d6f82]'
      case 'uncommon': return 'bg-[#618e22]'
      case 'rare': return 'bg-[#4a90d9]'
      case 'epic': return 'bg-[#9b59b6]'
      case 'legendary': return 'bg-[#f39c12]'
      default: return 'bg-[#6d6f82]'
    }
  }

  const handleShare = (bead: Bead) => {
    const text = `I earned the ${bead.name} bead in Capybara Gym! 🏋️‍♂️✨`
    navigator.clipboard.writeText(text)
    toast.success('Copied to clipboard!')
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-[#0e0c0b]">My Beads</h1>
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="gap-2">
                <Filter className="h-4 w-4" />
                Filter
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onClick={() => setFilter(null)}>All</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setFilter('common')}>Common</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setFilter('uncommon')}>Uncommon</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setFilter('rare')}>Rare</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setFilter('epic')}>Epic</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setFilter('legendary')}>Legendary</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="gap-2">
                <ArrowUpDown className="h-4 w-4" />
                Sort
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onClick={() => setSortBy('newest')}>Newest First</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setSortBy('rarity')}>By Rarity</DropdownMenuItem>
              <DropdownMenuItem onClick={() => setSortBy('type')}>By Type</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#7d3e3a]">{collectedBeads}</p>
            <p className="text-xs text-[#6d6f82]">Total Beads</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#618e22]">{new Set(beads.map(b => b.type)).size}</p>
            <p className="text-xs text-[#6d6f82]">Unique Types</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <p className="text-2xl font-bold text-[#f3c700]">{Math.round(completionPercentage)}%</p>
            <p className="text-xs text-[#6d6f82]">Complete</p>
          </CardContent>
        </Card>
      </div>

      {/* Progress */}
      <Card className="bg-white border-[#e8e9f2]">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg">Collection Progress</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-[#6d6f82]">{collectedBeads} of {totalBeads} beads</span>
              <span className="text-[#7d3e3a] font-medium">{Math.round(completionPercentage)}%</span>
            </div>
            <Progress value={completionPercentage} className="h-3 bg-[#e8eaf3]" />
          </div>
        </CardContent>
      </Card>

      {/* Beads Grid */}
      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {filteredBeads.map((bead) => {
          const Icon = bead.icon
          return (
            <Card key={bead.id} className="bg-white border-[#e8e9f2] group hover:shadow-lg transition-all">
              <CardContent className="p-4">
                <div className="flex flex-col items-center text-center">
                  {/* Bead Visual */}
                  <div 
                    className="w-20 h-20 rounded-full flex items-center justify-center mb-3 shadow-lg"
                    style={{ 
                      background: `linear-gradient(135deg, ${bead.color}, ${bead.color}dd)`,
                      boxShadow: `0 8px 24px ${bead.color}40`
                    }}
                  >
                    <Icon className="h-10 w-10 text-white" />
                  </div>

                  {/* Rarity Badge */}
                  <Badge className={`${getRarityColor(bead.rarity)} text-white text-xs mb-2`}>
                    {bead.rarity}
                  </Badge>

                  {/* Name */}
                  <h3 className="font-semibold text-[#0e0c0b] text-sm mb-1">{bead.name}</h3>

                  {/* Description */}
                  <p className="text-xs text-[#6d6f82] mb-2 line-clamp-2">{bead.description}</p>

                  {/* Date */}
                  <p className="text-xs text-[#6d6f82] mb-3">{bead.earnedAt}</p>

                  {/* Share Button */}
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    onClick={() => handleShare(bead)}
                    className="opacity-0 group-hover:opacity-100 transition-opacity"
                  >
                    <Share2 className="h-4 w-4 mr-1" />
                    Share
                  </Button>
                </div>
              </CardContent>
            </Card>
          )
        })}
      </div>

      {/* Locked Beads Preview */}
      <div>
        <h2 className="text-lg font-semibold text-[#0e0c0b] mb-4">Locked Beads</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 opacity-50">
          {[
            { name: 'Monthly Master', rarity: 'rare', icon: Flame },
            { name: 'Century Club', rarity: 'legendary', icon: Crown },
            { name: 'Weekend Warrior', rarity: 'uncommon', icon: Sparkles },
          ].map((bead, i) => {
            const Icon = bead.icon
            return (
              <Card key={i} className="bg-[#f4f4f9] border-[#e8e9f2]">
                <CardContent className="p-4">
                  <div className="flex flex-col items-center text-center">
                    <div className="w-20 h-20 rounded-full bg-[#e8eaf3] flex items-center justify-center mb-3">
                      <Icon className="h-10 w-10 text-[#6d6f82]" />
                    </div>
                    <Badge className={`${getRarityColor(bead.rarity)} text-white text-xs mb-2 opacity-50`}>
                      {bead.rarity}
                    </Badge>
                    <h3 className="font-semibold text-[#6d6f82] text-sm">{bead.name}</h3>
                    <p className="text-xs text-[#6d6f82] mt-1">Locked</p>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>
      </div>
    </div>
  )
}

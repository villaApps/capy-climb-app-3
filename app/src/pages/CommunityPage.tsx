import { useState } from 'react'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { 
  Heart, 
  MessageCircle, 
  Share2, 
  Trophy,
  Flame,
  TrendingUp,
  Users,
  Search,
  Plus
} from 'lucide-react'
import { toast } from 'sonner'

interface Post {
  id: string
  author: {
    name: string
    avatar?: string
    badge?: string
  }
  content: string
  image?: string
  likes: number
  comments: number
  timestamp: string
  liked: boolean
}

const posts: Post[] = [
  {
    id: '1',
    author: { name: 'Sarah Johnson', badge: 'Week Warrior' },
    content: 'Just hit my 7-day streak! The early morning workouts are really paying off. 💪🔥',
    likes: 24,
    comments: 5,
    timestamp: '2 hours ago',
    liked: false
  },
  {
    id: '2',
    author: { name: 'Mike Chen', badge: 'Gym Explorer' },
    content: 'Tried the new Downtown Fitness location today. Amazing facilities and super friendly staff! Highly recommend the pool area. 🏊‍♂️',
    likes: 18,
    comments: 3,
    timestamp: '4 hours ago',
    liked: true
  },
  {
    id: '3',
    author: { name: 'Emma Wilson', badge: 'Fitness Master' },
    content: 'Completed my 50th workout today! Thanks Capybara Gym for keeping me motivated. Time to celebrate! 🎉',
    likes: 45,
    comments: 12,
    timestamp: '6 hours ago',
    liked: false
  }
]

const leaderboard = [
  { rank: 1, name: 'Alex Thompson', checkins: 47, avatar: '' },
  { rank: 2, name: 'Maria Garcia', checkins: 42, avatar: '' },
  { rank: 3, name: 'James Lee', checkins: 38, avatar: '' },
]

export function CommunityPage() {
  const [postList, setPostList] = useState(posts)
  const [newPost, setNewPost] = useState('')

  const handleLike = (postId: string) => {
    setPostList(prev => prev.map(post => {
      if (post.id === postId) {
        return {
          ...post,
          liked: !post.liked,
          likes: post.liked ? post.likes - 1 : post.likes + 1
        }
      }
      return post
    }))
  }

  const handleShare = (post: Post) => {
    navigator.clipboard.writeText(`${post.author.name}: ${post.content}`)
    toast.success('Copied to clipboard!')
  }

  const handlePost = () => {
    if (!newPost.trim()) return
    
    const post: Post = {
      id: Date.now().toString(),
      author: { name: 'You' },
      content: newPost,
      likes: 0,
      comments: 0,
      timestamp: 'Just now',
      liked: false
    }
    
    setPostList([post, ...postList])
    setNewPost('')
    toast.success('Post created!')
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-[#0e0c0b]">Community</h1>
        <Button className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white">
          <Plus className="h-4 w-4 mr-2" />
          New Post
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4">
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <Users className="h-6 w-6 text-[#7d3e3a] mx-auto mb-2" />
            <p className="text-2xl font-bold text-[#0e0c0b]">2.4k</p>
            <p className="text-xs text-[#6d6f82]">Members</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <Flame className="h-6 w-6 text-[#f97c16] mx-auto mb-2" />
            <p className="text-2xl font-bold text-[#0e0c0b]">847</p>
            <p className="text-xs text-[#6d6f82]">Active Today</p>
          </CardContent>
        </Card>
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4 text-center">
            <TrendingUp className="h-6 w-6 text-[#618e22] mx-auto mb-2" />
            <p className="text-2xl font-bold text-[#0e0c0b]">12.5k</p>
            <p className="text-xs text-[#6d6f82]">Total Check-ins</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid lg:grid-cols-3 gap-6">
        {/* Feed */}
        <div className="lg:col-span-2 space-y-4">
          {/* Create Post */}
          <Card className="bg-white border-[#e8e9f2]">
            <CardContent className="p-4">
              <div className="flex gap-3">
                <Avatar className="h-10 w-10">
                  <AvatarFallback className="bg-[#7d3e3a] text-white">Y</AvatarFallback>
                </Avatar>
                <div className="flex-1">
                  <Input
                    placeholder="Share your fitness journey..."
                    value={newPost}
                    onChange={(e) => setNewPost(e.target.value)}
                    className="bg-[#e8eaf3] border-0 mb-2"
                  />
                  <div className="flex justify-end">
                    <Button 
                      onClick={handlePost}
                      disabled={!newPost.trim()}
                      className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white"
                    >
                      Post
                    </Button>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Posts */}
          {postList.map(post => (
            <Card key={post.id} className="bg-white border-[#e8e9f2]">
              <CardContent className="p-4">
                {/* Header */}
                <div className="flex items-center gap-3 mb-3">
                  <Avatar className="h-10 w-10">
                    <AvatarImage src={post.author.avatar} />
                    <AvatarFallback className="bg-[#f4f4f9] text-[#7d3e3a]">
                      {post.author.name[0]}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-[#0e0c0b]">{post.author.name}</span>
                      {post.author.badge && (
                        <Badge variant="secondary" className="text-xs bg-[#f3c700]/20 text-[#f3c700]">
                          <Trophy className="h-3 w-3 mr-1" />
                          {post.author.badge}
                        </Badge>
                      )}
                    </div>
                    <span className="text-xs text-[#6d6f82]">{post.timestamp}</span>
                  </div>
                </div>

                {/* Content */}
                <p className="text-[#0e0c0b] mb-4">{post.content}</p>

                {/* Actions */}
                <div className="flex items-center gap-4">
                  <Button 
                    variant="ghost" 
                    size="sm"
                    onClick={() => handleLike(post.id)}
                    className={post.liked ? 'text-red-500' : 'text-[#6d6f82]'}
                  >
                    <Heart className={`h-4 w-4 mr-1 ${post.liked ? 'fill-current' : ''}`} />
                    {post.likes}
                  </Button>
                  <Button variant="ghost" size="sm" className="text-[#6d6f82]">
                    <MessageCircle className="h-4 w-4 mr-1" />
                    {post.comments}
                  </Button>
                  <Button 
                    variant="ghost" 
                    size="sm" 
                    onClick={() => handleShare(post)}
                    className="text-[#6d6f82]"
                  >
                    <Share2 className="h-4 w-4 mr-1" />
                    Share
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Sidebar */}
        <div className="space-y-4">
          {/* Leaderboard */}
          <Card className="bg-white border-[#e8e9f2]">
            <CardHeader className="pb-2">
              <div className="flex items-center gap-2">
                <Trophy className="h-5 w-5 text-[#f3c700]" />
                <span className="font-semibold text-[#0e0c0b]">This Week's Leaders</span>
              </div>
            </CardHeader>
            <CardContent className="p-0">
              {leaderboard.map((user, index) => (
                <div 
                  key={user.name} 
                  className={`flex items-center gap-3 p-3 ${
                    index !== leaderboard.length - 1 ? 'border-b border-[#e8e9f2]' : ''
                  }`}
                >
                  <div className={`w-6 h-6 rounded-full flex items-center justify-center text-sm font-bold ${
                    index === 0 ? 'bg-[#f3c700] text-white' :
                    index === 1 ? 'bg-[#c0c0c0] text-white' :
                    index === 2 ? 'bg-[#cd7f32] text-white' :
                    'bg-[#e8eaf3] text-[#6d6f82]'
                  }`}>
                    {user.rank}
                  </div>
                  <Avatar className="h-8 w-8">
                    <AvatarFallback className="bg-[#f4f4f9] text-[#7d3e3a] text-sm">
                      {user.name[0]}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-[#0e0c0b]">{user.name}</p>
                  </div>
                  <Badge variant="secondary" className="text-xs">
                    {user.checkins} check-ins
                  </Badge>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Trending */}
          <Card className="bg-white border-[#e8e9f2]">
            <CardHeader className="pb-2">
              <div className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-[#618e22]" />
                <span className="font-semibold text-[#0e0c0b]">Trending</span>
              </div>
            </CardHeader>
            <CardContent className="p-4">
              <div className="space-y-2">
                <p className="text-sm text-[#7d3e3a] hover:underline cursor-pointer">#MorningWorkout</p>
                <p className="text-sm text-[#7d3e3a] hover:underline cursor-pointer">#FitnessGoals</p>
                <p className="text-sm text-[#7d3e3a] hover:underline cursor-pointer">#CapybaraGym</p>
                <p className="text-sm text-[#7d3e3a] hover:underline cursor-pointer">#StreakLife</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  )
}

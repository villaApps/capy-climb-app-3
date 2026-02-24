import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { 
  Ticket, 
  Check, 
  Star,
  Zap,
  Calendar,
  Clock,
  ArrowRight
} from 'lucide-react'
import { toast } from 'sonner'

interface PassType {
  id: string
  name: string
  description: string
  price: number
  originalPrice?: number
  duration: string
  features: string[]
  popular?: boolean
  badge?: string
}

const passTypes: PassType[] = [
  {
    id: 'day',
    name: 'Day Pass',
    description: 'Full access for one day',
    price: 15,
    duration: '1 day',
    features: ['All gym access', 'Locker room', 'Showers']
  },
  {
    id: 'week',
    name: 'Week Pass',
    description: '7 consecutive days',
    price: 45,
    originalPrice: 60,
    duration: '7 days',
    features: ['All gym access', 'Locker room', 'Showers', 'Group classes'],
    badge: 'Save 25%'
  },
  {
    id: 'month',
    name: 'Monthly Pass',
    description: 'Unlimited monthly access',
    price: 99,
    originalPrice: 120,
    duration: '30 days',
    features: ['All gym access', 'Locker room', 'Showers', 'Group classes', 'Guest passes'],
    popular: true,
    badge: 'Best Value'
  },
  {
    id: 'quarter',
    name: 'Quarterly Pass',
    description: '3 months commitment',
    price: 249,
    originalPrice: 300,
    duration: '90 days',
    features: ['All gym access', 'Locker room', 'Showers', 'Group classes', 'Guest passes', 'Personal training session'],
    badge: 'Save 17%'
  },
  {
    id: 'year',
    name: 'Annual Pass',
    description: 'Full year membership',
    price: 799,
    originalPrice: 1200,
    duration: '365 days',
    features: ['All gym access', 'Locker room', 'Showers', 'Group classes', 'Unlimited guest passes', 'Monthly PT session', 'Spa access'],
    badge: 'Save 33%'
  }
]

export function ShopPage() {
  const [selectedPass, setSelectedPass] = useState<PassType | null>(null)

  const handlePurchase = (pass: PassType) => {
    setSelectedPass(pass)
    toast.success(`${pass.name} added to cart!`)
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-[#0e0c0b]">Pass Shop</h1>
        <p className="text-[#6d6f82]">Choose the perfect pass for your fitness journey</p>
      </div>

      {/* Promotional Banner */}
      <Card className="bg-gradient-to-r from-[#7d3e3a] to-[#a9332c] text-white border-0">
        <CardContent className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <Badge className="bg-white/20 text-white border-0 mb-2">
                <Zap className="h-3 w-3 mr-1" />
                Limited Time Offer
              </Badge>
              <h2 className="text-2xl font-bold mb-1">Get 20% Off Your First Pass!</h2>
              <p className="text-white/80">Use code: CAPY20 at checkout</p>
            </div>
            <Ticket className="h-16 w-16 text-white/30" />
          </div>
        </CardContent>
      </Card>

      {/* Pass Types */}
      <Tabs defaultValue="all" className="w-full">
        <TabsList className="grid w-full grid-cols-4 bg-[#e8eaf3]">
          <TabsTrigger value="all" className="data-[state=active]:bg-white">All Passes</TabsTrigger>
          <TabsTrigger value="short" className="data-[state=active]:bg-white">Short Term</TabsTrigger>
          <TabsTrigger value="long" className="data-[state=active]:bg-white">Long Term</TabsTrigger>
          <TabsTrigger value="membership" className="data-[state=active]:bg-white">Memberships</TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {passTypes.map(pass => (
              <PassCard key={pass.id} pass={pass} onPurchase={handlePurchase} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="short" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {passTypes.filter(p => ['day', 'week'].includes(p.id)).map(pass => (
              <PassCard key={pass.id} pass={pass} onPurchase={handlePurchase} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="long" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {passTypes.filter(p => ['month', 'quarter'].includes(p.id)).map(pass => (
              <PassCard key={pass.id} pass={pass} onPurchase={handlePurchase} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="membership" className="mt-6">
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {passTypes.filter(p => ['quarter', 'year'].includes(p.id)).map(pass => (
              <PassCard key={pass.id} pass={pass} onPurchase={handlePurchase} />
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}

function PassCard({ pass, onPurchase }: { pass: PassType; onPurchase: (pass: PassType) => void }) {
  return (
    <Card className={`bg-white border-[#e8e9f2] relative overflow-hidden ${
      pass.popular ? 'ring-2 ring-[#7d3e3a]' : ''
    }`}>
      {pass.popular && (
        <div className="absolute top-0 right-0 bg-[#7d3e3a] text-white text-xs px-3 py-1 rounded-bl-lg">
          Most Popular
        </div>
      )}
      {pass.badge && !pass.popular && (
        <div className="absolute top-0 right-0 bg-[#618e22] text-white text-xs px-3 py-1 rounded-bl-lg">
          {pass.badge}
        </div>
      )}
      
      <CardHeader className="pb-2">
        <CardTitle className="text-lg flex items-center gap-2">
          <Ticket className="h-5 w-5 text-[#7d3e3a]" />
          {pass.name}
        </CardTitle>
        <p className="text-sm text-[#6d6f82]">{pass.description}</p>
      </CardHeader>
      
      <CardContent className="space-y-4">
        <div className="flex items-baseline gap-2">
          <span className="text-3xl font-bold text-[#0e0c0b]">${pass.price}</span>
          {pass.originalPrice && (
            <span className="text-lg text-[#6d6f82] line-through">${pass.originalPrice}</span>
          )}
        </div>
        
        <div className="flex items-center gap-2 text-sm text-[#6d6f82]">
          <Calendar className="h-4 w-4" />
          {pass.duration}
        </div>
        
        <ul className="space-y-2">
          {pass.features.map((feature, i) => (
            <li key={i} className="flex items-center gap-2 text-sm">
              <Check className="h-4 w-4 text-[#618e22]" />
              {feature}
            </li>
          ))}
        </ul>
        
        <Button 
          onClick={() => onPurchase(pass)}
          className={`w-full ${
            pass.popular 
              ? 'bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white' 
              : 'bg-[#f4f4f9] hover:bg-[#e8e9f2] text-[#0e0c0b]'
          }`}
        >
          Purchase
          <ArrowRight className="ml-2 h-4 w-4" />
        </Button>
      </CardContent>
    </Card>
  )
}

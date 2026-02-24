import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Badge } from '@/components/ui/badge'
import { QrCode, Clock, CheckCircle, Calendar, MapPin, ArrowRight } from 'lucide-react'
import { Link } from 'react-router-dom'

interface Pass {
  id: string
  type: string
  gymName: string
  status: 'active' | 'expired' | 'used'
  purchaseDate: string
  expiryDate: string
  qrCode: string
  visitsUsed?: number
  visitsTotal?: number
}

export function PassManagementPage() {
  const [activeTab, setActiveTab] = useState('active')
  
  const activePasses: Pass[] = [
    {
      id: '1',
      type: 'Monthly Pass',
      gymName: 'Downtown Fitness',
      status: 'active',
      purchaseDate: '2024-01-01',
      expiryDate: '2024-02-01',
      qrCode: 'qr-1',
      visitsUsed: 12,
      visitsTotal: 30
    }
  ]

  const expiredPasses: Pass[] = [
    {
      id: '2',
      type: 'Day Pass',
      gymName: 'Sunset Gym',
      status: 'expired',
      purchaseDate: '2023-12-15',
      expiryDate: '2023-12-15',
      qrCode: 'qr-2'
    }
  ]

  const PassCard = ({ pass }: { pass: Pass }) => (
    <Card className="bg-white border-[#e8e9f2] overflow-hidden">
      <div className={`h-2 ${
        pass.status === 'active' ? 'bg-[#618e22]' :
        pass.status === 'expired' ? 'bg-[#6d6f82]' : 'bg-[#7d3e3a]'
      }`} />
      <CardContent className="p-4">
        <div className="flex items-start justify-between mb-4">
          <div>
            <h3 className="font-semibold text-[#0e0c0b]">{pass.type}</h3>
            <div className="flex items-center gap-1 text-sm text-[#6d6f82]">
              <MapPin className="h-3 w-3" />
              {pass.gymName}
            </div>
          </div>
          <Badge 
            variant={pass.status === 'active' ? 'default' : 'secondary'}
            className={pass.status === 'active' ? 'bg-[#618e22]' : ''}
          >
            {pass.status === 'active' && <CheckCircle className="h-3 w-3 mr-1" />}
            {pass.status.charAt(0).toUpperCase() + pass.status.slice(1)}
          </Badge>
        </div>

        {pass.status === 'active' && (
          <div className="flex justify-center py-4">
            <div className="w-32 h-32 bg-[#f4f4f9] rounded-lg flex items-center justify-center">
              <QrCode className="h-20 w-20 text-[#0e0c0b]" />
            </div>
          </div>
        )}

        <div className="space-y-2 text-sm">
          <div className="flex items-center gap-2 text-[#6d6f82]">
            <Calendar className="h-4 w-4" />
            <span>Purchased: {pass.purchaseDate}</span>
          </div>
          <div className="flex items-center gap-2 text-[#6d6f82]">
            <Clock className="h-4 w-4" />
            <span>Expires: {pass.expiryDate}</span>
          </div>
          {pass.visitsUsed !== undefined && (
            <div className="mt-3">
              <div className="flex justify-between text-sm mb-1">
                <span className="text-[#6d6f82]">Visits</span>
                <span className="text-[#0e0c0b]">{pass.visitsUsed}/{pass.visitsTotal}</span>
              </div>
              <div className="h-2 bg-[#e8eaf3] rounded-full overflow-hidden">
                <div 
                  className="h-full bg-[#7d3e3a] rounded-full transition-all"
                  style={{ width: `${(pass.visitsUsed / (pass.visitsTotal || 1)) * 100}%` }}
                />
              </div>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-[#0e0c0b]">My Passes</h1>
        <Link to="/shop">
          <Button className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white rounded-full">
            Buy Pass
            <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        </Link>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3 bg-[#e8eaf3]">
          <TabsTrigger value="active" className="data-[state=active]:bg-white">Active</TabsTrigger>
          <TabsTrigger value="expired" className="data-[state=active]:bg-white">Expired</TabsTrigger>
          <TabsTrigger value="history" className="data-[state=active]:bg-white">History</TabsTrigger>
        </TabsList>

        <TabsContent value="active" className="mt-6">
          {activePasses.length > 0 ? (
            <div className="space-y-4">
              {activePasses.map(pass => (
                <PassCard key={pass.id} pass={pass} />
              ))}
            </div>
          ) : (
            <Card className="bg-white border-[#e8e9f2]">
              <CardContent className="p-8 text-center">
                <div className="w-16 h-16 rounded-full bg-[#f4f4f9] flex items-center justify-center mx-auto mb-4">
                  <QrCode className="h-8 w-8 text-[#6d6f82]" />
                </div>
                <h3 className="text-lg font-semibold text-[#0e0c0b] mb-2">No active passes</h3>
                <p className="text-[#6d6f82] mb-4">Purchase a pass to start your fitness journey</p>
                <Link to="/shop">
                  <Button className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white rounded-full">
                    Browse Passes
                  </Button>
                </Link>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="expired" className="mt-6">
          {expiredPasses.length > 0 ? (
            <div className="space-y-4">
              {expiredPasses.map(pass => (
                <PassCard key={pass.id} pass={pass} />
              ))}
            </div>
          ) : (
            <Card className="bg-white border-[#e8e9f2]">
              <CardContent className="p-8 text-center">
                <p className="text-[#6d6f82]">No expired passes</p>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="history" className="mt-6">
          <Card className="bg-white border-[#e8e9f2]">
            <CardContent className="p-8 text-center">
              <p className="text-[#6d6f82]">Pass usage history will appear here</p>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}

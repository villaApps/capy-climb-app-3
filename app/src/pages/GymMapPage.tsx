import { useState } from 'react'
import { Card, CardContent } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { 
  Search, 
  MapPin, 
  Filter, 
  Star, 
  Clock,
  Navigation,
  Phone
} from 'lucide-react'
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from '@/components/ui/sheet'
import { toast } from 'sonner'

interface Gym {
  id: string
  name: string
  address: string
  rating: number
  reviewCount: number
  distance: string
  hours: string
  phone: string
  amenities: string[]
  occupancy: number
  lat: number
  lng: number
}

const gyms: Gym[] = [
  {
    id: '1',
    name: 'Downtown Fitness',
    address: '123 Main St, Downtown',
    rating: 4.8,
    reviewCount: 234,
    distance: '0.5 mi',
    hours: 'Open 24 hours',
    phone: '(555) 123-4567',
    amenities: ['Pool', 'Sauna', 'Classes'],
    occupancy: 65,
    lat: 40.7128,
    lng: -74.0060
  },
  {
    id: '2',
    name: 'Sunset Gym',
    address: '456 Beach Ave, Sunset',
    rating: 4.6,
    reviewCount: 189,
    distance: '1.2 mi',
    hours: '5 AM - 11 PM',
    phone: '(555) 234-5678',
    amenities: ['Yoga', 'CrossFit', 'Parking'],
    occupancy: 42,
    lat: 40.7200,
    lng: -74.0100
  },
  {
    id: '3',
    name: 'Powerhouse Gym',
    address: '789 Power St, Midtown',
    rating: 4.9,
    reviewCount: 312,
    distance: '2.1 mi',
    hours: 'Open 24 hours',
    phone: '(555) 345-6789',
    amenities: ['Pool', 'Basketball', 'Spa'],
    occupancy: 78,
    lat: 40.7300,
    lng: -73.9950
  }
]

const amenitiesList = ['Pool', 'Sauna', 'Classes', 'Yoga', 'CrossFit', 'Parking', 'Spa', 'Basketball']

export function GymMapPage() {
  const [searchQuery, setSearchQuery] = useState('')
  const [selectedAmenities, setSelectedAmenities] = useState<string[]>([])
  const [selectedGym, setSelectedGym] = useState<Gym | null>(null)

  const filteredGyms = gyms.filter(gym => {
    const matchesSearch = gym.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         gym.address.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesAmenities = selectedAmenities.length === 0 || 
                            selectedAmenities.every(a => gym.amenities.includes(a))
    return matchesSearch && matchesAmenities
  })

  const toggleAmenity = (amenity: string) => {
    setSelectedAmenities(prev => 
      prev.includes(amenity) 
        ? prev.filter(a => a !== amenity)
        : [...prev, amenity]
    )
  }

  const getOccupancyColor = (occupancy: number) => {
    if (occupancy < 50) return 'bg-green-500'
    if (occupancy < 75) return 'bg-yellow-500'
    return 'bg-red-500'
  }

  return (
    <div className="h-[calc(100vh-140px)] flex flex-col md:flex-row gap-4">
      {/* Sidebar */}
      <div className="w-full md:w-96 flex flex-col gap-4">
        {/* Search */}
        <Card className="bg-white border-[#e8e9f2]">
          <CardContent className="p-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#6d6f82]" />
              <Input
                placeholder="Search gyms..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10 bg-[#e8eaf3] border-0"
              />
            </div>
            
            {/* Filters */}
            <Sheet>
              <SheetTrigger asChild>
                <Button variant="outline" className="w-full mt-3 gap-2">
                  <Filter className="h-4 w-4" />
                  Filters
                  {selectedAmenities.length > 0 && (
                    <Badge className="ml-2 bg-[#7d3e3a]">{selectedAmenities.length}</Badge>
                  )}
                </Button>
              </SheetTrigger>
              <SheetContent side="left">
                <SheetHeader>
                  <SheetTitle>Filter Gyms</SheetTitle>
                </SheetHeader>
                <div className="mt-4">
                  <p className="text-sm font-medium text-[#0e0c0b] mb-3">Amenities</p>
                  <div className="flex flex-wrap gap-2">
                    {amenitiesList.map(amenity => (
                      <Button
                        key={amenity}
                        variant={selectedAmenities.includes(amenity) ? 'default' : 'outline'}
                        size="sm"
                        onClick={() => toggleAmenity(amenity)}
                        className={selectedAmenities.includes(amenity) ? 'bg-[#7d3e3a]' : ''}
                      >
                        {amenity}
                      </Button>
                    ))}
                  </div>
                </div>
              </SheetContent>
            </Sheet>
          </CardContent>
        </Card>

        {/* Gym List */}
        <div className="flex-1 overflow-auto space-y-3">
          {filteredGyms.map(gym => (
            <Card 
              key={gym.id} 
              className={`bg-white border-[#e8e9f2] cursor-pointer hover:shadow-md transition-shadow ${
                selectedGym?.id === gym.id ? 'ring-2 ring-[#7d3e3a]' : ''
              }`}
              onClick={() => setSelectedGym(gym)}
            >
              <CardContent className="p-4">
                <div className="flex items-start justify-between mb-2">
                  <h3 className="font-semibold text-[#0e0c0b]">{gym.name}</h3>
                  <Badge variant="secondary" className="flex items-center gap-1">
                    <Star className="h-3 w-3 fill-[#f3c700] text-[#f3c700]" />
                    {gym.rating}
                  </Badge>
                </div>
                
                <div className="flex items-center gap-1 text-sm text-[#6d6f82] mb-2">
                  <MapPin className="h-3 w-3" />
                  {gym.address}
                </div>
                
                <div className="flex items-center gap-4 text-sm">
                  <span className="text-[#6d6f82]">{gym.distance}</span>
                  <div className="flex items-center gap-1">
                    <div className={`w-2 h-2 rounded-full ${getOccupancyColor(gym.occupancy)}`} />
                    <span className="text-[#6d6f82]">{gym.occupancy}% full</span>
                  </div>
                </div>
                
                <div className="flex flex-wrap gap-1 mt-2">
                  {gym.amenities.slice(0, 3).map(amenity => (
                    <Badge key={amenity} variant="outline" className="text-xs">
                      {amenity}
                    </Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Map Area */}
      <div className="flex-1 bg-[#e8eaf3] rounded-lg relative overflow-hidden">
        {/* Mock Map */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="text-center">
            <MapPin className="h-16 w-16 text-[#7d3e3a] mx-auto mb-4" />
            <p className="text-[#6d6f82]">Interactive Map</p>
            <p className="text-sm text-[#6d6f82]">Google Maps integration would go here</p>
          </div>
        </div>

        {/* Gym Markers */}
        {filteredGyms.map((gym, index) => (
          <button
            key={gym.id}
            onClick={() => setSelectedGym(gym)}
            className={`absolute w-10 h-10 rounded-full flex items-center justify-center shadow-lg transition-transform hover:scale-110 ${
              selectedGym?.id === gym.id ? 'bg-[#7d3e3a] text-white scale-125' : 'bg-white text-[#7d3e3a]'
            }`}
            style={{
              left: `${20 + index * 25}%`,
              top: `${30 + index * 15}%`
            }}
          >
            <MapPin className="h-5 w-5" />
          </button>
        ))}

        {/* Selected Gym Detail */}
        {selectedGym && (
          <Card className="absolute bottom-4 left-4 right-4 bg-white border-[#e8e9f2] shadow-lg">
            <CardContent className="p-4">
              <div className="flex items-start justify-between">
                <div>
                  <h3 className="font-semibold text-[#0e0c0b]">{selectedGym.name}</h3>
                  <div className="flex items-center gap-1 text-sm text-[#6d6f82]">
                    <Star className="h-3 w-3 fill-[#f3c700] text-[#f3c700]" />
                    {selectedGym.rating} ({selectedGym.reviewCount} reviews)
                  </div>
                  <div className="flex items-center gap-1 text-sm text-[#6d6f82] mt-1">
                    <Clock className="h-3 w-3" />
                    {selectedGym.hours}
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button size="sm" variant="outline" onClick={() => toast.info('Calling...')}>
                    <Phone className="h-4 w-4" />
                  </Button>
                  <Button size="sm" className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90">
                    <Navigation className="h-4 w-4 mr-1" />
                    Directions
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}

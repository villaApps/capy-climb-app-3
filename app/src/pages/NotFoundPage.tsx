import { Link } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Home, ArrowLeft } from 'lucide-react'

export function NotFoundPage() {
  return (
    <div className="min-h-screen bg-[#f4f4f9] flex items-center justify-center px-4">
      <div className="text-center max-w-md">
        <div className="w-24 h-24 rounded-full bg-[#7d3e3a]/10 flex items-center justify-center mx-auto mb-6">
          <span className="text-6xl font-bold text-[#7d3e3a]">404</span>
        </div>
        
        <h1 className="text-3xl font-bold text-[#0e0c0b] mb-4">
          Page Not Found
        </h1>
        
        <p className="text-[#6d6f82] mb-8">
          Sorry, we couldn't find the page you're looking for. It might have been moved or deleted.
        </p>
        
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <Link to="/">
            <Button className="bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white rounded-full">
              <Home className="mr-2 h-4 w-4" />
              Go Home
            </Button>
          </Link>
          
          <Button 
            variant="outline" 
            onClick={() => window.history.back()}
            className="border-[#dbd9d8] hover:bg-[#f4f4f9]"
          >
            <ArrowLeft className="mr-2 h-4 w-4" />
            Go Back
          </Button>
        </div>
      </div>
    </div>
  )
}

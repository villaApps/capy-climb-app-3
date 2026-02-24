import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Loader2, Mail, ArrowLeft, CheckCircle } from 'lucide-react'
import { toast } from 'sonner'

export function ForgotPasswordPage() {
  const { forgotPassword, isLoading } = useAuth()
  
  const [email, setEmail] = useState('')
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [error, setError] = useState('')

  const validateEmail = () => {
    if (!email) {
      setError('Email is required')
      return false
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email')
      return false
    }
    setError('')
    return true
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateEmail()) return
    
    try {
      await forgotPassword(email)
      setIsSubmitted(true)
      toast.success('Password reset email sent!')
    } catch (err) {
      toast.error('Failed to send reset email. Please try again.')
    }
  }

  if (isSubmitted) {
    return (
      <Card className="w-full border-0 shadow-none bg-transparent">
        <CardHeader className="space-y-1 text-center">
          <div className="mx-auto w-16 h-16 rounded-full bg-green-100 flex items-center justify-center mb-4">
            <CheckCircle className="h-8 w-8 text-green-600" />
          </div>
          <CardTitle className="text-2xl font-semibold text-[#0e0c0b]">
            Check your email
          </CardTitle>
          <CardDescription className="text-[#6d6f82]">
            We've sent a password reset link to<br />
            <span className="font-medium text-[#0e0c0b]">{email}</span>
          </CardDescription>
        </CardHeader>
        
        <CardContent className="space-y-4 text-center">
          <p className="text-sm text-[#6d6f82]">
            Didn't receive the email? Check your spam folder or try again.
          </p>
        </CardContent>

        <CardFooter className="flex flex-col gap-3">
          <Button
            onClick={() => setIsSubmitted(false)}
            variant="outline"
            className="w-full h-12 border-[#dbd9d8] hover:bg-[#f4f4f9]"
          >
            Try again
          </Button>
          <Link
            to="/signin"
            className="flex items-center justify-center gap-2 text-sm text-[#7d3e3a] hover:underline"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to sign in
          </Link>
        </CardFooter>
      </Card>
    )
  }

  return (
    <Card className="w-full border-0 shadow-none bg-transparent">
      <CardHeader className="space-y-1">
        <Link
          to="/signin"
          className="flex items-center gap-2 text-sm text-[#6d6f82] hover:text-[#0e0c0b] mb-2"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to sign in
        </Link>
        <CardTitle className="text-2xl font-semibold text-[#0e0c0b]">
          Forgot password?
        </CardTitle>
        <CardDescription className="text-[#6d6f82]">
          Enter your email and we'll send you a reset link
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="email" className="text-[#0e0c0b]">Email</Label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#6d6f82]" />
              <Input
                id="email"
                type="email"
                placeholder="name@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={isLoading}
                className={`pl-10 bg-[#e8eaf3] border-0 h-12 text-[#0e0c0b] placeholder:text-[#6d6f82] focus-visible:ring-[#7d3e3a] ${
                  error ? 'ring-2 ring-red-500' : ''
                }`}
              />
            </div>
            {error && <p className="text-sm text-red-500">{error}</p>}
          </div>

          <Button
            type="submit"
            disabled={isLoading}
            className="w-full h-12 bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white rounded-full font-medium"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Sending...
              </>
            ) : (
              'Send Reset Link'
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}

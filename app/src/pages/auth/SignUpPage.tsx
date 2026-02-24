import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Separator } from '@/components/ui/separator'
import { Checkbox } from '@/components/ui/checkbox'
import { Eye, EyeOff, Loader2, Mail, Lock, User } from 'lucide-react'
import { toast } from 'sonner'

export function SignUpPage() {
  const navigate = useNavigate()
  const { signUp, signInWithGoogle, signInWithApple, isLoading } = useAuth()
  
  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [agreeTerms, setAgreeTerms] = useState(false)
  const [errors, setErrors] = useState<{
    firstName?: string
    lastName?: string
    email?: string
    password?: string
    confirmPassword?: string
    agreeTerms?: string
  }>({})

  const validateForm = () => {
    const newErrors: typeof errors = {}
    
    if (!firstName.trim()) {
      newErrors.firstName = 'First name is required'
    }
    
    if (!lastName.trim()) {
      newErrors.lastName = 'Last name is required'
    }
    
    if (!email) {
      newErrors.email = 'Email is required'
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Please enter a valid email'
    }
    
    if (!password) {
      newErrors.password = 'Password is required'
    } else if (password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters'
    } else if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
      newErrors.password = 'Password must contain uppercase, lowercase, and number'
    }
    
    if (password !== confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match'
    }
    
    if (!agreeTerms) {
      newErrors.agreeTerms = 'You must agree to the terms'
    }
    
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!validateForm()) return
    
    try {
      await signUp(email, password, firstName, lastName)
      toast.success('Account created successfully! Please sign in.')
      navigate('/signin')
    } catch (error) {
      toast.error('Failed to create account. Please try again.')
    }
  }

  return (
    <Card className="w-full border-0 shadow-none bg-transparent">
      <CardHeader className="space-y-1 text-center">
        <CardTitle className="text-2xl font-semibold text-[#0e0c0b]">
          Create an account
        </CardTitle>
        <CardDescription className="text-[#6d6f82]">
          Join Capybara Gym and start your fitness journey
        </CardDescription>
      </CardHeader>
      
      <CardContent className="space-y-4">
        {/* Social Sign Up */}
        <div className="grid grid-cols-2 gap-3">
          <Button
            variant="outline"
            onClick={() => signInWithGoogle()}
            disabled={isLoading}
            className="bg-white border-[#dbd9d8] hover:bg-[#f4f4f9] text-[#0e0c0b]"
          >
            <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
            </svg>
            Google
          </Button>
          <Button
            variant="outline"
            onClick={() => signInWithApple()}
            disabled={isLoading}
            className="bg-white border-[#dbd9d8] hover:bg-[#f4f4f9] text-[#0e0c0b]"
          >
            <svg className="mr-2 h-4 w-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12.152 6.896c-.948 0-2.415-1.078-3.96-1.04-2.04.027-3.91 1.183-4.961 3.014-2.117 3.675-.546 9.103 1.519 12.09 1.013 1.454 2.208 3.09 3.792 3.039 1.52-.065 2.09-.987 3.935-.987 1.831 0 2.35.987 3.96.948 1.637-.026 2.676-1.48 3.676-2.948 1.156-1.688 1.636-3.325 1.662-3.415-.039-.013-3.182-1.221-3.22-4.857-.026-3.04 2.48-4.494 2.597-4.559-1.429-2.09-3.623-2.324-4.39-2.376-2-.156-3.675 1.09-4.61 1.09zM15.53 3.83c.843-1.012 1.4-2.427 1.245-3.83-1.207.052-2.662.805-3.532 1.818-.78.896-1.454 2.338-1.273 3.714 1.338.104 2.715-.688 3.559-1.701" />
            </svg>
            Apple
          </Button>
        </div>

        <div className="relative">
          <div className="absolute inset-0 flex items-center">
            <Separator className="w-full" />
          </div>
          <div className="relative flex justify-center text-xs uppercase">
            <span className="bg-[#f4f4f9] px-2 text-[#6d6f82]">Or continue with</span>
          </div>
        </div>

        {/* Sign Up Form */}
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="firstName" className="text-[#0e0c0b]">First Name</Label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#6d6f82]" />
                <Input
                  id="firstName"
                  placeholder="John"
                  value={firstName}
                  onChange={(e) => setFirstName(e.target.value)}
                  disabled={isLoading}
                  className={`pl-10 bg-[#e8eaf3] border-0 h-12 text-[#0e0c0b] placeholder:text-[#6d6f82] focus-visible:ring-[#7d3e3a] ${
                    errors.firstName ? 'ring-2 ring-red-500' : ''
                  }`}
                />
              </div>
              {errors.firstName && <p className="text-sm text-red-500">{errors.firstName}</p>}
            </div>

            <div className="space-y-2">
              <Label htmlFor="lastName" className="text-[#0e0c0b]">Last Name</Label>
              <Input
                id="lastName"
                placeholder="Doe"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                disabled={isLoading}
                className={`bg-[#e8eaf3] border-0 h-12 text-[#0e0c0b] placeholder:text-[#6d6f82] focus-visible:ring-[#7d3e3a] ${
                  errors.lastName ? 'ring-2 ring-red-500' : ''
                }`}
              />
              {errors.lastName && <p className="text-sm text-red-500">{errors.lastName}</p>}
            </div>
          </div>

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
                  errors.email ? 'ring-2 ring-red-500' : ''
                }`}
              />
            </div>
            {errors.email && <p className="text-sm text-red-500">{errors.email}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="password" className="text-[#0e0c0b]">Password</Label>
            <div className="relative">
              <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[#6d6f82]" />
              <Input
                id="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="Create a password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                disabled={isLoading}
                className={`pl-10 pr-10 bg-[#e8eaf3] border-0 h-12 text-[#0e0c0b] placeholder:text-[#6d6f82] focus-visible:ring-[#7d3e3a] ${
                  errors.password ? 'ring-2 ring-red-500' : ''
                }`}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-[#6d6f82] hover:text-[#0e0c0b]"
              >
                {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
              </button>
            </div>
            {errors.password && <p className="text-sm text-red-500">{errors.password}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="confirmPassword" className="text-[#0e0c0b]">Confirm Password</Label>
            <Input
              id="confirmPassword"
              type={showPassword ? 'text' : 'password'}
              placeholder="Confirm your password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              disabled={isLoading}
              className={`bg-[#e8eaf3] border-0 h-12 text-[#0e0c0b] placeholder:text-[#6d6f82] focus-visible:ring-[#7d3e3a] ${
                errors.confirmPassword ? 'ring-2 ring-red-500' : ''
              }`}
            />
            {errors.confirmPassword && <p className="text-sm text-red-500">{errors.confirmPassword}</p>}
          </div>

          <div className="flex items-start space-x-2">
            <Checkbox
              id="terms"
              checked={agreeTerms}
              onCheckedChange={(checked) => setAgreeTerms(checked as boolean)}
              className="mt-1"
            />
            <Label htmlFor="terms" className="text-sm text-[#6d6f82] leading-relaxed">
              I agree to the{' '}
              <Link to="/terms" className="text-[#7d3e3a] hover:underline">Terms of Service</Link>
              {' '}and{' '}
              <Link to="/privacy" className="text-[#7d3e3a] hover:underline">Privacy Policy</Link>
            </Label>
          </div>
          {errors.agreeTerms && <p className="text-sm text-red-500">{errors.agreeTerms}</p>}

          <Button
            type="submit"
            disabled={isLoading}
            className="w-full h-12 bg-[#7d3e3a] hover:bg-[#7d3e3a]/90 text-white rounded-full font-medium"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Creating account...
              </>
            ) : (
              'Create Account'
            )}
          </Button>
        </form>
      </CardContent>

      <CardFooter className="flex justify-center">
        <p className="text-sm text-[#6d6f82]">
          Already have an account?{' '}
          <Link to="/signin" className="text-[#7d3e3a] hover:underline font-medium">
            Sign in
          </Link>
        </p>
      </CardFooter>
    </Card>
  )
}

import { createContext, useContext, useState, useCallback, type ReactNode } from 'react'

export interface User {
  id: string
  email: string
  firstName: string
  lastName: string
  displayName: string
  avatar?: string
  membershipTier?: string
}

interface AuthContextType {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, firstName: string, lastName: string) => Promise<void>
  signOut: () => Promise<void>
  forgotPassword: (email: string) => Promise<void>
  resetPassword: (token: string, newPassword: string) => Promise<void>
  signInWithGoogle: () => Promise<void>
  signInWithApple: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  const signIn = useCallback(async (email: string, password: string) => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // const result = await Auth.signIn(email, password)
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
      setUser({
        id: '1',
        email,
        firstName: 'Test',
        lastName: 'User',
        displayName: 'Test User',
      })
    } finally {
      setIsLoading(false)
    }
  }, [])

  const signUp = useCallback(async (email: string, password: string, firstName: string, lastName: string) => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.signUp({
      //   username: email,
      //   password,
      //   attributes: { given_name: firstName, family_name: lastName }
      // })
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
    } finally {
      setIsLoading(false)
    }
  }, [])

  const signOut = useCallback(async () => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.signOut()
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 500))
      setUser(null)
    } finally {
      setIsLoading(false)
    }
  }, [])

  const forgotPassword = useCallback(async (email: string) => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.forgotPassword(email)
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
    } finally {
      setIsLoading(false)
    }
  }, [])

  const resetPassword = useCallback(async (token: string, newPassword: string) => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.forgotPasswordSubmit(email, token, newPassword)
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
    } finally {
      setIsLoading(false)
    }
  }, [])

  const signInWithGoogle = useCallback(async () => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.federatedSignIn({ provider: CognitoHostedUIIdentityProvider.Google })
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
      setUser({
        id: '2',
        email: 'google@example.com',
        firstName: 'Google',
        lastName: 'User',
        displayName: 'Google User',
      })
    } finally {
      setIsLoading(false)
    }
  }, [])

  const signInWithApple = useCallback(async () => {
    setIsLoading(true)
    try {
      // TODO: Integrate with AWS Amplify
      // await Auth.federatedSignIn({ provider: CognitoHostedUIIdentityProvider.Apple })
      
      // Mock implementation
      await new Promise(resolve => setTimeout(resolve, 1000))
      setUser({
        id: '3',
        email: 'apple@example.com',
        firstName: 'Apple',
        lastName: 'User',
        displayName: 'Apple User',
      })
    } finally {
      setIsLoading(false)
    }
  }, [])

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    signIn,
    signUp,
    signOut,
    forgotPassword,
    resetPassword,
    signInWithGoogle,
    signInWithApple,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export function useRequireAuth() {
  const { isAuthenticated, isLoading } = useAuth()
  return { isAuthenticated, isLoading }
}

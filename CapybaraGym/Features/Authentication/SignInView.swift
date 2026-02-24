//
//  SignInView.swift
//  CapybaraGym
//
//  Sign In screen
//

import SwiftUI

public struct SignInView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showForgotPassword = false
    @State private var showSignUp = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                CapyColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: CapySpacing.xLarge) {
                        // Logo and Title
                        headerSection
                        
                        // Form
                        formSection
                        
                        // Actions
                        actionsSection
                        
                        // Footer
                        footerSection
                    }
                    .padding(.horizontal, CapySpacing.large)
                    .padding(.top, CapySpacing.xHuge)
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
            .alert(item: errorBinding) { error in
                Alert(
                    title: Text("Error"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: CapySpacing.medium) {
            // App Logo
            ZStack {
                Circle()
                    .fill(CapyColors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(CapyColors.primary)
            }
            
            Text("Welcome Back")
                .font(CapyTypography.heading1)
                .foregroundColor(CapyColors.textPrimary)
            
            Text("Sign in to continue your fitness journey")
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: CapySpacing.medium) {
            CapyTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: $viewModel.email,
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )
            
            CapyTextField(
                title: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                icon: "lock",
                isSecure: true,
                textContentType: .password
            )
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: CapySpacing.medium) {
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(CapyTypography.bodySmall)
                .foregroundColor(CapyColors.primary)
            }
            
            // Sign In Button
            CapyButton(
                title: "Sign In",
                isLoading: viewModel.viewState.isLoading,
                action: {
                    Task {
                        await viewModel.signIn()
                    }
                }
            )
            .disabled(!viewModel.isSignInValid)
            .opacity(viewModel.isSignInValid ? 1.0 : 0.6)
        }
    }
    
    private var footerSection: some View {
        HStack(spacing: CapySpacing.xSmall) {
            Text("Don't have an account?")
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textSecondary)
            
            Button("Sign Up") {
                showSignUp = true
            }
            .font(CapyTypography.bodyMedium)
            .foregroundColor(CapyColors.primary)
        }
        .padding(.top, CapySpacing.large)
    }
    
    // MARK: - Helpers
    
    private var errorBinding: Binding<AuthError?> {
        Binding(
            get: {
                if case .error(let error) = viewModel.viewState,
                   let authError = error as? AuthError {
                    return authError
                }
                return nil
            },
            set: { _ in
                viewModel.clearError()
            }
        )
    }
}

// MARK: - Forgot Password View
struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var isSubmitted = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CapySpacing.large) {
                Text("Reset Password")
                    .font(CapyTypography.heading2)
                    .foregroundColor(CapyColors.textPrimary)
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                if isSubmitted {
                    VStack(spacing: CapySpacing.medium) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundColor(CapyColors.primary)
                        
                        Text("Check your email")
                            .font(CapyTypography.heading3)
                            .foregroundColor(CapyColors.textPrimary)
                        
                        Text("We've sent password reset instructions to \(email)")
                            .font(CapyTypography.bodyMedium)
                            .foregroundColor(CapyColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, CapySpacing.large)
                } else {
                    CapyTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        icon: "envelope",
                        keyboardType: .emailAddress
                    )
                    
                    CapyButton(
                        title: "Send Instructions",
                        action: {
                            isSubmitted = true
                        }
                    )
                    .disabled(!email.isValidEmail)
                    .opacity(email.isValidEmail ? 1.0 : 0.6)
                }
                
                Spacer()
            }
            .padding()
            .background(CapyColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

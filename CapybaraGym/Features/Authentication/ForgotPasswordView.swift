//
//  ForgotPasswordView.swift
//  CapybaraGym
//
//  Password recovery screen
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.top, 20)
                    
                    if viewModel.resetSent {
                        // Success State
                        successSection
                            .padding(.top, 40)
                    } else {
                        // Form
                        formSection
                            .padding(.top, 40)
                        
                        // Reset Button
                        Button(action: { viewModel.sendResetLink() }) {
                            Text("Send Reset Link")
                                .font(.button)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!viewModel.isEmailValid)
                        .opacity(viewModel.isEmailValid ? 1.0 : 0.6)
                        .padding(.top, 32)
                    }
                    
                    Spacer()
                    
                    // Back to Sign In
                    backToSignInSection
                        .padding(.bottom, 32)
                }
                .padding(.horizontal, Layout.horizontalPadding)
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.primaryBrown)
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Forgot Password?")
                .font(.title1)
                .foregroundColor(.primaryText)
            
            Text("Enter your email address and we'll send you a link to reset your password")
                .font(.bodyMedium)
                .foregroundColor(.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Email Address")
                .font(.bodySmall)
                .foregroundColor(.secondaryText)
            
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(viewModel.emailIsFocused ? .primaryBrown : .tertiaryText)
                TextField("Enter your email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
            }
            .padding(.horizontal, Layout.spacingM)
            .frame(height: Layout.inputFieldHeight)
            .background(Color.inputBackground)
            .cornerRadius(Layout.radiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusMedium)
                    .stroke(viewModel.emailIsFocused ? Color.primaryBrown : Color.clear, lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Success Section
    private var successSection: some View {
        VStack(spacing: 24) {
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.occupancyLow.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.occupancyLow)
            }
            
            VStack(spacing: 12) {
                Text("Check Your Email")
                    .font(.title2)
                    .foregroundColor(.primaryText)
                
                Text("We've sent a password reset link to")
                    .font(.bodyMedium)
                    .foregroundColor(.secondaryText)
                
                Text(viewModel.email)
                    .font(.bodyMedium)
                    .foregroundColor(.primaryBrown)
            }
            
            VStack(spacing: 16) {
                Text("Didn't receive the email? Check your spam folder or")
                    .font(.bodySmall)
                    .foregroundColor(.secondaryText)
                
                Button(action: { viewModel.sendResetLink() }) {
                    Text("Resend Email")
                        .font(.button)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Back to Sign In Section
    private var backToSignInSection: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left")
                    .font(.bodyMedium)
                Text("Back to Sign In")
                    .font(.bodyMedium)
            }
            .foregroundColor(.primaryBrown)
        }
    }
}

// MARK: - ViewModel
@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var emailIsFocused = false
    @Published var isLoading = false
    @Published var resetSent = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var isEmailValid: Bool {
        !email.isEmpty && email.contains("@")
    }
    
    func sendResetLink() {
        guard isEmailValid else { return }
        
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            self.resetSent = true
        }
    }
}

// MARK: - Preview
#Preview("Forgot Password View") {
    NavigationStack {
        ForgotPasswordView()
    }
}

//
//  SignUpView.swift
//  CapybaraGym
//
//  Sign Up screen
//

import SwiftUI

public struct SignUpView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            CapyColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: CapySpacing.xLarge) {
                    // Header
                    headerSection
                    
                    // Form
                    formSection
                    
                    // Sign Up Button
                    CapyButton(
                        title: "Create Account",
                        isLoading: viewModel.viewState.isLoading,
                        action: {
                            Task {
                                await viewModel.signUp()
                                if case .success = viewModel.viewState {
                                    showConfirmation = true
                                }
                            }
                        }
                    )
                    .disabled(!viewModel.isSignUpValid)
                    .opacity(viewModel.isSignUpValid ? 1.0 : 0.6)
                    
                    // Terms
                    termsSection
                }
                .padding(.horizontal, CapySpacing.large)
                .padding(.vertical, CapySpacing.large)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showConfirmation) {
            ConfirmationView(viewModel: viewModel)
        }
        .alert(item: errorBinding) { error in
            Alert(
                title: Text("Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: CapySpacing.small) {
            Text("Join Capybara Gym")
                .font(CapyTypography.heading1)
                .foregroundColor(CapyColors.textPrimary)
            
            Text("Start your fitness journey today")
                .font(CapyTypography.bodyMedium)
                .foregroundColor(CapyColors.textSecondary)
        }
    }
    
    private var formSection: some View {
        VStack(spacing: CapySpacing.medium) {
            // Name fields
            HStack(spacing: CapySpacing.medium) {
                CapyTextField(
                    title: "First Name",
                    placeholder: "John",
                    text: $viewModel.firstName,
                    textContentType: .givenName
                )
                
                CapyTextField(
                    title: "Last Name",
                    placeholder: "Doe",
                    text: $viewModel.lastName,
                    textContentType: .familyName
                )
            }
            
            CapyTextField(
                title: "Email",
                placeholder: "john@example.com",
                text: $viewModel.email,
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                autocapitalization: .never
            )
            
            CapyTextField(
                title: "Phone (Optional)",
                placeholder: "+1 (555) 000-0000",
                text: $viewModel.phoneNumber,
                icon: "phone",
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            )
            
            CapyTextField(
                title: "Password",
                placeholder: "Create a password",
                text: $viewModel.password,
                icon: "lock",
                isSecure: true,
                textContentType: .newPassword
            )
            
            CapyTextField(
                title: "Confirm Password",
                placeholder: "Confirm your password",
                text: $viewModel.confirmPassword,
                icon: "lock.shield",
                isSecure: true,
                textContentType: .newPassword
            )
            
            // Password requirements
            passwordRequirements
        }
    }
    
    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: CapySpacing.xxSmall) {
            Text("Password must contain:")
                .font(CapyTypography.caption)
                .foregroundColor(CapyColors.textSecondary)
            
            RequirementRow(
                text: "At least 8 characters",
                isMet: viewModel.password.count >= 8
            )
            
            RequirementRow(
                text: "One uppercase letter",
                isMet: viewModel.password.rangeOfCharacter(from: .uppercaseLetters) != nil
            )
            
            RequirementRow(
                text: "One lowercase letter",
                isMet: viewModel.password.rangeOfCharacter(from: .lowercaseLetters) != nil
            )
            
            RequirementRow(
                text: "One number",
                isMet: viewModel.password.rangeOfCharacter(from: .decimalDigits) != nil
            )
        }
    }
    
    private var termsSection: some View {
        Text("By creating an account, you agree to our [Terms of Service](https://capybaragym.com/terms) and [Privacy Policy](https://capybaragym.com/privacy)")
            .font(CapyTypography.caption)
            .foregroundColor(CapyColors.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.top, CapySpacing.medium)
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

// MARK: - Requirement Row
struct RequirementRow: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: CapySpacing.xxSmall) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isMet ? CapyColors.success : CapyColors.textTertiary)
            
            Text(text)
                .font(CapyTypography.caption)
                .foregroundColor(isMet ? CapyColors.textPrimary : CapyColors.textTertiary)
        }
    }
}

// MARK: - Confirmation View
struct ConfirmationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var resendTimer = 60
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: CapySpacing.large) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(CapyColors.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 50))
                        .foregroundColor(CapyColors.primary)
                }
                
                // Title
                Text("Verify Your Email")
                    .font(CapyTypography.heading2)
                    .foregroundColor(CapyColors.textPrimary)
                
                // Description
                Text("We've sent a verification code to \(viewModel.email)")
                    .font(CapyTypography.bodyMedium)
                    .foregroundColor(CapyColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                // Code Input
                VStack(spacing: CapySpacing.medium) {
                    CapyTextField(
                        title: "Verification Code",
                        placeholder: "Enter 6-digit code",
                        text: $viewModel.confirmationCode,
                        icon: "number",
                        keyboardType: .numberPad
                    )
                    
                    CapyButton(
                        title: "Verify",
                        isLoading: viewModel.viewState.isLoading,
                        action: {
                            Task {
                                await viewModel.confirmSignUp()
                                if case .success = viewModel.viewState {
                                    dismiss()
                                }
                            }
                        }
                    )
                    .disabled(viewModel.confirmationCode.count != 6)
                    .opacity(viewModel.confirmationCode.count == 6 ? 1.0 : 0.6)
                }
                .padding(.top, CapySpacing.large)
                
                // Resend
                HStack(spacing: CapySpacing.xxSmall) {
                    Text("Didn't receive it?")
                        .font(CapyTypography.bodySmall)
                        .foregroundColor(CapyColors.textSecondary)
                    
                    if resendTimer > 0 {
                        Text("Resend in \(resendTimer)s")
                            .font(CapyTypography.bodySmall)
                            .foregroundColor(CapyColors.textTertiary)
                    } else {
                        Button("Resend") {
                            Task {
                                await viewModel.resendConfirmationCode()
                                startTimer()
                            }
                        }
                        .font(CapyTypography.bodySmall)
                        .foregroundColor(CapyColors.primary)
                    }
                }
                .padding(.top, CapySpacing.medium)
                
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
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
    
    private func startTimer() {
        resendTimer = 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendTimer > 0 {
                resendTimer -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

// MARK: - Preview
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

//
//  BuyPassView.swift
//  CapybaraGym
//
//  Purchase passes screen
//

import SwiftUI

struct BuyPassView: View {
    @StateObject private var viewModel = BuyPassViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Gym Selection
                        gymSelectionSection
                        
                        // Pass Types
                        passTypesSection
                        
                        // Payment Summary
                        if viewModel.selectedPass != nil {
                            paymentSummarySection
                        }
                        
                        // Payment Methods
                        paymentMethodsSection
                        
                        // Purchase Button
                        purchaseButton
                            .padding(.top, 8)
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Buy Pass")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primaryBrown)
                }
            }
            .sheet(isPresented: $viewModel.showGymSelection) {
                GymSelectionSheet(selectedGym: $viewModel.selectedGym)
            }
            .alert("Success!", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your pass has been purchased successfully!")
            }
        }
    }
    
    // MARK: - Gym Selection Section
    private var gymSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Gym")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Button(action: { viewModel.showGymSelection = true }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "building.2")
                            .font(.system(size: 24))
                            .foregroundColor(.tertiaryText)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.selectedGym?.name ?? "Select a gym")
                            .font(.bodyMedium)
                            .foregroundColor(viewModel.selectedGym != nil ? .primaryText : .tertiaryText)
                        
                        if let gym = viewModel.selectedGym {
                            Text(gym.address)
                                .font(.caption)
                                .foregroundColor(.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                }
                .padding(12)
                .background(Color.cardBackground)
                .cornerRadius(Layout.radiusMedium)
            }
        }
    }
    
    // MARK: - Pass Types Section
    private var passTypesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Pass Type")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.passTypes) { passType in
                    PassTypeCard(
                        passType: passType,
                        isSelected: viewModel.selectedPass?.id == passType.id,
                        action: { viewModel.selectPass(passType) }
                    )
                }
            }
        }
    }
    
    // MARK: - Payment Summary Section
    private var paymentSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 12) {
                // Pass Details
                HStack {
                    Text(viewModel.selectedPass?.name ?? "")
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.selectedPass?.price ?? 0))")
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                }
                
                Divider()
                
                // Subtotal
                HStack {
                    Text("Subtotal")
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.subtotal))")
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                }
                
                // Tax
                HStack {
                    Text("Tax (8%)")
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.tax))")
                        .font(.bodySmall)
                        .foregroundColor(.secondaryText)
                }
                
                // Discount (if applicable)
                if viewModel.discount > 0 {
                    HStack {
                        Text("Discount")
                            .font(.bodySmall)
                            .foregroundColor(.occupancyLow)
                        
                        Spacer()
                        
                        Text("-$\(String(format: "%.2f", viewModel.discount))")
                            .font(.bodySmall)
                            .foregroundColor(.occupancyLow)
                    }
                }
                
                Divider()
                
                // Total
                HStack {
                    Text("Total")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", viewModel.total))")
                        .font(.title3)
                        .foregroundColor(.primaryBrown)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
        }
    }
    
    // MARK: - Payment Methods Section
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            VStack(spacing: 0) {
                ForEach(viewModel.paymentMethods) { method in
                    PaymentMethodRow(
                        method: method,
                        isSelected: viewModel.selectedPaymentMethod?.id == method.id,
                        action: { viewModel.selectPaymentMethod(method) }
                    )
                    
                    if method.id != viewModel.paymentMethods.last?.id {
                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(Layout.radiusLarge)
            
            Button(action: { viewModel.addPaymentMethod() }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle")
                        .font(.bodyMedium)
                    Text("Add Payment Method")
                        .font(.bodyMedium)
                }
                .foregroundColor(.primaryBrown)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.primaryBrown.opacity(0.1))
                .cornerRadius(Layout.radiusMedium)
            }
        }
    }
    
    // MARK: - Purchase Button
    private var purchaseButton: some View {
        Button(action: { viewModel.purchase() }) {
            Text("Purchase Pass - $\(String(format: "%.2f", viewModel.total))")
                .font(.button)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canPurchase)
        .opacity(viewModel.canPurchase ? 1.0 : 0.6)
    }
}

// MARK: - Pass Type Card
struct PassTypeCard: View {
    let passType: PassType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.primaryBrown.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: passType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .primaryBrown : .tertiaryText)
                }
                
                VStack(spacing: 4) {
                    Text(passType.name)
                        .font(.bodyMedium)
                        .foregroundColor(isSelected ? .primaryText : .secondaryText)
                    
                    Text(passType.duration)
                        .font(.caption)
                        .foregroundColor(.tertiaryText)
                    
                    Text("$\(String(format: "%.2f", passType.price))")
                        .font(.headline)
                        .foregroundColor(isSelected ? .primaryBrown : .secondaryText)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.primaryBrown.opacity(0.05) : Color.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.radiusLarge)
                    .stroke(isSelected ? Color.primaryBrown : Color.clear, lineWidth: 2)
            )
            .cornerRadius(Layout.radiusLarge)
        }
    }
}

// MARK: - Payment Method Row
struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: method.icon)
                    .font(.system(size: 24))
                    .foregroundColor(method.color)
                    .frame(width: 32)
                
                // Details
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.name)
                        .font(.bodyMedium)
                        .foregroundColor(.primaryText)
                    
                    if let subtitle = method.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .primaryBrown : .tertiaryText)
            }
            .padding(14)
        }
    }
}

// MARK: - Gym Selection Sheet
struct GymSelectionSheet: View {
    @Binding var selectedGym: GymLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    let gyms: [GymLocation] = [
        GymLocation(id: "1", name: "Capybara Fitness Center", address: "123 Gym Street, Downtown"),
        GymLocation(id: "2", name: "Iron Pump Gym", address: "456 Muscle Ave, Uptown"),
        GymLocation(id: "3", name: "Zen Wellness Studio", address: "789 Peace Blvd, Midtown")
    ]
    
    var filteredGyms: [GymLocation] {
        if searchText.isEmpty { return gyms }
        return gyms.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredGyms) { gym in
                    Button(action: {
                        selectedGym = gym
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(gym.name)
                                    .font(.bodyMedium)
                                    .foregroundColor(.primaryText)
                                Text(gym.address)
                                    .font(.caption)
                                    .foregroundColor(.secondaryText)
                            }
                            
                            Spacer()
                            
                            if selectedGym?.id == gym.id {
                                Image(systemName: "checkmark")
                                    .font(.bodyMedium)
                                    .foregroundColor(.primaryBrown)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Gym")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placeholder: "Search gyms")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Pass Type Model
struct PassType: Identifiable {
    let id: String
    let name: String
    let duration: String
    let price: Double
    let icon: String
    
    static let all = [
        PassType(id: "1", name: "Day Pass", duration: "1 Day", price: 15.99, icon: "sun.max.fill"),
        PassType(id: "2", name: "Week Pass", duration: "7 Days", price: 49.99, icon: "calendar.badge.clock"),
        PassType(id: "3", name: "Monthly", duration: "30 Days", price: 99.99, icon: "calendar"),
        PassType(id: "4", name: "10 Visits", duration: "Flexible", price: 129.99, icon: "number")
    ]
}

// MARK: - Payment Method Model
struct PaymentMethod: Identifiable {
    let id: String
    let name: String
    let subtitle: String?
    let icon: String
    let color: Color
    
    static let sample = [
        PaymentMethod(id: "1", name: "•••• 4242", subtitle: "Expires 12/25", icon: "creditcard.fill", color: .primaryBrown),
        PaymentMethod(id: "2", name: "Apple Pay", subtitle: nil, icon: "apple.logo", color: .black),
        PaymentMethod(id: "3", name: "PayPal", subtitle: nil, icon: "dollarsign.circle.fill", color: .blue)
    ]
}

// MARK: - Gym Location Model
struct GymLocation: Identifiable {
    let id: String
    let name: String
    let address: String
}

// MARK: - ViewModel
@MainActor
class BuyPassViewModel: ObservableObject {
    @Published var selectedGym: GymLocation?
    @Published var selectedPass: PassType?
    @Published var selectedPaymentMethod: PaymentMethod?
    @Published var showGymSelection = false
    @Published var showSuccess = false
    
    let passTypes: [PassType] = PassType.all
    let paymentMethods: [PaymentMethod] = PaymentMethod.sample
    
    var subtotal: Double { selectedPass?.price ?? 0 }
    var tax: Double { subtotal * 0.08 }
    var discount: Double { 0 }
    var total: Double { subtotal + tax - discount }
    
    var canPurchase: Bool {
        selectedGym != nil && selectedPass != nil && selectedPaymentMethod != nil
    }
    
    func selectPass(_ pass: PassType) {
        selectedPass = pass
    }
    
    func selectPaymentMethod(_ method: PaymentMethod) {
        selectedPaymentMethod = method
    }
    
    func addPaymentMethod() {
        // Add new payment method
    }
    
    func purchase() {
        guard canPurchase else { return }
        showSuccess = true
    }
}

// MARK: - Preview
#Preview("Buy Pass View") {
    BuyPassView()
}

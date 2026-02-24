//
//  View+Extensions.swift
//  CapybaraGym
//
//  View extensions for common operations
//

import SwiftUI

// MARK: - View Modifiers
public extension View {
    
    /// Hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Add a dismiss keyboard gesture
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
    
    /// Apply corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Add a border with specific corners
    func border(_ color: Color, width: CGFloat, cornerRadius: CGFloat) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: width)
        )
    }
    
    /// Add a gradient border
    func gradientBorder(
        colors: [Color],
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 16
    ) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: lineWidth
                )
        )
    }
    
    /// Apply a shimmer effect for loading states
    func shimmer(isActive: Bool) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
    
    /// Add a placeholder for async images
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .center,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self.opacity(shouldShow ? 0 : 1)
        }
    }
    
    /// Read the view's size
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    /// Read the view's frame
    func readFrame(in coordinateSpace: CoordinateSpace, onChange: @escaping (CGRect) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: geometry.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
    }
}

// MARK: - Rounded Corner Shape
public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preference Keys
public struct SizePreferenceKey: PreferenceKey {
    public static var defaultValue: CGSize = .zero
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public struct FramePreferenceKey: PreferenceKey {
    public static var defaultValue: CGRect = .zero
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Shimmer Modifier
public struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.5)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 2)
                        .mask(content)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                            ) {
                                phase = 1
                            }
                        }
                    }
                }
            )
    }
}

// MARK: - Async Image Extensions
public extension AsyncImage {
    
    /// Add a placeholder and error view to AsyncImage
    func withPlaceholder<Placeholder: View, ErrorView: View>(
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder errorView: @escaping () -> ErrorView
    ) -> some View {
        self.phase { phase in
            switch phase {
            case .empty:
                placeholder()
            case .success(let image):
                image.resizable()
            case .failure:
                errorView()
            @unknown default:
                placeholder()
            }
        }
    }
}

// MARK: - ScrollView Extensions
public extension ScrollView {
    
    /// Add refresh capability
    func refreshable(action: @escaping @Sendable () async -> Void) -> some View {
        self.refreshable(action: action)
    }
}

// MARK: - List Extensions
public extension List {
    
    /// Remove list row background
    func removeRowBackground() -> some View {
        self.listRowBackground(Color.clear)
    }
    
    /// Remove list separators
    func removeSeparators() -> some View {
        self.listRowSeparator(.hidden)
    }
}

// MARK: - Navigation Extensions
public extension View {
    
    /// Configure navigation bar title display mode
    func navigationBarTitleDisplayMode(_ mode: NavigationBarItem.TitleDisplayMode) -> some View {
        self.navigationBarTitleDisplayMode(mode)
    }
    
    /// Hide navigation bar back button
    func hideBackButton() -> some View {
        self.navigationBarBackButtonHidden(true)
    }
    
    /// Add custom back button
    func customBackButton(action: @escaping () -> Void) -> some View {
        self.navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(CapyColors.primary)
            })
    }
}

// MARK: - Alert Extensions
public extension View {
    
    /// Show an alert with error
    func alert(error: Binding<Error?>, buttonTitle: String = "OK") -> some View {
        self.alert(
            "Error",
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            ),
            actions: {
                Button(buttonTitle, role: .cancel) {
                    error.wrappedValue = nil
                }
            },
            message: {
                if let error = error.wrappedValue {
                    Text(error.localizedDescription)
                }
            }
        )
    }
}

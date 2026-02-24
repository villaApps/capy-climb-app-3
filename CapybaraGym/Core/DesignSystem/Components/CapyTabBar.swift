//
//  CapyTabBar.swift
//  CapybaraGym
//
//  Custom tab bar component
//

import SwiftUI

// MARK: - Tab Item
public struct CapyTabItem {
    let id: String
    let title: String
    let icon: String
    let selectedIcon: String
    
    public init(
        id: String,
        title: String,
        icon: String,
        selectedIcon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon + ".fill"
    }
}

// MARK: - CapyTabBar
public struct CapyTabBar: View {
    
    // MARK: - Properties
    let items: [CapyTabItem]
    @Binding var selectedTab: String
    
    // MARK: - Initialization
    public init(
        items: [CapyTabItem],
        selectedTab: Binding<String>
    ) {
        self.items = items
        self._selectedTab = selectedTab
    }
    
    // MARK: - Body
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.id) { item in
                TabButton(
                    item: item,
                    isSelected: selectedTab == item.id
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = item.id
                    }
                }
            }
        }
        .padding(.horizontal, CapySpacing.small)
        .padding(.top, CapySpacing.small)
        .padding(.bottom, CapySpacing.medium + SafeAreaInsets.bottom)
        .background(
            CapyColors.cardElevated
                .shadow(color: CapyColors.shadow, radius: 20, x: 0, y: -5)
        )
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let item: CapyTabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: CapySpacing.xxSmall) {
                // Icon
                Image(systemName: isSelected ? item.selectedIcon : item.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? CapyColors.primary : CapyColors.textTertiary)
                    .frame(height: 24)
                
                // Title
                Text(item.title)
                    .font(CapyTypography.labelSmall)
                    .foregroundColor(isSelected ? CapyColors.primary : CapyColors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, CapySpacing.xSmall)
        }
    }
}

// MARK: - CapyTabView
public struct CapyTabView<Content: View>: View {
    
    // MARK: - Properties
    let items: [CapyTabItem]
    @Binding var selectedTab: String
    let content: Content
    
    // MARK: - Initialization
    public init(
        items: [CapyTabItem],
        selectedTab: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self.items = items
        self._selectedTab = selectedTab
        self.content = content()
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            content
                .padding(.bottom, CapyLayout.tabBarHeight)
            
            // Tab bar
            CapyTabBar(
                items: items,
                selectedTab: $selectedTab
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Floating Action Button Tab Bar
public struct CapyFloatingTabBar: View {
    
    // MARK: - Properties
    let items: [CapyTabItem]
    let centerItem: CapyTabItem?
    @Binding var selectedTab: String
    let onCenterTap: (() -> Void)?
    
    // MARK: - Initialization
    public init(
        items: [CapyTabItem],
        centerItem: CapyTabItem? = nil,
        selectedTab: Binding<String>,
        onCenterTap: (() -> Void)? = nil
    ) {
        self.items = items
        self.centerItem = centerItem
        self._selectedTab = selectedTab
        self.onCenterTap = onCenterTap
    }
    
    // MARK: - Body
    public var body: some View {
        HStack(spacing: 0) {
            // Left items
            HStack(spacing: 0) {
                ForEach(Array(items.prefix(items.count / 2).enumerated()), id: \.element.id) { _, item in
                    TabButton(
                        item: item,
                        isSelected: selectedTab == item.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item.id
                        }
                    }
                }
            }
            
            // Center button
            if let centerItem = centerItem {
                Spacer()
                
                Button(action: { onCenterTap?() }) {
                    ZStack {
                        Circle()
                            .fill(CapyColors.primary)
                            .frame(width: 56, height: 56)
                            .shadow(color: CapyColors.primary.opacity(0.4), radius: 10, x: 0, y: 4)
                        
                        Image(systemName: centerItem.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -20)
                
                Spacer()
            }
            
            // Right items
            HStack(spacing: 0) {
                ForEach(Array(items.suffix(from: items.count / 2).enumerated()), id: \.element.id) { _, item in
                    TabButton(
                        item: item,
                        isSelected: selectedTab == item.id
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = item.id
                        }
                    }
                }
            }
        }
        .padding(.horizontal, CapySpacing.small)
        .padding(.top, CapySpacing.small)
        .padding(.bottom, CapySpacing.medium + SafeAreaInsets.bottom)
        .background(
            CapyColors.cardElevated
                .shadow(color: CapyColors.shadow, radius: 20, x: 0, y: -5)
        )
    }
}

// MARK: - Preview
struct CapyTabBar_Previews: PreviewProvider {
    static let tabs = [
        CapyTabItem(id: "home", title: "Home", icon: "house"),
        CapyTabItem(id: "map", title: "Map", icon: "map"),
        CapyTabItem(id: "pass", title: "Pass", icon: "qrcode"),
        CapyTabItem(id: "shop", title: "Shop", icon: "bag"),
        CapyTabItem(id: "profile", title: "Profile", icon: "person")
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            
            // Standard tab bar
            CapyTabBar(
                items: tabs,
                selectedTab: .constant("home")
            )
        }
        .background(CapyColors.background)
        
        VStack {
            Spacer()
            
            // Floating action tab bar
            CapyFloatingTabBar(
                items: Array(tabs.prefix(2) + tabs.suffix(2)),
                centerItem: CapyTabItem(id: "scan", title: "Scan", icon: "qrcode"),
                selectedTab: .constant("home"),
                onCenterTap: {}
            )
        }
        .background(CapyColors.background)
    }
}

//
//  OccupancyIndicator.swift
//  CapybaraGym
//
//  Gym crowd level indicator component
//

import SwiftUI

struct OccupancyIndicator: View {
    let occupancy: Int
    let capacity: Int
    var showLabel: Bool = true
    var style: IndicatorStyle = .full
    
    enum IndicatorStyle {
        case full      // Full bar with text
        case compact   // Just bar
        case dot       // Status dot only
        case text      // Text only
    }
    
    private var percentage: Double {
        guard capacity > 0 else { return 0 }
        return Double(occupancy) / Double(capacity)
    }
    
    private var level: OccupancyLevel {
        switch percentage {
        case 0..<0.5:
            return .low
        case 0.5..<0.8:
            return .medium
        default:
            return .high
        }
    }
    
    private var statusText: String {
        switch level {
        case .low:
            return "Not Crowded"
        case .medium:
            return "Moderately Busy"
        case .high:
            return "Very Crowded"
        }
    }
    
    var body: some View {
        switch style {
        case .full:
            fullIndicator
        case .compact:
            compactIndicator
        case .dot:
            dotIndicator
        case .text:
            textIndicator
        }
    }
    
    private var fullIndicator: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if showLabel {
                    Text("Current Occupancy")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Text("\(occupancy)/\(capacity)")
                    .font(.captionMedium)
                    .foregroundColor(level.color)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(level.color)
                        .frame(width: geometry.size.width * CGFloat(percentage), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: percentage)
                }
            }
            .frame(height: 8)
            
            HStack {
                StatusDot(color: level.color)
                Text(statusText)
                    .font(.captionMedium)
                    .foregroundColor(level.color)
            }
        }
    }
    
    private var compactIndicator: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(level.color)
                    .frame(width: geometry.size.width * CGFloat(percentage), height: 6)
            }
        }
        .frame(height: 6)
    }
    
    private var dotIndicator: some View {
        HStack(spacing: 6) {
            StatusDot(color: level.color, size: 10)
            if showLabel {
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(level.color)
            }
        }
    }
    
    private var textIndicator: some View {
        HStack(spacing: 4) {
            Text("\(Int(percentage * 100))%")
                .font(.captionMedium)
                .foregroundColor(level.color)
            Text("full")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
    }
}

// MARK: - Status Dot
struct StatusDot: View {
    let color: Color
    var size: CGFloat = 8
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

// MARK: - Occupancy Level
enum OccupancyLevel {
    case low
    case medium
    case high
    
    var color: Color {
        switch self {
        case .low:
            return .occupancyLow
        case .medium:
            return .occupancyMedium
        case .high:
            return .occupancyHigh
        }
    }
}

// MARK: - Live Occupancy Badge
struct LiveOccupancyBadge: View {
    let occupancy: Int
    let capacity: Int
    
    private var percentage: Double {
        guard capacity > 0 else { return 0 }
        return Double(occupancy) / Double(capacity)
    }
    
    private var level: OccupancyLevel {
        switch percentage {
        case 0..<0.5:
            return .low
        case 0.5..<0.8:
            return .medium
        default:
            return .high
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Pulsing dot
            PulsingDot(color: level.color)
            
            Text("LIVE")
                .font(.captionMedium)
                .foregroundColor(level.color)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(level.color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Pulsing Dot
struct PulsingDot: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 12, height: 12)
                .scaleEffect(isPulsing ? 1.5 : 1.0)
            
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Preview
#Preview("Occupancy Indicator") {
    ScrollView {
        VStack(spacing: 24) {
            Group {
                Text("Full Style")
                    .font(.headline)
                OccupancyIndicator(occupancy: 30, capacity: 100, style: .full)
                OccupancyIndicator(occupancy: 65, capacity: 100, style: .full)
                OccupancyIndicator(occupancy: 90, capacity: 100, style: .full)
            }
            
            Divider()
            
            Group {
                Text("Compact Style")
                    .font(.headline)
                OccupancyIndicator(occupancy: 45, capacity: 100, style: .compact)
                    .frame(width: 200)
            }
            
            Divider()
            
            Group {
                Text("Dot Style")
                    .font(.headline)
                HStack(spacing: 20) {
                    OccupancyIndicator(occupancy: 30, capacity: 100, style: .dot)
                    OccupancyIndicator(occupancy: 65, capacity: 100, style: .dot)
                    OccupancyIndicator(occupancy: 90, capacity: 100, style: .dot)
                }
            }
            
            Divider()
            
            Group {
                Text("Live Badge")
                    .font(.headline)
                HStack(spacing: 16) {
                    LiveOccupancyBadge(occupancy: 30, capacity: 100)
                    LiveOccupancyBadge(occupancy: 65, capacity: 100)
                    LiveOccupancyBadge(occupancy: 90, capacity: 100)
                }
            }
        }
        .padding()
    }
}

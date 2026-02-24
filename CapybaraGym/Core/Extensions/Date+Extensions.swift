//
//  Date+Extensions.swift
//  CapybaraGym
//
//  Date extensions for common operations
//

import Foundation

// MARK: - Formatting Extensions
public extension Date {
    
    /// Format date with custom format
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    /// Format as short date (e.g., "Jan 1, 2024")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Format as medium date (e.g., "January 1, 2024")
    var mediumDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Format as long date (e.g., "Monday, January 1, 2024")
    var longDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Format as short time (e.g., "3:30 PM")
    var shortTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Format as short date and time
    var shortDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Format as relative time (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Format as time ago
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents(
            [.year, .month, .weekOfYear, .day, .hour, .minute, .second],
            from: self,
            to: now
        )
        
        if let year = components.year, year > 0 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        if let month = components.month, month > 0 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        if let week = components.weekOfYear, week > 0 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        }
        if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        if let second = components.second, second > 5 {
            return "\(second) seconds ago"
        }
        return "Just now"
    }
}

// MARK: - Component Extensions
public extension Date {
    
    /// Get year
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    /// Get month
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    /// Get day
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// Get hour
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// Get minute
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// Get weekday (1 = Sunday, 7 = Saturday)
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    /// Get weekday name
    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    /// Get month name
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }
    
    /// Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /// Get end of day
    var endOfDay: Date {
        let components = DateComponents(day: 1, second: -1)
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Get start of month
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    /// Get end of month
    var endOfMonth: Date {
        let components = DateComponents(month: 1, day: -1)
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }
}

// MARK: - Calculation Extensions
public extension Date {
    
    /// Add days
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Add hours
    func adding(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    /// Add minutes
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    /// Add months
    func adding(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// Add years
    func adding(years: Int) -> Date {
        return Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    /// Days between dates
    func daysBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
    
    /// Hours between dates
    func hoursBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: self, to: date)
        return components.hour ?? 0
    }
    
    /// Minutes between dates
    func minutesBetween(_ date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self, to: date)
        return components.minute ?? 0
    }
    
    /// Check if same day
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    /// Check if today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Check if yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if tomorrow
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    /// Check if in past
    var isPast: Bool {
        return self < Date()
    }
    
    /// Check if in future
    var isFuture: Bool {
        return self > Date()
    }
    
    /// Check if within last 7 days
    var isWithinLastWeek: Bool {
        let weekAgo = Date().adding(days: -7)
        return self >= weekAgo && self <= Date()
    }
    
    /// Check if within last 30 days
    var isWithinLastMonth: Bool {
        let monthAgo = Date().adding(days: -30)
        return self >= monthAgo && self <= Date()
    }
}

// MARK: - Static Properties
public extension Date {
    
    /// Current timestamp
    static var timestamp: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// Current timestamp as string
    static var timestampString: String {
        return String(Int(timestamp))
    }
}

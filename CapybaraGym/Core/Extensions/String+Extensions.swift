//
//  String+Extensions.swift
//  CapybaraGym
//
//  String extensions for common operations
//

import Foundation

// MARK: - Validation Extensions
public extension String {
    
    /// Check if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Check if string is a valid phone number (US format)
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    /// Check if string is a valid password (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: self)
    }
    
    /// Check if string contains only numbers
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    /// Check if string is not empty after trimming
    var isNotEmptyTrimmed: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty
    }
    
    /// Check if string is empty after trimming
    var isEmptyTrimmed: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Formatting Extensions
public extension String {
    
    /// Format as phone number (US format)
    func formattedPhoneNumber() -> String {
        let cleanNumber = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let length = cleanNumber.count
        
        guard length > 0 else { return "" }
        
        if length <= 3 {
            return cleanNumber
        } else if length <= 6 {
            let index = cleanNumber.index(cleanNumber.startIndex, offsetBy: 3)
            return "(\(cleanNumber[..<index])) \(cleanNumber[index...])"
        } else if length <= 10 {
            let areaCodeEnd = cleanNumber.index(cleanNumber.startIndex, offsetBy: 3)
            let prefixEnd = cleanNumber.index(cleanNumber.startIndex, offsetBy: 6)
            return "(\(cleanNumber[..<areaCodeEnd])) \(cleanNumber[areaCodeEnd..<prefixEnd])-\(cleanNumber[prefixEnd...])"
        } else {
            let countryCodeEnd = cleanNumber.index(cleanNumber.startIndex, offsetBy: length - 10)
            let areaCodeEnd = cleanNumber.index(countryCodeEnd, offsetBy: 3)
            let prefixEnd = cleanNumber.index(countryCodeEnd, offsetBy: 6)
            return "+\(cleanNumber[..<countryCodeEnd]) (\(cleanNumber[countryCodeEnd..<areaCodeEnd])) \(cleanNumber[areaCodeEnd..<prefixEnd])-\(cleanNumber[prefixEnd...])"
        }
    }
    
    /// Mask email (e.g., j***@example.com)
    func maskedEmail() -> String {
        guard isValidEmail else { return self }
        
        let components = split(separator: "@")
        guard components.count == 2 else { return self }
        
        let localPart = String(components[0])
        let domain = String(components[1])
        
        let maskedLocal: String
        if localPart.count <= 2 {
            maskedLocal = String(repeating: "*", count: localPart.count)
        } else {
            let firstChar = localPart.prefix(1)
            let lastChar = localPart.suffix(1)
            maskedLocal = "\(firstChar)\(String(repeating: "*", count: localPart.count - 2))\(lastChar)"
        }
        
        return "\(maskedLocal)@\(domain)"
    }
    
    /// Truncate string with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        if count > length {
            return String(prefix(length)) + trailing
        }
        return self
    }
    
    /// Convert to title case
    func titleCase() -> String {
        return self
            .replacingOccurrences(of: "([A-Z])", with: " $1", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
            .capitalized
    }
}

// MARK: - Utility Extensions
public extension String {
    
    /// Check if not empty
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /// Get initials from name
    var initials: String {
        let components = self.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    /// Remove all whitespace
    func removingWhitespace() -> String {
        return replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
    }
    
    /// Remove special characters
    func removingSpecialCharacters() -> String {
        return components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }
    
    /// Convert to URL
    var url: URL? {
        return URL(string: self)
    }
    
    /// Convert to Date with format
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }
    
    /// Localized string
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Localized with format
    func localized(_ arguments: CVarArg...) -> String {
        return String(format: localized, arguments: arguments)
    }
}

// MARK: - HTML Extensions
public extension String {
    
    /// Strip HTML tags
    func strippingHTML() -> String {
        return self.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    /// Decode HTML entities
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) else {
            return self
        }
        
        return attributedString.string
    }
}

// MARK: - Data Extensions
public extension String {
    
    /// Convert to Data
    var data: Data? {
        return self.data(using: .utf8)
    }
    
    /// Base64 encode
    var base64Encoded: String? {
        return data?.base64EncodedString()
    }
    
    /// Base64 decode
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

//
//  ViewState.swift
//  CapybaraGym
//
//  View state management for MVVM architecture
//

import Foundation

// MARK: - View State Enum
public enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case error(Error)
    
    /// Check if loading
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    /// Check if success
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    /// Check if error
    public var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    /// Get success value
    public var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    /// Get error
    public var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}

// MARK: - Loading State
public enum LoadingState {
    case idle
    case loading
    case loaded
    case error(Error)
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// MARK: - Async State
@MainActor
public class AsyncState<T>: ObservableObject {
    @Published public private(set) var state: ViewState<T> = .idle
    
    public init() {}
    
    public func setLoading() {
        state = .loading
    }
    
    public func setSuccess(_ value: T) {
        state = .success(value)
    }
    
    public func setError(_ error: Error) {
        state = .error(error)
    }
    
    public func reset() {
        state = .idle
    }
}

// MARK: - Paginated State
@MainActor
public class PaginatedState<T>: ObservableObject {
    @Published public private(set) var items: [T] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var isLoadingMore = false
    @Published public private(set) var hasMorePages = true
    @Published public private(set) var error: Error?
    
    private var currentPage = 0
    private let pageSize: Int
    
    public init(pageSize: Int = 20) {
        self.pageSize = pageSize
    }
    
    public func reset() {
        items = []
        currentPage = 0
        hasMorePages = true
        error = nil
    }
    
    public func setLoading() {
        if items.isEmpty {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        error = nil
    }
    
    public func appendItems(_ newItems: [T]) {
        isLoading = false
        isLoadingMore = false
        items.append(contentsOf: newItems)
        currentPage += 1
        hasMorePages = newItems.count >= pageSize
    }
    
    public func setError(_ error: Error) {
        isLoading = false
        isLoadingMore = false
        self.error = error
    }
    
    public var shouldLoadMore: Bool {
        !isLoading && !isLoadingMore && hasMorePages
    }
}

// MARK: - Form State
@MainActor
public class FormState: ObservableObject {
    @Published public var isSubmitting = false
    @Published public var isValid = false
    @Published public var errors: [String: String] = [:]
    @Published public var generalError: String?
    
    public init() {}
    
    public func setFieldError(_ error: String, for field: String) {
        errors[field] = error
        validate()
    }
    
    public func clearFieldError(for field: String) {
        errors.removeValue(forKey: field)
        validate()
    }
    
    public func getError(for field: String) -> String? {
        errors[field]
    }
    
    public func hasError(for field: String) -> Bool {
        errors[field] != nil
    }
    
    public func setGeneralError(_ error: String?) {
        generalError = error
    }
    
    public func setSubmitting(_ submitting: Bool) {
        isSubmitting = submitting
    }
    
    public func validate() {
        isValid = errors.isEmpty
    }
    
    public func reset() {
        isSubmitting = false
        isValid = false
        errors = [:]
        generalError = nil
    }
}

// MARK: - View State Extensions
public extension ViewState {
    
    /// Map the success value to a new type
    func map<U>(_ transform: (T) -> U) -> ViewState<U> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .success(let value):
            return .success(transform(value))
        case .error(let error):
            return .error(error)
        }
    }
    
    /// Flat map the success value
    func flatMap<U>(_ transform: (T) -> ViewState<U>) -> ViewState<U> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .success(let value):
            return transform(value)
        case .error(let error):
            return .error(error)
        }
    }
}

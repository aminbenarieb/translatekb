import Foundation

/// Tracks how many translations the user has run this month. Resets on month
/// boundary. Lives in the App Group so the keyboard increments it and the main
/// app displays it.
public final class UsageCounter: @unchecked Sendable {
    private let storage: AppGroupStorage
    private let calendar = Calendar(identifier: .gregorian)

    public init(storage: AppGroupStorage = .shared) {
        self.storage = storage
    }

    /// Increment the counter, rolling over to a new month when needed. Returns
    /// the new count for this month.
    @discardableResult
    public func increment(provider: String, now: Date = Date()) -> Int {
        rolloverIfNeeded(now: now)
        let next = storage.usageCount + 1
        storage.usageCount = next
        storage.lastUsedProvider = provider
        return next
    }

    public func currentCount(now: Date = Date()) -> Int {
        rolloverIfNeeded(now: now)
        return storage.usageCount
    }

    private func rolloverIfNeeded(now: Date) {
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        if storage.usageMonthStart != startOfMonth {
            storage.usageMonthStart = startOfMonth
            storage.usageCount = 0
        }
    }
}

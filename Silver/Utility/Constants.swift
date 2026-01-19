import Foundation

struct Constants {
    static let defaultCurrency = "USD"
    static let appVersion = "1.0 (MVP)"
    static let refreshInterval: TimeInterval = 60  // seconds for auto-refresh of prices
    static let defaultSpotPrice: Double = 92.50   // fallback if API fails
}

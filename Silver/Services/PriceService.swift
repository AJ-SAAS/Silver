import Foundation
import SwiftUI
import Combine

final class PriceService: ObservableObject {
    
    // MARK: - Published state
    @Published var currentSpot: Double = 0.0
    @Published var previousSpot: Double = 0.0
    @Published var changePercentToday: Double = 0.0
    @Published var goldSilverRatio: Double = 0.0
    @Published var lastUpdate = Date()
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    // Future: for sparkline graph
    @Published var historicalSpots: [Date: Double] = [:]
    
    // MARK: - Offline cache
    private let lastSpotKey = "LastSpotPrice"
    private let lastUpdateKey = "LastSpotDate"
    
    private var endpoint: String {
        let apiKey = Secrets.metalPriceAPIKey
        return "https://api.metalpriceapi.com/v1/latest?api_key=\(apiKey)&base=USD&currencies=XAG,XAU"
    }
    
    init() {
        // Load cached
        if let lastPrice = UserDefaults.standard.value(forKey: lastSpotKey) as? Double,
           let lastDate = UserDefaults.standard.value(forKey: lastUpdateKey) as? Date {
            currentSpot = lastPrice
            lastUpdate = lastDate
        }
        Task { await fetchLatestPrices() }
    }
    
    func fetchLatestPrices() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: endpoint) else {
            await MainActor.run { errorMessage = "Invalid API URL"; isLoading = false }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success,
                  let rates = json["rates"] as? [String: Double],
                  let xagRate = rates["XAG"],
                  let xauRate = rates["XAU"]
            else {
                throw NSError(domain: "MetalpriceAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            await MainActor.run {
                let newSpot = 1 / xagRate  // Correct: USD per oz
                previousSpot = currentSpot
                currentSpot = newSpot
                
                let goldSpot = 1 / xauRate
                goldSilverRatio = goldSpot / newSpot  // Correct ratio
                
                changePercentToday = previousSpot > 0 ? ((newSpot - previousSpot) / previousSpot) * 100 : 0
                
                lastUpdate = Date()
                errorMessage = nil
                
                UserDefaults.standard.set(currentSpot, forKey: lastSpotKey)
                UserDefaults.standard.set(lastUpdate, forKey: lastUpdateKey)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch prices: \(error.localizedDescription)"
            }
            print("❌ PriceService fetch error:", error)
        }
        
        isLoading = false
    }
    
    var lastUpdateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last update " + formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}

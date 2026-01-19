import Foundation
import SwiftUI

@Observable
final class PriceService {
    
    // MARK: - Published state
    var currentSpot: Double = 92.50
    var changePercentToday: Double = 0.0
    var goldSilverRatio: Double = 80.0
    var lastUpdate = Date()
    var errorMessage: String?
    var isLoading = false
    
    // MARK: - Offline cache
    private let lastSpotKey = "LastSpotPrice"
    private let lastUpdateKey = "LastSpotDate"
    
    private var endpoint: String {
        let apiKey = Secrets.metalPriceAPIKey
        return "https://api.metalpriceapi.com/v1/latest?api_key=\(apiKey)&base=USD&currencies=XAG,XAU"
    }
    
    init() {
        // Load cached price if available
        if let lastPrice = UserDefaults.standard.value(forKey: lastSpotKey) as? Double,
           let lastDate = UserDefaults.standard.value(forKey: lastUpdateKey) as? Date {
            currentSpot = lastPrice
            lastUpdate = lastDate
        }
        Task { await fetchLatestPrices() }
    }
    
    // MARK: - Fetch latest prices
    func fetchLatestPrices() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: endpoint) else {
            await MainActor.run {
                errorMessage = "Invalid API URL"
                isLoading = false
            }
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool, success,
                  let rates = json["rates"] as? [String: Double],
                  let silverRate = rates["XAG"],
                  let goldRate = rates["XAU"]
            else {
                throw NSError(domain: "MetalpriceAPI", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            await MainActor.run {
                changePercentToday = ((silverRate - currentSpot) / currentSpot) * 100
                currentSpot = silverRate
                goldSilverRatio = goldRate / silverRate
                lastUpdate = Date()
                errorMessage = nil
                
                // Cache latest price
                UserDefaults.standard.set(currentSpot, forKey: lastSpotKey)
                UserDefaults.standard.set(lastUpdate, forKey: lastUpdateKey)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to fetch prices: \(error.localizedDescription)"
            }
            print("❌ PriceService fetch error:", error)
        }
        
        await MainActor.run { isLoading = false }
    }
    
    // MARK: - Last update string
    var lastUpdateString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last update " + formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}

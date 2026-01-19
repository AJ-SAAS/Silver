import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var currentSpot: Double = 92.50
    @Published var previousSpot: Double = 92.50
    @Published var changePercentToday: Double = 0.0
    @Published var goldSilverRatio: Double = 80.0
    @Published var lastUpdate: Date = Date()
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private var timer: Timer?

    private var apiKey: String {
        Secrets.metalPriceAPIKey
    }

    init() {
        Task { await fetchLatestPrices() }
        startAutoRefresh()
    }

    deinit {
        timer?.invalidate()
    }

    private func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { await self?.fetchLatestPrices() }
        }
    }

    func fetchLatestPrices() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let urlString = "https://api.metalpriceapi.com/v1/latest?api_key=\(apiKey)&base=USD&currencies=XAG,XAU"

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
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
                throw NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
            }

            previousSpot = currentSpot
            currentSpot = xagRate
            goldSilverRatio = xauRate / xagRate
            changePercentToday = ((currentSpot - previousSpot) / previousSpot) * 100
            lastUpdate = Date()

            // Optional: cache to UserDefaults
            UserDefaults.standard.set(currentSpot, forKey: "LastSpotPrice")
            UserDefaults.standard.set(lastUpdate, forKey: "LastSpotDate")

        } catch {
            errorMessage = "Failed to load prices: \(error.localizedDescription)"
            print("❌ HomeViewModel fetchLatestPrices error:", error)
        }

        isLoading = false
    }

    var lastUpdateDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last update " + formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}

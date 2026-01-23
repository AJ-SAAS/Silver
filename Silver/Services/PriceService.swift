import Foundation
import SwiftUI
import Combine

final class PriceService: ObservableObject {

    @Published var currentSpot: Double = 0.0
    @Published var changePercentToday: Double = 0.0
    @Published var goldSilverRatio: Double = 0.0
    @Published var lastUpdate: Date = Date()
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    @Published var historicalSpots: [Date: Double] = [:]

    private let lastSpotKey       = "LastSpotPrice"
    private let lastUpdateKey     = "LastSpotDate"
    private let previousSpotKey   = "PreviousSpotPrice"

    private var previousSpot: Double = 0.0

    private let apiHost = "yh-finance.p.rapidapi.com"
    private let apiKey  = Secrets.rapidApiYahooKey

    init() {
        loadCachedData()
        Task { await fetchLatestPrices() }
    }

    private func loadCachedData() {
        let defaults = UserDefaults.standard
        if let price = defaults.value(forKey: lastSpotKey) as? Double,
           let date  = defaults.value(forKey: lastUpdateKey) as? Date,
           let prev  = defaults.value(forKey: previousSpotKey) as? Double {
            currentSpot   = price
            lastUpdate    = date
            previousSpot  = prev
        }
    }

    func fetchLatestPrices() async {
        isLoading = true
        errorMessage = nil

        var components = URLComponents(string: "https://\(apiHost)/market/v2/get-quotes")!
        components.queryItems = [
            .init(name: "symbols", value: "XAG=X,XAU=X"),
            .init(name: "region",  value: "US")
        ]

        guard let url = components.url else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(apiKey,  forHTTPHeaderField: "X-RapidAPI-Key")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // ── DEBUG LOGGING ──
            print("Quotes URL requested: \(url.absoluteString)")
            if let httpResponse = response as? HTTPURLResponse {
                print("Quotes HTTP status: \(httpResponse.statusCode)")
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let truncated = jsonString.prefix(2000)
                print("RAW QUOTES JSON RESPONSE (first 2000 chars):\n\(truncated)")
                if jsonString.count > 2000 {
                    print("... (response truncated; full length: \(jsonString.count) chars)")
                }
            } else {
                print("Failed to decode quotes response as UTF-8")
            }
            // ── END DEBUG ──

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let quoteResponse = json["quoteResponse"] as? [String: Any],
                  let results = quoteResponse["result"] as? [[String: Any]] else {
                throw NSError(domain: "Yahoo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response structure"])
            }

            guard let silver = results.first(where: { ($0["symbol"] as? String) == "XAG=X" }),
                  let gold   = results.first(where: { ($0["symbol"] as? String) == "XAU=X" }),
                  let silverPrice = silver["regularMarketPrice"] as? Double,
                  let goldPrice   = gold["regularMarketPrice"]   as? Double else {
                throw NSError(domain: "Yahoo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing price data for XAG=X or XAU=X"])
            }

            // Prefer official daily change percent
            if let officialChange = silver["regularMarketChangePercent"] as? Double {
                changePercentToday = officialChange
            } else {
                changePercentToday = previousSpot > 0 ? ((silverPrice - previousSpot) / previousSpot) * 100 : 0
            }

            previousSpot     = currentSpot
            currentSpot      = silverPrice
            goldSilverRatio  = goldPrice / silverPrice
            lastUpdate       = Date()

            let defaults = UserDefaults.standard
            defaults.set(currentSpot,     forKey: lastSpotKey)
            defaults.set(lastUpdate,      forKey: lastUpdateKey)
            defaults.set(previousSpot,    forKey: previousSpotKey)

            print("✅ Silver: $\(silverPrice), Ratio: \(goldSilverRatio), Change: \(changePercentToday)%")

            await fetchHistorical()

        } catch {
            errorMessage = "Failed to fetch: \(error.localizedDescription)"
            print("❌ Fetch error: \(error)")
        }

        isLoading = false
    }

    private func fetchHistorical() async {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let end   = Int(now.timeIntervalSince1970)
        let start = Int(sevenDaysAgo.timeIntervalSince1970)

        var components = URLComponents(string: "https://\(apiHost)/stock/v2/get-chart")!
        components.queryItems = [
            .init(name: "symbol",   value: "XAG=X"),
            .init(name: "period1",  value: String(start)),
            .init(name: "period2",  value: String(end)),
            .init(name: "interval", value: "1d"),
            .init(name: "region",   value: "US")
        ]

        guard let url = components.url else {
            print("❌ Invalid historical URL")
            historicalSpots = mockHistoricalData()
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiHost, forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue(apiKey,  forHTTPHeaderField: "X-RapidAPI-Key")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // ── DEBUG LOGGING ──
            if let httpResponse = response as? HTTPURLResponse {
                print("Chart HTTP status: \(httpResponse.statusCode)")
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                let truncated = jsonString.prefix(2000)
                print("RAW CHART JSON RESPONSE (first 2000 chars):\n\(truncated)")
                if jsonString.count > 2000 {
                    print("... (chart response truncated; full length: \(jsonString.count) chars)")
                }
            } else {
                print("Failed to decode chart response as UTF-8")
            }
            // ── END DEBUG ──

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let chart = json["chart"] as? [String: Any],
                  let resultArray = chart["result"] as? [[String: Any]],
                  let result = resultArray.first,
                  let timestamps = result["timestamp"] as? [Double],
                  let indicators = result["indicators"] as? [String: Any],
                  let quoteArray = indicators["quote"] as? [[String: Any]],
                  let quote = quoteArray.first,
                  let closes = quote["close"] as? [Double?] else {
                throw NSError(domain: "Historical", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON structure"])
            }

            var temp: [Date: Double] = [:]
            for (index, timestamp) in timestamps.enumerated() {
                if let closePrice = closes[index] {
                    let date = Date(timeIntervalSince1970: timestamp)
                    temp[date] = closePrice
                }
            }

            historicalSpots = temp
            print("✅ Historical loaded via RapidAPI: \(temp.count) points")

        } catch {
            print("❌ Historical fetch failed: \(error.localizedDescription)")
            historicalSpots = mockHistoricalData()
        }
    }

    private func mockHistoricalData() -> [Date: Double] {
        let now = Date()
        var mock: [Date: Double] = [:]
        for i in 0..<7 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: now)!
            mock[date] = 32.0 + Double.random(in: -1.5...1.5)
        }
        return mock
    }
}

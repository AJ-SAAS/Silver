import Foundation
import SwiftUI
import Combine

@preconcurrency @MainActor
final class HomeViewModel: ObservableObject {

    @Published var currentSpot: Double = 0.0
    @Published var changePercentToday: Double = 0.0
    @Published var goldSilverRatio: Double = 0.0
    @Published var lastUpdate: Date = Date()
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let priceService: PriceService

    // ← Added default = PriceService() so no need to pass it explicitly in SilverApp
    init(priceService: PriceService = PriceService()) {
        self.priceService = priceService

        priceService.$currentSpot.assign(to: &$currentSpot)
        priceService.$changePercentToday.assign(to: &$changePercentToday)
        priceService.$goldSilverRatio.assign(to: &$goldSilverRatio)
        priceService.$lastUpdate.assign(to: &$lastUpdate)
        priceService.$errorMessage.assign(to: &$errorMessage)
        priceService.$isLoading.assign(to: &$isLoading)

        Task { await priceService.fetchLatestPrices() }
    }

    func refreshPrices() async {
        await priceService.fetchLatestPrices()
    }

    var historicalSpots: [Date: Double] {
        priceService.historicalSpots
    }

    var lastUpdateDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last update " + formatter.localizedString(for: lastUpdate, relativeTo: Date())
    }
}

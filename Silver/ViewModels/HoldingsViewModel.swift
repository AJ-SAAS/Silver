import Foundation
import Combine
import FirebaseAuth

@MainActor
final class HoldingsViewModel: ObservableObject {

    @Published var holdings: [SilverItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastLoadedDate: Date?

    private let service: HoldingsServiceProtocol
    private var userId: String? { Auth.auth().currentUser?.uid }

    init(service: HoldingsServiceProtocol = HoldingsService()) {
        self.service = service
        
        // Fixed: Explicitly mark Task as @MainActor to satisfy concurrency checker
        Task { @MainActor in
            await loadHoldings()
        }
    }

    // Computed properties
    var totalOunces: Double {
        holdings.reduce(0) { $0 + $1.totalWeight }
    }

    var totalHoldingsCount: Int {
        holdings.count
    }

    func totalCurrentValue(spot: Double) -> Double {
        holdings.reduce(0) { $0 + $1.currentValue(currentSpot: spot) }
    }

    func totalUnrealizedPL(spot: Double) -> Double? {
        let pls = holdings.compactMap { $0.unrealizedPL(currentSpot: spot) }
        guard !pls.isEmpty else { return nil }
        return pls.reduce(0, +)
    }

    // Data loading & modification
    func loadHoldings() async {
        guard let userId = userId else {
            errorMessage = "User not signed in. Please log in to view your holdings."
            print("❌ No user ID - check Firebase Auth")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            holdings = try await service.fetchHoldings(for: userId)
            lastLoadedDate = Date()
            print("✅ Loaded \(holdings.count) holdings for user \(userId)")
        } catch {
            errorMessage = "Failed to load holdings: \(error.localizedDescription)"
            print("❌ loadHoldings error:", error.localizedDescription)
        }

        isLoading = false
    }

    func addItem(_ item: SilverItem) async {
        guard let userId = userId else {
            errorMessage = "User not signed in."
            return
        }

        do {
            try await service.addItem(item, for: userId)
            await loadHoldings()
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
        }
    }

    func deleteItem(_ item: SilverItem) async {
        guard let userId = userId else {
            errorMessage = "User not signed in."
            return
        }

        guard let itemId = item.id else {
            errorMessage = "Cannot delete: Missing ID"
            return
        }

        do {
            try await service.deleteItem(item, for: userId)
            await loadHoldings()
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }
}

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class HoldingsViewModel: ObservableObject {

    @Published var holdings: [SilverItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Optional: timestamp when data was last successfully loaded
    @Published var lastLoadedDate: Date?

    private let service: HoldingsServiceProtocol
    private var userId: String? { Auth.auth().currentUser?.uid }

    init(service: HoldingsServiceProtocol = HoldingsService()) {
        self.service = service
        Task { await loadHoldings() }
    }

    // ────────────────────────────────────────────────
    // Computed properties for Home screen & UI
    // ────────────────────────────────────────────────

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

    // ────────────────────────────────────────────────
    // Data loading & modification methods
    // ────────────────────────────────────────────────

    func loadHoldings() async {
        guard let userId = userId else {
            errorMessage = "User not signed in. Please log in to view your holdings."
            print("❌ No user ID - check Firebase Auth (currentUser is nil)")
            return
        }

        print("Loading holdings for user ID: \(userId)")

        isLoading = true
        errorMessage = nil

        do {
            holdings = try await service.fetchHoldings(for: userId)
            lastLoadedDate = Date()
            print("✅ Successfully loaded \(holdings.count) holdings for user \(userId)")
        } catch {
            errorMessage = "Failed to load holdings: \(error.localizedDescription)"
            print("❌ HoldingsViewModel loadHoldings error:", error.localizedDescription)
            print("Full error:", error)
        }

        isLoading = false
    }

    func addItem(_ item: SilverItem) async {
        guard let userId = userId else {
            errorMessage = "User not signed in. Please log in to add holdings."
            print("❌ Cannot add item: No user ID - check Firebase Auth")
            return
        }

        print("Adding new item for user ID: \(userId)")

        do {
            try await service.addItem(item, for: userId)
            print("✅ Item added successfully")
            await loadHoldings()  // refresh list
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
            print("❌ HoldingsViewModel addItem error:", error.localizedDescription)
            print("Full error:", error)
        }
    }

    func deleteItem(_ item: SilverItem) async {
        guard let userId = userId else {
            errorMessage = "User not signed in. Please log in to delete holdings."
            print("❌ Cannot delete item: No user ID - check Firebase Auth")
            return
        }

        guard let itemId = item.id else {
            errorMessage = "Cannot delete: Missing document ID"
            print("❌ Delete failed: Item has no ID")
            return
        }

        print("Deleting item ID \(itemId) for user ID: \(userId)")

        do {
            try await service.deleteItem(item, for: userId)
            print("✅ Item \(itemId) deleted successfully")
            await loadHoldings()  // refresh list
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
            print("❌ HoldingsViewModel deleteItem error:", error.localizedDescription)
            print("Full error:", error)
        }
    }
}

import Foundation
import FirebaseAuth

@MainActor
final class HoldingsViewModel: ObservableObject {

    @Published var holdings: [SilverItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let service: HoldingsServiceProtocol
    private var userId: String? { Auth.auth().currentUser?.uid }

    init(service: HoldingsServiceProtocol = HoldingsService()) {
        self.service = service
    }

    func loadHoldings() async {
        guard let userId = userId else {
            errorMessage = "User not signed in"
            return
        }
        isLoading = true
        errorMessage = nil

        do {
            holdings = try await service.fetchHoldings(for: userId)
        } catch {
            errorMessage = "Failed to load holdings"
            print("❌ HoldingsViewModel loadHoldings error:", error)
        }

        isLoading = false
    }

    func addItem(_ item: SilverItem) async {
        guard let userId = userId else { return }
        do {
            try await service.addItem(item, for: userId)
            await loadHoldings()
        } catch {
            errorMessage = "Failed to add item"
            print("❌ HoldingsViewModel addItem error:", error)
        }
    }

    func deleteItem(_ item: SilverItem) async {
        guard let userId = userId else { return }
        do {
            try await service.deleteItem(item, for: userId)
            await loadHoldings()
        } catch {
            errorMessage = "Failed to delete item"
            print("❌ HoldingsViewModel deleteItem error:", error)
        }
    }

    // Computed totals
    func totalStackValue(currentSpot: Double) -> Double {
        holdings.reduce(0) { $0 + $1.currentValue(currentSpot: currentSpot) }
    }

    func totalOunces() -> Double {
        holdings.reduce(0) { $0 + $1.totalWeight }
    }
}

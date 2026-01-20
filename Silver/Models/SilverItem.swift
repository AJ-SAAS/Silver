import Foundation
import FirebaseFirestore

struct SilverItem: Identifiable, Codable {
    @DocumentID var id: String?             // Firestore document ID (auto-generated on add)
    var type: String                        // e.g. "Coin", "Bar", "Round"
    var quantity: Double
    var weightPerUnit: Double               // in oz
    var purchasePricePerOz: Double?         // optional - for P/L calculation
    var premiumPaid: Double?                // optional - can be % or absolute, for future use
    
    var totalWeight: Double {
        quantity * weightPerUnit
    }
    
    func currentValue(currentSpot: Double) -> Double {
        totalWeight * currentSpot
    }
    
    func unrealizedPL(currentSpot: Double) -> Double? {
        guard let purchase = purchasePricePerOz else { return nil }
        return (currentSpot - purchase) * totalWeight
    }
}

import Foundation
import FirebaseFirestore

struct SilverItem: Identifiable, Codable {
    @DocumentID var id: String?      // Firestore document ID
    var type: String                 // "Coin" / "Bar" / "Round"
    var quantity: Double
    var weightPerUnit: Double        // in oz
    var purchasePricePerOz: Double?  // optional
    var premiumPaid: Double?         // optional %
    
    // Computed properties
    var totalWeight: Double {
        quantity * weightPerUnit
    }
    
    func currentValue(currentSpot: Double) -> Double {
        return totalWeight * currentSpot
    }
    
    func unrealizedPL(currentSpot: Double) -> Double? {
        guard let purchase = purchasePricePerOz else { return nil }
        return (currentSpot - purchase) * totalWeight
    }
}

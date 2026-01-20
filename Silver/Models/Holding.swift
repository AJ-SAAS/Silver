import Foundation

struct Holding: Identifiable, Codable {
    var id: UUID = UUID()  // make it var
    var type: String
    var quantity: Int
    var weightPerUnitOz: Double
    var purchasePricePerOz: Double?

    var totalOunces: Double {
        Double(quantity) * weightPerUnitOz
    }

    func currentValue(at spot: Double) -> Double {
        totalOunces * spot
    }

    func unrealizedPL(at spot: Double) -> Double? {
        guard let purchase = purchasePricePerOz else { return nil }
        return (spot - purchase) * totalOunces
    }
}

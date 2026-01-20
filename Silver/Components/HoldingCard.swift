import SwiftUI

struct HoldingCard: View {

    let item: SilverItem
    let currentSpot: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.type)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(item.totalWeight, format: .number.precision(.fractionLength(2))) oz")
                    .foregroundColor(.white.opacity(0.7))
            }

            if let unrealized = item.unrealizedPL(currentSpot: currentSpot) {
                Text("P/L: \(unrealized >= 0 ? "+" : "")\(unrealized, format: .currency(code: "USD"))")
                    .foregroundColor(unrealized >= 0 ? .green : .red)
                    .font(.subheadline)
            }

            Text("Current Value: \(item.currentValue(currentSpot: currentSpot), format: .currency(code: "USD"))")
                .foregroundColor(.white.opacity(0.8))
                .font(.subheadline)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

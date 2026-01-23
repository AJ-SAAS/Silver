import SwiftUI

struct HoldingCard: View {

    let item: SilverItem
    let currentSpot: Double

    private var value: Double { item.currentValue(currentSpot: currentSpot) }
    private var pl: Double? { item.unrealizedPL(currentSpot: currentSpot) }
    private var plPct: Double? {
        guard let p = pl, let purchase = item.purchasePricePerOz, purchase > 0 else { return nil }
        let cost = purchase * item.totalWeight
        return cost > 0 ? (value - cost) / cost * 100 : nil
    }

    private var plColor: Color {
        guard let pct = plPct else { return .gray }
        return pct >= 0 ? .green : .red
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: "cube.box.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(.white)
                .background(Circle().fill(Color.gray.opacity(0.4)))

            VStack(alignment: .leading, spacing: 4) {
                Text("Silver \(item.type)")
                    .font(.headline)
                    .foregroundColor(.white)

                Text("\(item.quantity, specifier: "%.0f") × \(item.weightPerUnit, specifier: "%.1f") oz")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(value, specifier: "%.2f")")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                if let pct = plPct {
                    HStack(spacing: 6) {
                        Text("\(pct >= 0 ? "+" : "")\(pct, specifier: "%.2f")%")
                            .font(.subheadline.bold())
                        Image(systemName: "triangle.fill")
                            .font(.caption)
                            .rotationEffect(.degrees(pct >= 0 ? 0 : 180))
                    }
                    .foregroundColor(plColor)
                } else {
                    Text("No P/L data")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

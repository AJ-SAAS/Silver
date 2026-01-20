import SwiftUI

struct HoldingCard: View {

    let item: SilverItem
    let currentSpot: Double

    private var currentValue: Double {
        item.currentValue(currentSpot: currentSpot)
    }

    private var unrealizedPL: Double? {
        item.unrealizedPL(currentSpot: currentSpot)
    }

    private var plPercent: Double? {
        guard let pl = unrealizedPL, let purchase = item.purchasePricePerOz, purchase > 0 else { return nil }
        let costBasis = purchase * item.totalWeight
        return costBasis > 0 ? (currentValue - costBasis) / costBasis * 100 : nil
    }

    private var plColor: Color {
        guard let percent = plPercent else { return .gray }
        return percent >= 0 ? .green : .red
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon
            Image(systemName: "cube.box.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(.white.opacity(0.9))
                .background(
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                )

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
                Text("$\(currentValue, specifier: "%.2f")")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                if let percent = plPercent {
                    HStack(spacing: 4) {
                        Text("\(percent >= 0 ? "+" : "")\(percent, specifier: "%.2f")%")
                            .font(.subheadline.bold())
                            .foregroundColor(plColor)

                        Image(systemName: "triangle.fill")
                            .font(.caption)
                            .foregroundColor(plColor)
                            .rotationEffect(.degrees(percent >= 0 ? 0 : 180))
                    }
                } else {
                    Text("No P/L")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.06))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

import SwiftUI

struct PriceCard: View {

    let spotPrice: Double
    let changePercent: Double
    let lastUpdate: String

    private var isUp: Bool { changePercent >= 0 }

    var body: some View {
        VStack(spacing: 18) {

            // Header row
            HStack(alignment: .firstTextBaseline) {
                Text("Silver Spot")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.65))

                Spacer()

                Text(lastUpdate)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
            }

            // Main price – bigger & bolder
            Text("$\(spotPrice, format: .number.precision(.fractionLength(2)))")
                .font(.system(size: 52, weight: .heavy, design: .rounded))
                .minimumScaleFactor(0.85)
                .foregroundColor(.white)

            // Change indicator
            HStack(spacing: 8) {
                Image(systemName: isUp ? "arrow.up.right" : "arrow.down.right.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                Text("\(changePercent, format: .percent.precision(.fractionLength(2)))")
                    .font(.title3.weight(.semibold))
            }
            .foregroundColor(isUp ? .green : .red)

        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
        )
    }
}

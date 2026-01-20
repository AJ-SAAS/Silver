import SwiftUI

struct PriceCard: View {

    let spotPrice: Double
    let changePercent: Double
    let goldSilverRatio: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("Silver Spot Price")
                .font(.headline)
                .foregroundColor(.white)
            Text("$\(spotPrice, format: .number.precision(.fractionLength(2)))")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.green)

            HStack {
                Text("Change Today:")
                Text("\(changePercent, format: .percent.precision(.fractionLength(2)))")
                    .foregroundColor(changePercent >= 0 ? .green : .red)
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))

            HStack {
                Text("Gold/Silver Ratio:")
                Text("\(goldSilverRatio, format: .number.precision(.fractionLength(2)))")
                    .foregroundColor(.yellow)
            }
            .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

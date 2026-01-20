import SwiftUI

struct QuickStatsGrid: View {

    @ObservedObject var homeVM: HomeViewModel

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {

            StatBox(title: "Last Update", value: homeVM.lastUpdateDisplay)
            StatBox(title: "Gold/Silver", value: String(format: "%.2f", homeVM.goldSilverRatio))
            StatBox(title: "Change Today", value: String(format: "%.2f%%", homeVM.changePercentToday))
            StatBox(title: "Spot Price", value: String(format: "$%.2f", homeVM.currentSpot))
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

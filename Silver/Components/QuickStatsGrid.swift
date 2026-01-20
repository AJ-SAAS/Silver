import SwiftUI

struct QuickStatsGrid: View {

    @ObservedObject var homeVM: HomeViewModel

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {

            StatBox(
                title: "Gold / Silver Ratio",
                value: String(format: "%.2f", homeVM.goldSilverRatio)
            )

            StatBox(
                title: "Change Today",
                value: String(format: "%.2f%%", homeVM.changePercentToday)
            )

            StatBox(
                title: "Last Update",
                value: homeVM.lastUpdateDisplay
            )
        }
    }
}

// MARK: - Local Stat Card

private struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }
}

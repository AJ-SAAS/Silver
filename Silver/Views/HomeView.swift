import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var holdingsVM: HoldingsViewModel
    
    @Binding var selectedTab: TabBarView.Tab

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // HERO PRICE
                PriceCard(
                    spotPrice: homeVM.currentSpot,
                    changePercent: homeVM.changePercentToday,
                    lastUpdate: homeVM.lastUpdateDisplay
                )

                // YOUR STACK VALUE + P/L – tappable
                StackValueCard(
                    viewModel: holdingsVM,
                    spotPrice: homeVM.currentSpot,
                    isLoading: holdingsVM.isLoading
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedTab = .holdings
                    }
                }

                // MARKET CONTEXT
                QuickStatsGrid(homeVM: homeVM)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
        .background(AppBackground())
        .refreshable {
            await homeVM.refreshPrices()  // Use public method (add this to HomeViewModel)
            await holdingsVM.loadHoldings()
        }
        .task {
            await homeVM.refreshPrices()  // Initial load
            await holdingsVM.loadHoldings()
        }
    }
}

// MARK: - Stack Value Card (unchanged)
private struct StackValueCard: View {
    
    @ObservedObject var viewModel: HoldingsViewModel
    let spotPrice: Double
    let isLoading: Bool

    private var currentValue: Double {
        viewModel.totalCurrentValue(spot: spotPrice)
    }

    private var unrealizedPL: Double? {
        viewModel.totalUnrealizedPL(spot: spotPrice)
    }

    private var plColor: Color {
        guard let pl = unrealizedPL else { return .gray }
        return pl >= 0 ? .green : .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Silver Stack")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))

            if isLoading {
                ProgressView().tint(.white).padding(.vertical, 8)
            } else if viewModel.holdings.isEmpty {
                HStack {
                    Text("No holdings yet – tap to add")
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 8)
            } else {
                Text("$\(currentValue, format: .number.precision(.fractionLength(2)))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)

                if let pl = unrealizedPL {
                    HStack(spacing: 6) {
                        Image(systemName: pl >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(pl >= 0 ? "+" : "")\(pl, format: .number.precision(.fractionLength(2))) unrealized")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(plColor)
                } else {
                    Text("Add purchase prices to see P/L")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Text("\(viewModel.totalOunces, format: .number.precision(.fractionLength(2))) oz total")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.08), .white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Background
private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.08, blue: 0.14),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

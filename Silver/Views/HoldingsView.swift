import SwiftUI
import Charts

struct HoldingsView: View {

    @EnvironmentObject var holdingsVM: HoldingsViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var showingAddItem = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // Total Value + P/L
                    VStack(spacing: 12) {
                        Text("Total Stack Value")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                        Text("$\(holdingsVM.totalCurrentValue(spot: homeVM.currentSpot), specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        if let pl = holdingsVM.totalUnrealizedPL(spot: homeVM.currentSpot) {
                            let totalValue = holdingsVM.totalCurrentValue(spot: homeVM.currentSpot)
                            if totalValue > 0 {
                                let plPct = (pl / totalValue) * 100
                                HStack(spacing: 8) {
                                    Image(systemName: pl >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.title3)
                                    Text("\(pl >= 0 ? "+" : "")\(pl, specifier: "%.2f")")
                                        .font(.title3.bold())
                                    Text("(\(plPct, specifier: "%.2f")%)")
                                        .font(.title3)
                                }
                                .foregroundColor(pl >= 0 ? .green : .red)
                            }
                        }
                    }
                    .padding(.top, 40)

                    // Sparkline
                    if !homeVM.historicalSpots.isEmpty {
                        Chart(homeVM.historicalSpots.sorted(by: { $0.key < $1.key }), id: \.key) { date, price in
                            LineMark(
                                x: .value("Date", date),
                                y: .value("Price", price)
                            )
                            .foregroundStyle(.white)
                            .interpolationMethod(.catmullRom)

                            AreaMark(
                                x: .value("Date", date),
                                y: .value("Price", price)
                            )
                            .foregroundStyle(.white.opacity(0.15))
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis(.hidden)
                        .frame(height: 100)
                        .padding(.horizontal)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(16)
                    } else if homeVM.isLoading {
                        ProgressView("Fetching price trend...")
                            .frame(height: 100)
                            .foregroundColor(.white)
                    } else {
                        Text("No trend data yet")
                            .foregroundColor(.gray)
                            .frame(height: 100)
                    }

                    // Add Holding button
                    Button {
                        showingAddItem = true
                    } label: {
                        Text("Add Holding")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.green)
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 40)

                    // Holdings list
                    VStack(spacing: 16) {
                        ForEach(holdingsVM.holdings) { item in
                            HoldingCard(item: item, currentSpot: homeVM.currentSpot)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 120)
            }
            .background(AppBackground())
            .navigationTitle("My Stack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .foregroundStyle(.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView { newItem in
                    Task { await holdingsVM.addItem(newItem) }
                    showingAddItem = false
                }
            }
        }
    }
}

// Background
private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.08, blue: 0.14),
                     Color(red: 0.10, green: 0.14, blue: 0.20)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

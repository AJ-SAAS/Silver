import SwiftUI

struct HoldingsView: View {

    @EnvironmentObject var holdingsVM: HoldingsViewModel
    @EnvironmentObject var homeVM: HomeViewModel
    @State private var showingAddItem = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                if let error = holdingsVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }

                if holdingsVM.holdings.isEmpty {
                    VStack(spacing: 8) {
                        Text("No holdings yet")
                            .foregroundColor(.white.opacity(0.7))
                        Text("Tap + to add your first silver item")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(holdingsVM.holdings) { item in
                                HoldingCard(item: item, currentSpot: homeVM.currentSpot)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Holdings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
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
            .background(
                LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.17),
                                        Color(red: 0.12, green: 0.16, blue: 0.23)],
                               startPoint: .top,
                               endPoint: .bottom)
                    .ignoresSafeArea()
            )
        }
    }
}

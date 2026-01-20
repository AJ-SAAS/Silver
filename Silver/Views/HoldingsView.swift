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
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }

                if holdingsVM.holdings.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("No holdings yet")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("Tap + to add your first silver item")
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(holdingsVM.holdings) { item in
                                HoldingCard(item: item, currentSpot: homeVM.currentSpot)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // avoid tab bar overlap
                    }
                }
            }
            .navigationTitle("My Stack")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundStyle(.white) // Title white
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 26))
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
            .background(AppBackground()) // Consistent dark gradient
        }
    }
}

// Reusable background (move to shared file later)
private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.08, blue: 0.14), Color(red: 0.10, green: 0.14, blue: 0.20)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

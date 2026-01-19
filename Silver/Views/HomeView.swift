import SwiftUI

struct HomeView: View {
    
    @StateObject private var priceService = PriceService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                
                // Header
                Text("Silver Spot Price")
                    .font(.title2.bold())
                    .padding(.top)
                
                // Price or loading/error
                if priceService.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else if let error = priceService.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        Text("$\(priceService.currentSpot, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("Change today: \(priceService.changePercentToday, specifier: "%.2f")%")
                            .font(.headline)
                            .foregroundColor(priceService.changePercentToday >= 0 ? .green : .red)
                        
                        Text("Gold:Silver ratio \(priceService.goldSilverRatio, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(priceService.lastUpdateString)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Refresh Button
                Button(action: {
                    Task { await priceService.fetchLatestPrices() }
                }) {
                    Text("Refresh Prices")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

            }
            .navigationTitle("Silver Dashboard")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

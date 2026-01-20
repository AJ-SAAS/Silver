import SwiftUI

struct HomeView: View {

    @EnvironmentObject var homeVM: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if let error = homeVM.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
                
                VStack(spacing: 16) {
                    PriceCard(spotPrice: homeVM.currentSpot,
                              changePercent: homeVM.changePercentToday,
                              goldSilverRatio: homeVM.goldSilverRatio)
                    
                    QuickStatsGrid(homeVM: homeVM)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .background(
            LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.17),
                                    Color(red: 0.12, green: 0.16, blue: 0.23)],
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()
        )
        .refreshable {
            await homeVM.fetchLatestPrices()
        }
    }
}

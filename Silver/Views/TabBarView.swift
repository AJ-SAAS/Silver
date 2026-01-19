import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case holdings
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.home)
            
            // MARK: Holdings Tab
            HoldingsView()
                .tabItem {
                    Label("My Stack", systemImage: "cube.box.fill")
                }
                .tag(Tab.holdings)
            
            // MARK: Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .accentColor(.blue) // Your brand color
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}

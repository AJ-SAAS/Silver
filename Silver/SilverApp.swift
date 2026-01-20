import SwiftUI
import FirebaseCore

@main
struct SilverApp: App {

    @StateObject private var authVM = AuthViewModel()
    @StateObject private var homeVM = HomeViewModel()
    @StateObject private var holdingsVM = HoldingsViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.user != nil {
                    TabBarView()
                } else {
                    AuthView()
                }
            }
            // ✅ Inject ONCE at the root
            .environmentObject(authVM)
            .environmentObject(homeVM)
            .environmentObject(holdingsVM)
        }
    }
}

import SwiftUI
import FirebaseCore

@main
@MainActor
struct SilverApp: App {

    @StateObject private var authVM = AuthViewModel()
    @StateObject private var homeVM = HomeViewModel()           // ← now works thanks to default in init
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
            .environmentObject(authVM)
            .environmentObject(homeVM)
            .environmentObject(holdingsVM)
        }
    }
}

import SwiftUI
import FirebaseCore

@main
struct SilverApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    @StateObject private var authVM = AuthViewModel()  // Persist across views
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    TabBarView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(authVM) // Child views can use @EnvironmentObject
        }
    }
}

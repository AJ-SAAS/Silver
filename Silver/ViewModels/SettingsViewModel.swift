import Foundation
import Combine
import FirebaseAuth

final class SettingsViewModel: ObservableObject {  // ← ObservableObject, not @Observable

    @Published var userEmail: String? = nil

    var authVM: AuthViewModel

    init(authVM: AuthViewModel) {
        self.authVM = authVM
        self.userEmail = Auth.auth().currentUser?.email
    }

    func signOut() {
        authVM.signOut()
    }
}

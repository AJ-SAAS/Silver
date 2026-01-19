import Foundation
import Combine
import FirebaseAuth

@Observable
final class SettingsViewModel {

    var userEmail: String? = nil
    
    private let authVM: AuthViewModel
    
    init(authVM: AuthViewModel) {
        self.authVM = authVM
        
        // Load current user email if available
        if let firebaseUser = Auth.auth().currentUser {
            userEmail = firebaseUser.email
        }
    }
    
    func signOut() {
        authVM.signOut()
    }
}

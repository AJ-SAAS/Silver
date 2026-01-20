import Foundation
import Combine
import FirebaseAuth

final class AuthViewModel: ObservableObject {

    @Published var user: AppUser?

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
        if let firebaseUser = service.currentUser {
            self.user = AppUser(user: firebaseUser)
        }
    }

    @MainActor
    func signIn(email: String, password: String) async {
        do {
            try await service.signIn(email: email, password: password)
            if let firebaseUser = service.currentUser {
                user = AppUser(user: firebaseUser)
            }
        } catch {
            print("❌ SignIn error:", error.localizedDescription)
        }
    }

    @MainActor
    func signUp(email: String, password: String) async {
        do {
            try await service.signUp(email: email, password: password)
            if let firebaseUser = service.currentUser {
                user = AppUser(user: firebaseUser)
            }
        } catch {
            print("❌ SignUp error:", error.localizedDescription)
        }
    }

    @MainActor
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            print("❌ SignOut failed:", error)
        }
    }
}

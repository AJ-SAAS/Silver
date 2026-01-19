import FirebaseAuth
import Combine
import Foundation

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var authStatePublisher: AnyPublisher<User?, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() throws
}

final class AuthService: AuthServiceProtocol, ObservableObject {
    
    @Published var currentUser: User? = Auth.auth().currentUser
    private let authStateSubject = CurrentValueSubject<User?, Never>(Auth.auth().currentUser)
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen to Firebase auth changes
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            self?.authStateSubject.send(user)
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    var authStatePublisher: AnyPublisher<User?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
        }
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        await MainActor.run {
            self.currentUser = result.user
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        currentUser = nil
    }
}

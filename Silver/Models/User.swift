import Foundation
import FirebaseAuth

struct AppUser: Identifiable, Codable {
    let id: String          // Firebase UID
    let email: String?
    let createdAt: Date?
    
    init(user: User) {
        self.id = user.uid
        self.email = user.email
        self.createdAt = user.metadata.creationDate
    }
}

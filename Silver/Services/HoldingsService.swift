import Foundation
import FirebaseFirestore

protocol HoldingsServiceProtocol {
    func fetchHoldings(for userId: String) async throws -> [SilverItem]
    func addItem(_ item: SilverItem, for userId: String) async throws
    func deleteItem(_ item: SilverItem, for userId: String) async throws
}

final class HoldingsService: HoldingsServiceProtocol {
    
    private let db = Firestore.firestore()
    
    func fetchHoldings(for userId: String) async throws -> [SilverItem] {
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("holdings")
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                try? doc.data(as: SilverItem.self)
            }
        } catch {
            print("❌ Firestore fetchHoldings error:", error)
            throw error
        }
    }
    
    func addItem(_ item: SilverItem, for userId: String) async throws {
        do {
            _ = try db.collection("users")
                .document(userId)
                .collection("holdings")
                .addDocument(from: item)
        } catch {
            print("❌ Firestore addItem error:", error)
            throw error
        }
    }
    
    func deleteItem(_ item: SilverItem, for userId: String) async throws {
        guard let id = item.id else {
            print("❌ deleteItem: item.id is nil")
            return
        }
        do {
            try await db.collection("users")
                .document(userId)
                .collection("holdings")
                .document(id)
                .delete()
        } catch {
            print("❌ Firestore deleteItem error:", error)
            throw error
        }
    }
}

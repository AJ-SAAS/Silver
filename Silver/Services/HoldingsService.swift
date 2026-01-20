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
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            try? doc.data(as: SilverItem.self)
        }
    }

    func addItem(_ item: SilverItem, for userId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .addDocument(from: item) // async Firestore call
    }

    func deleteItem(_ item: SilverItem, for userId: String) async throws {
        guard let id = item.id else {
            throw NSError(domain: "HoldingsService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing document ID"])
        }

        try await db.collection("users")
            .document(userId)
            .collection("holdings")
            .document(id)
            .delete()
    }
}

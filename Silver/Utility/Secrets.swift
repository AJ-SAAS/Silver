import Foundation

enum Secrets {
    static let metalPriceAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "METALPRICE_API_KEY") as? String else {
            fatalError("❌ METALPRICE_API_KEY missing. Check Info.plist or xcconfig setup")
        }
        return key
    }()
}

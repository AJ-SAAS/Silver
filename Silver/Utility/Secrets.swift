import Foundation

enum Secrets {
    static let rapidApiYahooKey: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "RAPIDAPI_YAHOO_KEY"   // ← this must match the key in Info.plist / .xcconfig
        ) as? String else {
            fatalError("❌ RAPIDAPI_YAHOO_KEY missing. Check Info.plist or .xcconfig setup")
        }
        return key
    }()
}

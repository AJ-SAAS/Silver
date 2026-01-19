import Foundation

enum Logger {
    static func log(_ message: String) {
        #if DEBUG
        print("🟦 [Silver] \(message)")
        #endif
    }
    
    static func error(_ message: String) {
        #if DEBUG
        print("❌ [Silver Error] \(message)")
        #endif
    }
}

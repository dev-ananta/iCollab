// Imports
import Foundation

final class PersistenceManager: Sendable  {
    // Lets
    static let shared = PersistenceManager()
    private let logFile = "session_log.txt" // Defined here

    // Private Initializer --> Enforce Singleton Pattern
    private init() {} 

    // Session Logging Function
    func logSession(code: String) {
        let timestamp = Date().description
        let entry = "[\(timestamp)] Host started session: \(code)\n"
        
        if let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(self.logFile) // Explicit self
            
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

            if let handle = try? FileHandle(forWritingTo: fileURL) {
                handle.seekToEndOfFile()
                try? handle.write(contentsOf: entry.data(using: .utf8)!)
                try? handle.close()
            } else {
                try? entry.write(to: fileURL, atomically: true, encoding: .utf8)
            }
        }
    }
}
// Imports
import Foundation

struct SessionManager {
    // Code Generation Logic
    static func generateCode() -> String {
        let ip = getLocalIPAddress() ?? "127.0.0.1"
        let components = ip.components(separatedBy: ".")
        if components.count == 4 {
            let suffix = components[2] + components[3]
            return String(suffix.suffix(6)).padding(toLength: 6, withPad: "0", startingAt: 0)
        }
        return "000000"
    }

    // IP Address Retrieval Logic
    static func getLocalIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            guard let interface = ptr?.pointee else { continue }
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                // FIXED: Modern C-String decoding for the interface name
                let name = String(decoding: Data(bytes: interface.ifa_name, count: Int(strlen(interface.ifa_name))), as: UTF8.self)
                
                if name == "en0" { 
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    
                    // FIXED: Modern C-String decoding for the hostname
                    address = String(decoding: Data(bytes: hostname, count: Int(strlen(hostname))), as: UTF8.self)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
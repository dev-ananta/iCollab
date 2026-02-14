// Imports
import Network
import Foundation
import SwiftUI

@MainActor
class NetworkManager: ObservableObject {
    // Variables
    private var connection: NWConnection?
    @Published var receivedImage: NSImage?
    @Published var isConnected = false

    // Start Hosting Function
    func startHosting() {
        do {
            let listener = try NWListener(using: .tcp, on: 8080)
            listener.newConnectionHandler = { [weak self] newConn in
                Task { @MainActor in
                    self?.connection = newConn
                    self?.setupConnection(newConn)
                }
            }
            listener.start(queue: .main)
        } catch { print(error) }
    }

    // Connect to Host Function
    func connect(to ip: String) {
        let host = NWEndpoint.Host(ip)
        let port = NWEndpoint.Port(integerLiteral: 8080)
        let conn = NWConnection(host: host, port: port, using: .tcp)
        self.connection = conn
        setupConnection(conn)
    }

    // Private Connection Setup Function
    private func setupConnection(_ conn: NWConnection) {
        conn.stateUpdateHandler = { [weak self] state in
            if case .ready = state {
                Task { @MainActor in
                    self?.isConnected = true
                    self?.receiveFrame()
                }
            }
        }
        conn.start(queue: .main)
    }

    // Frame Handling Functions:
    func receiveFrame() { // Frame Recieving Function
        // Capture connection locally so the closure doesn't have to keep 
        // asking 'self' for it on a background thread.
        guard let activeConnection = self.connection else { return }
        
        activeConnection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] data, _, _, error in
            // Check if self still exists and there's no error
            guard let self = self, let data = data, data.count == 4 else { return }
            
            let size = data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            
            // Now receive the actual image bytes
            activeConnection.receive(minimumIncompleteLength: Int(size), maximumLength: Int(size)) { [weak self] imgData, _, _, _ in
                guard let self = self, let imgData = imgData else { return }
                
                if let image = NSImage(data: imgData) {
                    // Update the UI on the Main Actor
                    Task { @MainActor in
                        self.receivedImage = image
                    }
                }
                
                // Recursively call receiveFrame to wait for the next image
                // We use Task to safely transition back to the MainActor-isolated method
                Task { @MainActor in
                    self.receiveFrame()
                }
            }
        }
    }

    func sendFrame(_ data: Data) { // Frame Sending Function
        guard let activeConnection = self.connection else { return }
        
        var size = UInt32(data.count).bigEndian
        let sizeData = Data(bytes: &size, count: 4)
        
        // We combine the header and body into one send call for efficiency
        activeConnection.send(content: sizeData + data, completion: .contentProcessed({ error in
            if let error = error {
                print("Send error: \(error)")
            }
        }))
    }
}
// Imports
import Network
import Foundation
import SwiftUI

@MainActor
final class NetworkManager: ObservableObject {
    // Variables
    private var connection: NWConnection?
    @Published var receivedImage: NSImage?
    @Published var isConnected = false

    // Start Hosting Function
    func startHosting() {
        do {
            let listener = try NWListener(using: .tcp, on: 8080)

            listener.newConnectionHandler = { [weak self] newConn in
                guard let weakSelf = self else { return }
                
                Task { @MainActor in
                    weakSelf.connection = newConn
                    weakSelf.setupConnection(newConn)
                }
            }

            listener.start(queue: .main)
        } catch {
            print(error)
        }
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
            guard case .ready = state,
                let weakSelf = self else { return }

            Task { @MainActor in
                weakSelf.isConnected = true
                weakSelf.receiveFrame()
            }
        }


        conn.start(queue: .main)
    }

    // Frame Handling Functions:
    func receiveFrame() { // Frame Recieving Function
        // Read the first 4 bytes to get the size of the incoming image data
        guard let activeConnection = self.connection else { return }
        // Read the header (4 bytes for size)
        activeConnection.receive(
            minimumIncompleteLength: 4,
            maximumLength: 4
        ) { [weak self] headerData, _, _, _ in
            // Validate header data
            guard
                let headerData,
                headerData.count == 4
            else { return }
            // Convert the 4-byte header to an integer (big-endian)
            let size = headerData
                .withUnsafeBytes { $0.load(as: UInt32.self) }
                .bigEndian
            // Read the image data based on the size from the header
            activeConnection.receive(
                minimumIncompleteLength: Int(size),
                maximumLength: Int(size)
            ) { [weak self] imgData, _, _, _ in
                // Validate image data
                guard let imgData else { return }
                // Update the UI on the main thread
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    // Convert the received data to an NSImage and update the published property
                    if let image = NSImage(data: imgData) {
                        self.receivedImage = image
                    }
                    // Continue listening for the next frame
                    self.receiveFrame()
                }
            }
        }
    }

    func sendFrame(_ data: Data) { // Frame Sending Function
        // Prepare the size header and payload
        guard let activeConnection = self.connection else { return }
        // Prepare the size header (4 bytes) in big-endian format
        var size = UInt32(data.count).bigEndian
        let sizeData = Data(bytes: &size, count: 4)
        let payload = sizeData + data
        // Send the size header followed by the image data
        activeConnection.send(
            content: payload,
            completion: .contentProcessed { error in
                if let error {
                    print("Send error: \(error)")
                }
            }
        )
    }
}
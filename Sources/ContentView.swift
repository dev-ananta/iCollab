import SwiftUI

struct ContentView: View {
    // These remain as StateObjects
    @StateObject private var capture = CaptureEngine()
    @StateObject private var network = NetworkManager()
    
    @State private var ipAddress: String = ""
    @State private var isHost = false
    @State private var sessionCode: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if !network.isConnected {
                setupInterface
            } else {
                streamingInterface
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }

    var setupInterface: some View {
        VStack(spacing: 15) {
            Text("iCollab Screen Share").font(.largeTitle).bold()
            
            Button(action: { startHosting() }) {
                Text("Host Session").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Divider()

            // Keep '$' here: TextField REQUIRES a binding to modify the string
            TextField("Enter IP Address", text: $ipAddress)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)

            // FIXED (Ln 41): No '$'. Call method directly on 'network'.
            Button(action: { 
                network.connect(to: ipAddress) 
            }) {
                Text("Join Session").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    var streamingInterface: some View {
        VStack {
            if isHost {
                Text("Sharing Screen").font(.headline)
                Text("Session Code: \(sessionCode)").foregroundColor(.secondary)
                ProgressView()
                
                // FIXED (Ln 57): No '$'. Call method directly on 'capture'.
                Button("Stop Sharing") {
                    Task {
                        await capture.stop()
                    }
                }
            } else {
                if let image = network.receivedImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    ProgressView("Connecting to Host...")
                }
            }
        }
    }

    func startHosting() {
        isHost = true
        sessionCode = SessionManager.generateCode()
        PersistenceManager.shared.logSession(code: sessionCode)
        
        network.startHosting()
        
        // We use Task to bridge from the synchronous button click to the async engine start
        Task {
            // Await the engine start
            await capture.start()
            
            // Set the frame capture logic
            // Note: capture.onFrameCaptured must be defined as (@Sendable (Data) -> Void)? 
            // in CaptureEngine.swift to satisfy this.
            capture.onFrameCaptured = { [weak network] data in
                // We send the data directly through the network manager
                DispatchQueue.main.async {
                    network?.sendFrame(data)
                }
            }
        }
    }
}
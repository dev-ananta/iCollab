// Imports
import ScreenCaptureKit
import VideoToolbox

@MainActor 
class CaptureEngine: NSObject, SCStreamOutput, ObservableObject {
    // Variables
    private var stream: SCStream?
    var onFrameCaptured: (@Sendable (Data) -> Void)?

    // Start Screen Capture Function via Async/Await
    func start() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            guard let display = content.displays.first else { return }
            
            let filter = SCContentFilter(display: display, excludingWindows: [])
            let config = SCStreamConfiguration()
            config.width = 1280
            config.height = 720
            
            stream = SCStream(filter: filter, configuration: config, delegate: nil)
            // Note: We still pass 'self', but the method below is nonisolated
            try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global())
            try await stream?.startCapture()
        } catch {
            print("Capture failed: \(error)")
        }
    }

    func stop() async {
        do {
            try await stream?.stopCapture()
            stream = nil
        } catch {
            print("Failed to stop capture: \(error)")
        }
    }

    // FIXED: nonisolated prevents the Swift 6 data race error
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        if let jpegData = context.jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]) {
            // Hop back to the main actor to trigger the closure safely
            Task { @MainActor in
                onFrameCaptured?(jpegData)
            }
        }
    }
}
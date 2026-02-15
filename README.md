# iCollab
> 🖥️🤝🖥️
LAN-Based macOS Screen Share — Easy Install via DMG

iCollab is a lightweight, high-performance macOS screen-sharing application built with **SwiftUI**, **ScreenCaptureKit**, and **Network.framework**. It allows users to host a screen-sharing session over either a LAN-based connection (Local Area Network) or a connection revolving 6-digit session codes.

## 🖥️ Application Compatibility

- **macOS 13.0 (Ventura)** or Newer
- **Apple Silicon (arm64)** — Native, Optimized Performance
- **Intel (x86_64)** — Full Support
- Both Architectures are Automatically Built & Available as Separate DMG Installers.

## ✨ Features

* **Real-time Screen Sharing**: Leverages Apple's `ScreenCaptureKit` for low-latency, high-quality display capture.
* **TCP Streaming**: Uses `Network.framework` for reliable frame delivery between host and client.
* **Zero-Config Discovery**: Generate easy-to-read session codes based on local IP addresses.
* **Secure & Logged**: Integrated session logging via `PersistenceManager` to track host activity.
* **Sandboxed**: Built with macOS security best practices using App Sandbox and Hardened Runtime.

## Project Specifications:
- **Domain**: Native macOS Systems Programming/Real-Time Networking
- **Uniqueness**: High (Prototype Distributed Desktop Architecture)

### 📂 Project Structure
```
iCollab/
│── README.md → Documentation & Information
│── LICENSE.md → License pertaining to Copyright Information revolving this project/repository.
│── Info.plist → Information Property List; File that Manifests & Communication with macOS on how to Handle the Application. (Required Permissions & Identity)
│── iCollab.entitlements → Communicates with macOS Kernel to Allow for Access & Utilization of Certain Restricted Resources.
│── Package.swift → Instruct SPM (Swift Package Manager) how to Build, Organize, & Distribute Code.
│── .gitignore → Responsible for Instructing GitHub Ignore Certain Files.
│── /Sources 
│     ├──  App.swift → Defines Primary Strucutre & Entry Point for Application.
│     ├──  CaptureEngine.swift → SCKit Logic for Display Frame Capture & JPEG Encoding.
│     ├──  ContentView.swift → Main SwiftUI Interface & UI State Management.
│     ├──  NetworkManager.swift → TCP Socket Handling (Listener for Host, Connection for Client).
│     ├──  PersistenceManager.swift → Thread-safe Logging of Session Data to Disk.
│     └──  SessionManager.swift → IP Address Retrieval & Session Code Generation.

```

## 🚀 Getting Started

### Prerequisites (for end users)

* **macOS 13.0 (Ventura)** or newer

### Prerequisites (for developers/building locally)

* **macOS 13.0 (Ventura)** or newer
* **Swift 5.9+** (installed via Command Line Tools)

### Installation (End Users)

1. **Download the DMG installer** from [Releases](https://github.com/aparikh1/iCollab/releases)
2. **Open the DMG** and drag `iCollab.app` to Applications
3. **Remove quarantine attribute** (if Gatekeeper blocks it):
```bash
xattr -d com.apple.quarantine /Applications/iCollab.app
```
4. **Launch** from Applications or Spotlight

### Building Locally (Developers)

1. **Clone the repository**:
```bash
git clone https://github.com/aparikh1/iCollab.git
cd iCollab
```
2. **Build the project**:
```bash
swift build -c release
```
3. **Remove quarantine attribute** (optional):
```bash
xattr -d com.apple.quarantine .build/release/iCollab
```
4. **Run**:
```bash
./.build/release/iCollab
```

## 🛠️ Usage

### Hosting a Session

1. Launch `iCollab` from Applications
2. Click **Host Session**
3. **Permissions**: Allow Screen Recording when prompted
4. Share the **Session Code** or **Local IP** with the client

### Joining a Session

1. Launch `iCollab` on a second machine
2. Enter the Host's IP address in the text field
3. Click **Join Session**

## � Troubleshooting

### App Won't Launch / "Damaged" Message

If macOS blocks the app as "damaged" or "unverified":
```bash
xattr -d com.apple.quarantine /Applications/iCollab.app
```

### Black Screen

If the client connects but only sees a black screen, ensure the Host has granted **Screen Recording** permissions. You may need to restart the app after toggling this setting in macOS System Settings.

### Firewall

Ensure the macOS Firewall is not blocking incoming connections on port **8080**.

## 📄 License

Distributed under the MIT License. See `LICENSE.md` for more information.

---

#### Signed by Ananta the Developer
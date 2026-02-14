# iCollab
> 🖥️🤝🖥️
LAN-Based macOS Screen Share (View-Only MVP) iCollab is a lightweight, high-performance macOS screen-sharing application built with **SwiftUI**, **ScreenCaptureKit**, and **Network.framework**. It allows users to host a screen-sharing session over either a LAN-based connection (Local Area Network) or a connection revolving 6-digit session codes.

## 🖥️ Application Compatibility:

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

### Prerequisites

* **macOS 13.0 (Ventura)** or newer.
* **Swift 5.9+** (installed via Command Line Tools).
* **Visual Studio Code** (with the Swift extension).

### Installation & Build

1. **Clone the repository**:
```bash
git clone https://github.com/yourusername/iCollab.git
cd iCollab
```
2. **Build the project**:
```bash
swift build
```
3. **Sign the binary (Crucial)**: Since this app uses screen recording and network servers, you must sign it with the provided entitlements and enable the **Hardened Runtime**:
```bash
codesign --entitlements iCollab.entitlements --options runtime -f -s - .build/debug/iCollab
```

## 🛠️ Usage

### Hosting a Session

1. Run the app: `./.build/debug/iCollab`.
2. Click **Host Session**.
3. **Permissions**: When prompted, allow Screen Recording in `System Settings > Privacy & Security > Screen Recording`.
4. Share the **Session Code** or your **Local IP** with the client.

### Joining a Session

1. Run the app on a second machine (or a second window).
2. Enter the Host's IP address in the text field.
3. Click **Join Session**.

## 🔒 Security & Troubleshooting

### Trace Trap / Crash on Startup

If the app exits with a `trace trap`, it usually means the signature is invalid for the requested entitlements. Ensure you are using the `--options runtime` flag during the `codesign` step.

### Black Screen

If the client connects but only sees a black screen, ensure the Host has granted **Screen Recording** permissions. You may need to restart the app after toggling this setting in macOS System Settings.

### Firewall

Ensure the macOS Firewall is not blocking incoming connections on port **8080**.

## 📄 License

Distributed under the MIT License. See `LICENSE.md` for more information.

---

#### Signed by Ananta the Developer
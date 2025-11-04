//
//  NetworkMonitor.swift
//  bigbruhh
//
//  Network connectivity monitoring service
//  Tracks internet connection status and notifies when connectivity changes
//

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .unknown

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown

        var description: String {
            switch self {
            case .wifi: return "Wi-Fi"
            case .cellular: return "Cellular"
            case .ethernet: return "Ethernet"
            case .unknown: return "Unknown"
            }
        }
    }

    private init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            Task { @MainActor in
                self.isConnected = path.status == .satisfied

                // Determine connection type
                if path.usesInterfaceType(.wifi) {
                    self.connectionType = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.connectionType = .cellular
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self.connectionType = .ethernet
                } else {
                    self.connectionType = .unknown
                }

                Config.log("Network status: \(self.isConnected ? "Connected" : "Disconnected") via \(self.connectionType.description)", category: "Network")
            }
        }

        monitor.start(queue: queue)
        Config.log("Network monitoring started", category: "Network")
    }

    func stopMonitoring() {
        monitor.cancel()
        Config.log("Network monitoring stopped", category: "Network")
    }

    // MARK: - Helpers

    /// Check if connected to internet
    var hasConnection: Bool {
        isConnected
    }

    /// Check if on cellular (for data-saving features)
    var isCellular: Bool {
        connectionType == .cellular
    }

    /// Check if on WiFi (for heavy downloads)
    var isWiFi: Bool {
        connectionType == .wifi
    }
}

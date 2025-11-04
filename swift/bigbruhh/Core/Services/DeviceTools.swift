import Foundation
import UIKit
import Combine

enum DeviceToolError: Error {
    case unsupported
    case invalidParameters
}

struct DeviceTools {
    @MainActor static func getBatteryLevel(_: Any?) -> Any? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        if level < 0 {
            return "Error: Device does not support retrieving the battery level."
        }
        return level
    }

    @MainActor static func changeBrightness(_ params: Any?) -> Any? {
        guard
            let payload = params as? [String: Any],
            let brightness = payload["brightness"] as? CGFloat
        else {
            return DeviceToolError.invalidParameters.localizedDescription
        }
        UIScreen.main.brightness = max(0.0, min(brightness, 1.0))
        return brightness
    }

    @MainActor static func flashScreen(_: Any?) -> Any? {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let overlay = UIView(frame: UIScreen.main.bounds)
        overlay.backgroundColor = .white
        overlay.alpha = 0.0
        window?.addSubview(overlay)

        UIView.animate(withDuration: 0.1, animations: {
            overlay.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                overlay.alpha = 0.0
            }) { _ in
                overlay.removeFromSuperview()
            }
        }
        return "Successfully flashed the screen."
    }
}

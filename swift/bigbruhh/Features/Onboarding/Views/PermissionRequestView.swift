//
//  PermissionRequestView.swift
//  bigbruhh
//
//  Permission request screens for onboarding
//

import SwiftUI
import UserNotifications
import AVFoundation

struct PermissionRequestView: View {
    let permissionType: PermissionType
    let onComplete: (Bool) -> Void

    @State private var hasAppeared = false
    @State private var isRequesting = false
    @State private var permissionGranted = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay - full screen
            Scanlines()

            VStack(spacing: 40) {
                Spacer()

                // Icon
                Image(systemName: permissionType.iconName)
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#FFE66D"))
                    .scaleEffect(hasAppeared ? 1.0 : 0.8)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: hasAppeared)

                VStack(spacing: 16) {
                    // Title
                    Text(permissionType.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(hasAppeared ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: hasAppeared)

                    // Explanation
                    Text(permissionType.explanation)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(hasAppeared ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: hasAppeared)
                }

                Spacer()

                // Grant Permission Button
                VStack(spacing: 16) {
                    Button(action: requestPermission) {
                        HStack(spacing: 12) {
                            if isRequesting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: permissionGranted ? "checkmark" : "lock.open.fill")
                                    .font(.system(size: 20))
                                Text(permissionGranted ? "GRANTED" : "ALLOW ACCESS")
                                    .font(.system(size: 14, weight: .bold))
                                    .tracking(1.5)
                            }
                        }
                        .foregroundColor(Color.buttonTextColor(for: .brutalRed))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .applyVoiceGlassEffect(prominent: true, accentColor: Color.brutalRed)
                    .disabled(isRequesting || permissionGranted)
                    .opacity(hasAppeared ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: hasAppeared)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // Reset state when view appears with new permission type
            resetPermissionState()
            
            withAnimation {
                hasAppeared = true
            }
            
            // Check permission status on appear
            checkCurrentPermissionStatus()
        }
    }
    
    private func requestPermission() {
        isRequesting = true
        
        switch permissionType {
        case .notifications:
            requestNotificationPermission()
        case .calls:
            requestCallPermission()
        case .microphone:
            requestMicrophonePermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                isRequesting = false
                permissionGranted = granted
                
                if let error = error {
                    print("Notification permission error: \(error)")
                }
                
                // Continue after short delay to show granted state
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete(granted)
                }
            }
        }
    }
    
    private func requestCallPermission() {
        // Note: CallKit doesn't require explicit permission request
        // But we can check if notifications are enabled (for call notifications)
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isRequesting = false
                let granted = settings.authorizationStatus == .authorized
                
                permissionGranted = true  // Assume granted for CallKit
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete(true)
                }
            }
        }
    }
    
    private func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            // Use new AVAudioApplication API for iOS 17+
            Task {
                do {
                    let granted = try await AVAudioApplication.requestRecordPermission()
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        self.permissionGranted = granted
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onComplete(granted)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        self.permissionGranted = false
                        onComplete(false)
                    }
                }
            }
        } else {
            // Use deprecated AVAudioSession API for iOS 16 and earlier
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.permissionGranted = granted
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        onComplete(granted)
                    }
                }
            }
        }
    }
    
    private func resetPermissionState() {
        // Reset all permission state when view appears with new permission type
        isRequesting = false
        permissionGranted = false
        hasAppeared = false
    }
    
    private func checkCurrentPermissionStatus() {
        switch permissionType {
        case .notifications:
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    self.permissionGranted = settings.authorizationStatus == .authorized
                    if self.permissionGranted {
                        // Auto-advance if already granted
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onComplete(true)
                        }
                    }
                }
            }
        case .calls:
            // CallKit doesn't require explicit permission
            permissionGranted = true
            // Auto-advance immediately for calls
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete(true)
            }
        case .microphone:
            checkMicrophonePermissionStatus()
        }
    }
    
    private func checkMicrophonePermissionStatus() {
        if #available(iOS 17.0, *) {
            // Use new AVAudioApplication API for iOS 17+
            let status = AVAudioApplication.shared.recordPermission
            permissionGranted = status == .granted
        } else {
            // Use deprecated AVAudioSession API for iOS 16 and earlier
            let status = AVAudioSession.sharedInstance().recordPermission
            permissionGranted = status == .granted
        }
        
        if permissionGranted {
            // Auto-advance if already granted
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete(true)
            }
        }
    }
}

// MARK: - Preview

#Preview("Notifications") {
    PermissionRequestView(
        permissionType: .notifications,
        onComplete: { granted in
            print("Notifications permission: \(granted)")
        }
    )
}

#Preview("Calls") {
    PermissionRequestView(
        permissionType: .calls,
        onComplete: { granted in
            print("Calls permission: \(granted)")
        }
    )
}

#Preview("Microphone") {
    PermissionRequestView(
        permissionType: .microphone,
        onComplete: { granted in
            print("Microphone permission: \(granted)")
        }
    )
}


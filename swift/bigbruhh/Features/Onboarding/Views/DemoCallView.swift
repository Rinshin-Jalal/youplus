//
//  DemoCallView.swift
//  bigbruhh
//
//  Demo CallKit experience for onboarding
//

import SwiftUI
import CallKit

struct DemoCallView: View {
    let onComplete: () -> Void

    @State private var callTriggered = false
    @State private var countdownSeconds = 5

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Phone icon animation
                Image(systemName: "phone.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#4ECDC4"))
                    .scaleEffect(callTriggered ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: callTriggered)

                VStack(spacing: 16) {
                    Text("Incoming Call")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your Accountability Call")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }

                // Countdown
                if callTriggered {
                    Text("Call ends in \(countdownSeconds)s")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 20)
                }

                Spacer()

                // Explanation
                VStack(spacing: 12) {
                    Text("This is what you'll see every day")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Same time. No excuses.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            triggerDemoCall()
        }
    }

    private func triggerDemoCall() {
        // Trigger the call UI
        callTriggered = true

        // Optional: Actually trigger CallKit incoming call
        // This would require CallKit integration in the app
        // For demo purposes, we'll just show the UI and auto-dismiss

        // Start countdown
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownSeconds -= 1

            if countdownSeconds <= 0 {
                timer.invalidate()
                // Auto-dismiss and continue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - CallKit Helper (Optional Integration)

class OnboardingCallKitManager: NSObject {
    static let shared = OnboardingCallKitManager()

    private let callController = CXCallController()
    private let provider: CXProvider

    override init() {
        let configuration = CXProviderConfiguration(localizedName: "BigBruh Accountability")
        configuration.supportsVideo = false
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]

        provider = CXProvider(configuration: configuration)
        super.init()

        provider.setDelegate(self, queue: nil)
    }

    func triggerDemoIncomingCall() {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Your Accountability Call")
        update.hasVideo = false

        let callUUID = UUID()

        provider.reportNewIncomingCall(with: callUUID, update: update) { error in
            if let error = error {
                print("Error reporting incoming call: \(error)")
            } else {
                // Auto-end the call after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.endCall(uuid: callUUID)
                }
            }
        }
    }

    func endCall(uuid: UUID) {
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)

        callController.request(transaction) { error in
            if let error = error {
                print("Error ending call: \(error)")
            }
        }
    }
}

extension OnboardingCallKitManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Handle provider reset
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
}

// MARK: - Preview

#Preview {
    DemoCallView(onComplete: {
        print("Demo call complete")
    })
}

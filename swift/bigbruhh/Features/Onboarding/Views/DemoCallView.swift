//
//  DemoCallView.swift
//  bigbruhh
//
//  Demo call experience for onboarding
//  Step 25: Live demo call using cloned voice + user's data
//  TODO: Integrate with LiveKit for real call experience
//

import SwiftUI
import CallKit

struct DemoCallView: View {
    let onComplete: () -> Void

    @State private var callTriggered = false
    @State private var countdownSeconds = 90  // 60-90 second demo call

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
                    Text(callTriggered ? "Future You" : "Incoming Call")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text(callTriggered ? "Your Daily Accountability Call" : "Preparing your call...")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                }

                // Demo call simulation
                if callTriggered {
                    VStack(spacing: 12) {
                        Text("DEMO CALL IN PROGRESS")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2)
                            .foregroundColor(Color(hex: "#4ECDC4"))
                            .padding(.top, 20)

                        Text("\(countdownSeconds)s remaining")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))

                        Text("This is a preview of your daily calls")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.top, 4)
                    }
                }

                Spacer()

                // Explanation
                if !callTriggered {
                    VStack(spacing: 12) {
                        Text("Get ready for your first call")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("This is what happens every single day")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                } else {
                    // Live call simulation
                    VStack(spacing: 16) {
                        Text("\"So, you're ready to finally do this?\"")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .italic()

                        Text("\"No more excuses. I'll be here every day.\"")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .italic()
                            .padding(.top, 8)

                        Text("Using YOUR voice. YOUR data.")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#4ECDC4"))
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            triggerDemoCall()
        }
    }

    private func triggerDemoCall() {
        // Small delay before triggering call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                callTriggered = true
            }

            // TODO: Integrate with LiveKit for real call experience
            // - Pass cloned voice ID from step 24 loading
            // - Pass onboarding data to AI agent
            // - Use LiveKit for real-time call
            // - 60-90 second duration with actual conversation

            // For now: Simulate call countdown
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

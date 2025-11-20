//
//  DemoCallView.swift
//  bigbruhh
//
//  Demo call experience for onboarding
//  Step 25: Plays personalized demo call using cloned voice from Cartesia
//

import SwiftUI
import CallKit
import AVFoundation

struct DemoCallView: View {
    let onComplete: () -> Void

    @EnvironmentObject var state: ConversionOnboardingState

    @State private var callTriggered = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackProgress: Double = 0.0
    @State private var isPlaying: Bool = false
    @State private var displayedText: String = ""
    @State private var playbackTimer: Timer?
    @State private var pulseAnimation: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay - full screen
            Scanlines()

            VStack(spacing: 32) {
                Spacer()

                // Phone icon with pulsing glow animation
                ZStack {
                    // Outer glow rings
                    if callTriggered {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#4ECDC4").opacity(0.3),
                                        Color(hex: "#4ECDC4").opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0.0 : 1.0)
                            .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                    }

                    // Phone icon
                    Image(systemName: "phone.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "#4ECDC4"))
                        .shadow(
                            color: Color(hex: "#4ECDC4").opacity(0.6),
                            radius: callTriggered ? 20 : 10,
                            x: 0,
                            y: 0
                        )
                        .scaleEffect(callTriggered ? 1.0 : 0.95)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: callTriggered)
                }

                VStack(spacing: 16) {
                    Text(callTriggered ? "Future You" : "Incoming Call")
                        .font(.headlineMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(callTriggered ? "Your Daily Accountability Call" : "Preparing your call...")
                        .font(.bodyRegular)
                        .foregroundColor(.white.opacity(0.8))
                }

                // Call status
                if callTriggered && isPlaying {
                    Group {
                        if #available(iOS 26, *) {
                            VStack(spacing: 12) {
                                Text("CALL IN PROGRESS")
                                    .font(.captionMedium)
                                    .fontWeight(.bold)
                                    .tracking(2)
                                    .foregroundColor(Color(hex: "#4ECDC4"))
                                    .padding(.top, 20)

                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 4)
                                            .cornerRadius(2)

                                        Rectangle()
                                            .fill(Color(hex: "#4ECDC4"))
                                            .frame(width: geometry.size.width * playbackProgress, height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal, 40)

                                Text("Using YOUR voice • YOUR data")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.top, 4)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                            .glassEffect(in: .rect(cornerRadius: 20))
                        } else {
                            VStack(spacing: 12) {
                                Text("CALL IN PROGRESS")
                                    .font(.captionMedium)
                                    .fontWeight(.bold)
                                    .tracking(2)
                                    .foregroundColor(Color(hex: "#4ECDC4"))
                                    .padding(.top, 20)

                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.1))
                                            .frame(height: 4)
                                            .cornerRadius(2)

                                        Rectangle()
                                            .fill(Color(hex: "#4ECDC4"))
                                            .frame(width: geometry.size.width * playbackProgress, height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(height: 4)
                                .padding(.horizontal, 40)

                                Text("Using YOUR voice • YOUR data")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.4))
                                    .padding(.top, 4)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                }

                Spacer()

                // Explanation or transcript
                if !callTriggered {
                    Group {
                        if #available(iOS 26, *) {
                            VStack(spacing: 12) {
                                Text("Get ready for your first call")
                                    .font(.bodyBold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text("This is what happens every single day")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .glassEffect(in: .rect(cornerRadius: 20))
                            .padding(.horizontal, 24)
                            .padding(.bottom, 60)
                        } else {
                            VStack(spacing: 12) {
                                Text("Get ready for your first call")
                                    .font(.bodyBold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text("This is what happens every single day")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                            .padding(.bottom, 60)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    // Transcript display with typewriter effect
                    Group {
                        if #available(iOS 26, *) {
                            VStack(spacing: 16) {
                                if !displayedText.isEmpty {
                                    Text("\"\(displayedText)\"")
                                        .font(.bodyRegular)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .italic()
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(minHeight: 120)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .glassEffect(in: .rect(cornerRadius: 20))
                            .padding(.horizontal, 24)
                            .padding(.bottom, 60)
                        } else {
                            VStack(spacing: 16) {
                                if !displayedText.isEmpty {
                                    Text("\"\(displayedText)\"")
                                        .font(.bodyRegular)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .italic()
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .frame(minHeight: 120)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                            .padding(.bottom, 60)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            triggerDemoCall()
            // Start pulse animation
            pulseAnimation = true
        }
    }

    private func triggerDemoCall() {
        // Small delay before triggering call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.4)) {
                callTriggered = true
            }

            // Check if we have demo audio
            guard let audioURL = state.demoCallAudioURL,
                  let transcript = state.demoCallTranscript else {
                Config.log("⚠️ No demo audio available, showing fallback", category: "DemoCall")
                showFallbackDemo()
                return
            }

            // Play the demo audio
            playDemoAudio(url: audioURL, transcript: transcript)
        }
    }

    private func playDemoAudio(url: URL, transcript: String) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true

            Config.log("▶️ Playing demo audio", category: "DemoCall")

            // Start typewriter effect for transcript
            startTypewriterEffect(text: transcript)

            // Update progress
            startProgressTracking()

        } catch {
            Config.log("❌ Failed to play audio: \(error)", category: "DemoCall")
            showFallbackDemo()
        }
    }

    private func startTypewriterEffect(text: String) {
        displayedText = ""
        let characters = Array(text)
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            guard currentIndex < characters.count else {
                timer.invalidate()
                return
            }

            displayedText.append(characters[currentIndex])
            currentIndex += 1
        }
    }

    private func startProgressTracking() {
        guard let player = audioPlayer else { return }

        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            guard let audioPlayer = self.audioPlayer, audioPlayer.isPlaying else {
                timer.invalidate()
                self.handleAudioComplete()
                return
            }

            playbackProgress = audioPlayer.currentTime / audioPlayer.duration
        }
    }

    private func handleAudioComplete() {
        isPlaying = false
        playbackTimer?.invalidate()

        Config.log("✅ Demo audio playback complete", category: "DemoCall")

        // Continue after a brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onComplete()
        }
    }

    private func showFallbackDemo() {
        // Fallback: Show static message if audio isn't available
        displayedText = "Hey, it's me - you from the future. I know about \(state.getResponse(forStepId: 5) ?? "your goal"). Starting tomorrow, I'll be calling you every single day. No escape. No excuses. Let's do this."

        // Auto-complete after showing message
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            onComplete()
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

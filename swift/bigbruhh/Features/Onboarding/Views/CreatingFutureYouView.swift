//
//  CreatingFutureYouView.swift
//  bigbruhh
//
//  Loading screen for voice clone creation during onboarding
//  Step 24: Shows progress while creating "Future You" from voice recordings
//

import SwiftUI

struct CreatingFutureYouView: View {
    let config: LoadingConfig
    let onComplete: () -> Void

    @EnvironmentObject var state: ConversionOnboardingState

    @State private var currentMessageIndex: Int = 0
    @State private var progress: Double = 0.0
    @State private var isComplete: Bool = false
    @State private var isCloning: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Scanline overlay
            Scanlines()

            VStack(spacing: 40) {
                Spacer()

                // Main title
                Text(config.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Animated icon
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(Color(hex: "#4ECDC4").opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(progress > 0 ? 1.2 : 1.0)
                        .opacity(progress > 0 ? 0.0 : 1.0)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: progress)

                    // Main icon
                    Circle()
                        .fill(Color(hex: "#4ECDC4").opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "#4ECDC4"))
                        .rotationEffect(.degrees(progress * 360))
                }
                .padding(.vertical, 20)

                // Progress bar
                VStack(spacing: 16) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)

                            // Fill
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#4ECDC4"), Color(hex: "#3ab8b0")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * progress, height: 8)
                                .cornerRadius(4)
                                .animation(.linear(duration: 0.3), value: progress)
                        }
                    }
                    .frame(height: 8)

                    // Status message
                    if currentMessageIndex < config.statusMessages.count {
                        Text(config.statusMessages[currentMessageIndex])
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#4ECDC4"))
                            .transition(.opacity)
                            .id(currentMessageIndex) // Force view update
                    }

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 48)

                Spacer()
            }
        }
        .onAppear {
            startLoadingSequence()
        }
    }

    private func startLoadingSequence() {
        let messageCount = config.statusMessages.count
        let intervalDuration = config.duration / Double(messageCount)

        // Start voice cloning in background
        Task {
            await cloneVoiceAndGenerateDemo()
        }

        // Animate progress and cycle through messages
        Timer.scheduledTimer(withTimeInterval: intervalDuration, repeats: true) { timer in
            withAnimation {
                if currentMessageIndex < messageCount - 1 {
                    currentMessageIndex += 1
                    progress = Double(currentMessageIndex + 1) / Double(messageCount)
                } else {
                    progress = 1.0
                    timer.invalidate()

                    // Wait for voice cloning to complete
                    waitForCloningCompletion()
                }
            }
        }
    }

    private func cloneVoiceAndGenerateDemo() async {
        isCloning = true

        do {
            // Get voice recordings from steps 8 and 20
            guard let voice1 = state.getVoiceRecording(forKey: "step_8"),
                  let voice2 = state.getVoiceRecording(forKey: "step_20") else {
                errorMessage = "No voice recordings found"
                isCloning = false
                return
            }

            // Get user's name and goal
            let userName = state.getResponse(forStepId: 4) ?? "User"
            let goal = state.getResponse(forStepId: 5) ?? "your goal"
            let motivationLevel = Int(state.getResponse(forStepId: 7) ?? "5") ?? 5

            Config.log("🎤 Cloning voice with recordings from steps 8 & 20", category: "VoiceClone")

            // Clone voice using Cartesia
            let voiceCloneID = try await VoiceCloneService.shared.cloneVoice(
                from: [voice1, voice2],
                userName: userName
            )

            // Store voice clone ID
            await MainActor.run {
                state.voiceCloneID = voiceCloneID
            }

            Config.log("✅ Voice cloned: \(voiceCloneID)", category: "VoiceClone")

            // Generate demo call audio
            Config.log("🎬 Generating demo call", category: "DemoCall")

            let demoAudio = try await DemoCallService.shared.generateDemoCall(
                voiceCloneID: voiceCloneID,
                userName: userName,
                goal: goal,
                motivationLevel: motivationLevel
            )

            // Store demo audio
            await MainActor.run {
                state.demoCallAudioURL = demoAudio.audioURL
                state.demoCallTranscript = demoAudio.transcript
            }

            Config.log("✅ Demo call generated", category: "DemoCall")

        } catch {
            Config.log("❌ Voice cloning/demo generation failed: \(error)", category: "VoiceClone")
            await MainActor.run {
                errorMessage = "Failed to create voice clone"
            }
        }

        isCloning = false
    }

    private func waitForCloningCompletion() {
        // Check if cloning is complete every 0.5 seconds
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !isCloning || errorMessage != nil {
                timer.invalidate()

                // Complete after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isComplete = true
                    config.onComplete?()
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreatingFutureYouView(
        config: LoadingConfig(
            title: "Creating Your Future You",
            statusMessages: [
                "Analyzing your voice...",
                "Building your accountability partner...",
                "Preparing your first call...",
                "Almost ready..."
            ],
            duration: 8.0
        ),
        onComplete: {
            print("Loading complete")
        }
    )
}

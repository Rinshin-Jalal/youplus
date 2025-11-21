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
    @State private var pulse: Double = 1.0
    @State private var scanlineOffset: CGFloat = 0

    // Brutalist Red Accent
    private let accentColor = Color.brutalRed

    var body: some View {
        ZStack {

          Color.black
                .ignoresSafeArea()

            // Scanline overlay - subtle monitor effect
            Scanlines()

            // Vignette overlay - focus attention
            Vignette(intensity: 0.5)

            VStack {
                Spacer()
                
                Text(config.title.uppercased())
                    .font(.system(size: 18, weight: .black))
                    .tracking(4)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 40)
                        
                Spacer()

 // Core Glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.8),
                                accentColor.opacity(0.0)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(pulse)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: pulse)
                  
               

                Spacer()

                // Error message and Retry button
                if let error = errorMessage {
                    VStack(spacing: 16) {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            retryCloning()
                        }) {
                            Text("RETRY")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(accentColor)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            isCloning = true
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulse = 1.2
            }
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
            // Stop timer if error occurred
            if errorMessage != nil {
                timer.invalidate()
                return
            }
            
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
    
    private func retryCloning() {
        errorMessage = nil
        currentMessageIndex = 0
        progress = 0.0
        startLoadingSequence()
    }

    private func cloneVoiceAndGenerateDemo() async {
        isCloning = true
        errorMessage = nil // Clear any previous errors

        do {
            // Get voice recordings from steps 8 and 23 (not 20!)
            guard let voice1 = state.getVoiceRecording(forKey: "step_8"),
                  let voice2 = state.getVoiceRecording(forKey: "step_23") else {
                errorMessage = "No voice recordings found"
                isCloning = false
                return
            }

            // Get user's name and goal
            let userName = state.getResponse(forStepId: 4) ?? "User"
            let goal = state.getResponse(forStepId: 5) ?? "your goal"
            let motivationLevel = Int(state.getResponse(forStepId: 7) ?? "5") ?? 5

            Config.log("🎤 Cloning voice with recordings from steps 8 & 23", category: "VoiceClone")

            // Clone voice using Backend
            let voiceCloneID = try await ConversionOnboardingService.shared.cloneVoice(
                audioURLs: [voice1, voice2],
                userName: userName
            )

            // Store voice clone ID
            await MainActor.run {
                state.voiceCloneID = voiceCloneID
            }

            Config.log("✅ Voice cloned: \(voiceCloneID)", category: "VoiceClone")

            // Generate demo call audio
            Config.log("🎬 Generating demo call", category: "DemoCall")

            let (audioURL, transcript) = try await ConversionOnboardingService.shared.generateDemoCall(
                voiceId: voiceCloneID,
                userName: userName,
                goal: goal,
                motivationLevel: motivationLevel
            )

            // Store demo audio
            await MainActor.run {
                state.demoCallAudioURL = audioURL
                state.demoCallTranscript = transcript
            }

            Config.log("✅ Demo call generated", category: "DemoCall")

        } catch {
            Config.log("❌ Voice cloning/demo generation failed: \(error)", category: "VoiceClone")
            await MainActor.run {
                errorMessage = "Failed to create voice clone. Please try again."
            }
        }

        isCloning = false
    }

    private func waitForCloningCompletion() {
        // Check if cloning is complete every 0.5 seconds
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            // If error occurred, stop waiting and let user retry
            if errorMessage != nil {
                timer.invalidate()
                return
            }
            
            if !isCloning {
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

struct CreatingFutureYouView_Previews: PreviewProvider {
    static var previews: some View {
        CreatingFutureYouView(
            config: LoadingConfig(
                title: "Creating Future You",
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
}

//
//  VoiceStep.swift
//  bigbruhh
//
//  Voice recording with psychological pressure
//  Migrated from: nrn/components/onboarding/steps/VoiceStep.tsx
//
//  Features:
//  - Record/Pause/Resume/Submit
//  - Random notification styles
//  - Hostile messages during recording
//  - Minimum duration requirement
//  - Audio to base64 conversion
//

import SwiftUI
import AVFoundation

struct VoiceStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let secondaryAccentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var audioRecorder = AudioRecorderManager()

    @State private var phase: RecordingPhase = .ready
    @State private var isRecording: Bool = false
    @State private var isPaused: Bool = false
    @State private var recordingDuration: Int = 0
    @State private var currentMessage: String = ""
    @State private var notificationStyle: NotificationStyle = .imessage

    @State private var recordingTimer: Timer?
    @State private var messageTimer: Timer?

    private let minDuration: Int

    init(step: StepDefinition, promptResolver: any PromptResolving, backgroundColor: Color, textColor: Color, accentColor: Color, secondaryAccentColor: Color, onContinue: @escaping (UserResponse) -> Void) {
        self.step = step
        self.promptResolver = promptResolver
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.accentColor = accentColor
        self.secondaryAccentColor = secondaryAccentColor
        self.onContinue = onContinue
        self.minDuration = step.minDuration ?? 5
    }

    enum RecordingPhase {
        case ready, recording, paused, processing, complete
    }

    enum NotificationStyle: CaseIterable {
        case imessage, twitch, instagram, push, discord, tiktok
    }

    private let hostileMessages = [
        "don't freeze", "say it louder", "no mumbling fr", "speak up now",
        "no weak energy", "commit or quit", "zero excuses", "stop wasting time",
        "you're hesitating", "prove you're real", "voice shaking already?",
        "truth hurts huh", "no fake stuff", "comfort zone over", "stop the act",
        "every pause noted", "speak with conviction", "you're stammering",
        "voice betrays lies", "weak voice = weak", "sound stronger",
        "pathetic energy tbh"
    ]

    private let idlePrompts = [
        "ready when you are", "take your time", "waiting for you",
        "whenever you're ready", "no rush bestie", "waiting for truth",
        "mic's patient", "find your courage", "silence noted",
        "press record now", "stop procrastinating", "mic doesn't judge",
        "record or stay stuck", "truth needs voice", "voice > fear"
    ]

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Prompt at top
                Text(step.resolvedPrompt(using: promptResolver))
                    .font(.system(size: 32, weight: .black))
                    .tracking(1.2)
                    .lineSpacing(-6)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 32)

                Spacer()

                // Center content area
                VStack(spacing: 0) {
                    // Helper text (when not recording)
                    if let helperText = step.helperText, !isRecording, !isPaused {
                        Text(helperText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(textColor.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 56) // Space for absolute positioned buttons

                Spacer()
            }

            // Record button - ABSOLUTELY POSITIONED AT BOTTOM (when ready)
            if !isRecording && !isPaused && recordingDuration == 0 {
                VStack {
                    Spacer()
                    Button(action: startRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                            Text("RECORD")
                                .font(.system(size: 16, weight: .bold))
                                .tracking(1.5)
                        }
                        .foregroundColor(Color.buttonTextColor(for: accentColor))
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                    }
                    .applyVoiceGlassEffect(prominent: true, accentColor: accentColor)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }

            // Recording controls - ABSOLUTELY POSITIONED AT BOTTOM
            if isRecording || isPaused || recordingDuration > 0 {
                VStack {
                    Spacer()

                    // Timer - stays above buttons
                    VStack(spacing: 8) {
                        Text(formatTime(recordingDuration))
                            .font(.system(size: 32, weight: .bold))
                            .tracking(4)
                            .foregroundColor(textColor)

                        Text(isPaused ? "PAUSED" : (isRecording ? "RECORDING" : "STOPPED"))
                            .font(.system(size: 14, weight: .bold))
                            .tracking(2)
                            .foregroundColor(isPaused ? Color(hex: "#FF6B6B") : textColor.opacity(0.7))
                    }
                    .padding(.bottom, 24)

                    // Buttons row
                    if #available(iOS 26.0, *) {
                        GlassEffectContainer(spacing: 12.0) {
                            HStack(spacing: 12) {
                                // Pause/Resume button - secondary action
                                Button(action: isRecording ? pauseRecording : resumeRecording) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isRecording ? "pause.fill" : "play.fill")
                                            .font(.system(size: 14))
                                        Text(isRecording ? "PAUSE" : "RESUME")
                                            .font(.system(size: 14, weight: .bold))
                                            .tracking(1)
                                            .textCase(.uppercase)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                }
                                .applyVoiceGlassEffect(prominent: false, accentColor: accentColor)

                                // Submit button - primary action when enabled, disabled when not
                                Button(action: handleSubmit) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14))
                                            .foregroundColor(recordingDuration >= minDuration ? Color.buttonTextColor(for: accentColor) : nil)
                                        Text(recordingDuration < minDuration ? "NEED \(minDuration - recordingDuration)s" : "SUBMIT")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(recordingDuration >= minDuration ? Color.buttonTextColor(for: accentColor) : nil)
                                            .tracking(1)
                                            .textCase(.uppercase)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                }
                                .applyVoiceGlassEffect(prominent: recordingDuration >= minDuration, accentColor: accentColor)
                                .disabled(recordingDuration < minDuration)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    } else {
                        HStack(spacing: 12) {
                            // Pause/Resume button - secondary action
                            Button(action: isRecording ? pauseRecording : resumeRecording) {
                                HStack(spacing: 8) {
                                    Image(systemName: isRecording ? "pause.fill" : "play.fill")
                                        .font(.system(size: 14))
                                    Text(isRecording ? "PAUSE" : "RESUME")
                                        .font(.system(size: 14, weight: .bold))
                                        .tracking(1)
                                        .textCase(.uppercase)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                            .applyVoiceGlassEffect(prominent: false, accentColor: accentColor)

                            // Submit button - primary action when enabled, disabled when not
                            Button(action: handleSubmit) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14))
                                        .foregroundColor(recordingDuration >= minDuration ? Color.buttonTextColor(for: accentColor) : nil)
                                    Text(recordingDuration < minDuration ? "NEED \(minDuration - recordingDuration)s" : "SUBMIT")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(recordingDuration >= minDuration ? Color.buttonTextColor(for: accentColor) : nil)
                                        .tracking(1)
                                        .textCase(.uppercase)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                            .applyVoiceGlassEffect(prominent: recordingDuration >= minDuration, accentColor: accentColor)
                            .disabled(recordingDuration < minDuration)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }

            // Notification overlay
            NotificationView(style: notificationStyle, message: currentMessage, textColor: textColor)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.45)

            // Processing overlay
            if phase == .processing {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                Text("Processing recording...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)
            }
        }
        .onAppear {
            resetState()
            setupNotification()
            audioRecorder.requestPermission()
        }
        .onDisappear {
            cleanupTimers()
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        isRecording = false
        isPaused = false
        recordingDuration = 0
        currentMessage = ""
        phase = .ready
        cleanupTimers()
    }

    // MARK: - Actions

    private func setupNotification() {
        notificationStyle = NotificationStyle.allCases.randomElement() ?? .imessage
        currentMessage = idlePrompts.randomElement() ?? "ready when you are"
    }

    private func startRecording() {
        guard audioRecorder.startRecording() else { return }

        isRecording = true
        isPaused = false
        phase = .recording
        recordingDuration = 0

        triggerHaptic(intensity: 1.0)

        // Start recording timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }

        // Start hostile messages
        messageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            currentMessage = hostileMessages.randomElement() ?? "speak up now"
        }
        currentMessage = hostileMessages.randomElement() ?? "speak up now"
    }

    private func pauseRecording() {
        audioRecorder.pauseRecording()
        isRecording = false
        isPaused = true
        phase = .paused

        recordingTimer?.invalidate()
        messageTimer?.invalidate()

        triggerHaptic(intensity: 0.5)
    }

    private func resumeRecording() {
        guard audioRecorder.resumeRecording() else { return }

        isRecording = true
        isPaused = false
        phase = .recording

        triggerHaptic(intensity: 0.5)

        // Restart timers
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }

        messageTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            currentMessage = hostileMessages.randomElement() ?? "speak up now"
        }
    }

    private func handleSubmit() {
        guard recordingDuration >= minDuration else { return }

        isRecording = false
        isPaused = false
        phase = .processing

        cleanupTimers()
        triggerHaptic(intensity: 1.0)

        Task {
            do {
                guard let audioData = audioRecorder.stopRecording() else {
                    throw NSError(domain: "VoiceStep", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio data"])
                }

                // Save audio file and store file path instead of base64
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioFileName = "voice_\(step.id)_\(Date().timeIntervalSince1970).m4a"
                let audioFileURL = documentsPath.appendingPathComponent(audioFileName)
                
                do {
                    try audioData.write(to: audioFileURL)
                    print("✅ Audio saved to: \(audioFileURL.path)")
                } catch {
                    print("❌ Failed to save audio file: \(error)")
                    throw error
                }

                let response = UserResponse(
                    stepId: step.id,
                    type: .voice,
                    value: .text(audioFileURL.path),
                    timestamp: Date(),
                    duration: Double(recordingDuration),
                    dbField: step.dbField
                )

                print("\n🎤 === VOICE RECORDING SUBMITTED ===")
                print("🔢 Step \(step.id):")
                print("  🎤 Duration: \(recordingDuration)s")
                print("  📁 File path: \(audioFileURL.path)")
                print("  ⏰ Timestamp: \(response.timestamp)")
                print("🎤 === VOICE SUBMITTED ===\n")

                phase = .complete
                onContinue(response)

            } catch {
                print("❌ Recording submission failed: \(error)")
                phase = .ready
            }
        }
    }

    private func cleanupTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        messageTimer?.invalidate()
        messageTimer = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Custom Glass Effect Background

struct GlassEffectBackground: View {
    let prominent: Bool
    let accentColor: Color
    
    var body: some View {
        ZStack {
            // Base glass effect using blur and materials
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(
                            prominent ? 
                                accentColor.opacity(0.2) : 
                                Color.white.opacity(0.1)
                        )
                )
                .overlay(
                    // Subtle border for glass effect
                    Rectangle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
}

// MARK: - Notification View

struct NotificationView: View {
    let style: VoiceStep.NotificationStyle
    let message: String
    let textColor: Color

    var body: some View {
        Group {
            switch style {
            case .imessage:
                IMessageNotification(message: message)
            case .twitch:
                TwitchNotification(message: message)
            case .instagram:
                InstagramNotification(message: message)
            case .push:
                PushNotification(message: message)
            case .discord:
                DiscordNotification(message: message)
            case .tiktok:
                TikTokNotification(message: message)
            }
        }
        .opacity(0.9)
    }
}

// MARK: - Notification Styles

struct IMessageNotification: View {
    let message: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Text("now")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#007AFF"))
        .cornerRadius(10)
        .frame(minWidth: 200, maxWidth: 280)
    }
}

struct TwitchNotification: View {
    let message: String
    var body: some View {
        HStack(spacing: 4) {
            Text("BigBruh: ")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "#9146FF"))
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(hex: "#18181b"))
        .cornerRadius(6)
        .frame(minWidth: 180, maxWidth: 250)
    }
}

struct InstagramNotification: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "#E4405F"))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("B")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("bigbruh_official")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#262626"))
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .frame(minWidth: 220, maxWidth: 280)
    }
}

struct PushNotification: View {
    let message: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "#DC143C"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("B")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    )
                HStack {
                    Text("BigBruh")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("now")
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#666666"))
                }
            }
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(10)
        .background(Color(hex: "#1a1a1a"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#333333"), lineWidth: 1)
        )
        .frame(minWidth: 240, maxWidth: 300)
    }
}

struct DiscordNotification: View {
    let message: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "#5865F2"))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("B")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("BigBruh")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#dcddde"))
            }
        }
        .padding(8)
        .background(Color(hex: "#36393f"))
        .cornerRadius(8)
        .frame(minWidth: 210, maxWidth: 280)
    }
}

struct TikTokNotification: View {
    let message: String
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: "#FF0050"))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("B")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text("@bigbruh")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
        }
        .padding(8)
        .background(Color(hex: "#161823"))
        .cornerRadius(8)
        .frame(minWidth: 200, maxWidth: 260)
    }
}

// MARK: - Audio Recorder Manager

class AudioRecorderManager: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?

    func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("✅ Microphone permission granted")
            } else {
                print("❌ Microphone permission denied")
            }
        }
    }

    func startRecording() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            recordingURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: recordingURL!, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            print("📹 Recording started")
            return true

        } catch {
            print("❌ Failed to start recording: \(error)")
            return false
        }
    }

    func pauseRecording() {
        audioRecorder?.pause()
        print("⏸ Recording paused")
    }

    func resumeRecording() -> Bool {
        audioRecorder?.record()
        print("▶️ Recording resumed")
        return true
    }

    func stopRecording() -> Data? {
        audioRecorder?.stop()

        guard let url = recordingURL else {
            print("❌ No recording URL")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            print("✅ Recording stopped - \(data.count) bytes")

            // Clean up
            try? FileManager.default.removeItem(at: url)

            return data
        } catch {
            print("❌ Failed to read recording: \(error)")
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    VoiceStep(
        step: StepDefinition(
            id: 10,
            phase: .excuseDiscovery,
            type: .voice,
            prompt: "SAY IT OUT LOUD OR STAY STUCK.",
            dbField: ["voice_excuse"],
            options: nil,
            helperText: "Record your biggest excuse. No filters. Raw truth.",
            sliders: nil,
            minDuration: 5,
            requiredPhrase: nil,
            displayType: nil
        ),
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#90FD0E"),
        secondaryAccentColor: Color(hex: "#7ADC0B"),
        onContinue: { _ in print("Continue") }
    )
}

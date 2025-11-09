//
//  VoiceRecorderView.swift
//  bigbruhh
//
//  Voice recording component adapted from VoiceStep
//  Full featured with hostile messages, notifications, pause/resume
//

import SwiftUI
import AVFoundation

struct VoiceRecorderView: View {
    let minDuration: Int?
    let maxDuration: Int?
    let onRecordingComplete: (URL) -> Void
    var accentColor: Color = .brutalRed // Default red to match other onboarding buttons
    var backgroundColor: Color = .black
    var textColor: Color = .white

    @State private var audioRecorder = AudioRecorderManager()
    @Environment(\.presentationMode) var presentationMode

    @State private var phase: RecordingPhase = .ready
    @State private var isRecording: Bool = false
    @State private var isPaused: Bool = false
    @State private var recordingDuration: Int = 0
    @State private var currentMessage: String = ""
    @State private var notificationStyle: NotificationStyle = .imessage

    @State private var recordingTimer: Timer?
    @State private var messageTimer: Timer?

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
                // Title at top
                if let min = minDuration {
                    Text("Record at least \(min) seconds")
                        .font(.system(size: 14))
                        .foregroundColor(textColor.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                        .padding(.bottom, 20)
                }

                Spacer()

                // Center content area - nothing when ready, timer when recording
                VStack(spacing: 0) {
                    if isRecording || isPaused || recordingDuration > 0 {
                        VStack(spacing: 8) {
                            Text(formatTime(recordingDuration))
                                .font(.system(size: 48, weight: .bold))
                                .tracking(4)
                                .foregroundColor(textColor)

                            Text(isPaused ? "PAUSED" : (isRecording ? "RECORDING" : "STOPPED"))
                                .font(.system(size: 14, weight: .bold))
                                .tracking(2)
                                .foregroundColor(isPaused ? Color(hex: "#FF6B6B") : textColor.opacity(0.7))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 120)

                Spacer()
            }

            // RECORD button - ABSOLUTELY POSITIONED AT BOTTOM (when ready)
            if !isRecording && !isPaused && recordingDuration == 0 {
                VStack {
                    Spacer()
                    Button(action: startRecording) {
                        HStack(spacing: 12) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 24))
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
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .applyVoiceGlassEffect(prominent: false, accentColor: accentColor)

                        // Submit button - primary action when enabled
                        Button(action: handleSubmit) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(canSubmit ? Color.buttonTextColor(for: accentColor) : nil)
                                Text(canSubmit ? "SUBMIT" : "NEED \(minDuration! - recordingDuration)s")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(canSubmit ? Color.buttonTextColor(for: accentColor) : nil)
                                    .tracking(1)
                                    .textCase(.uppercase)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                        .applyVoiceGlassEffect(prominent: canSubmit, accentColor: accentColor)
                        .disabled(!canSubmit)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }

            // Notification overlay (converted style)
            NotificationView(style: convertNotificationStyle(notificationStyle), message: currentMessage, textColor: textColor)
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
        guard canSubmit else { return }

        isRecording = false
        isPaused = false
        phase = .processing

        cleanupTimers()
        triggerHaptic(intensity: 1.0)

        Task {
            do {
                guard let audioData = audioRecorder.stopRecording() else {
                    throw NSError(domain: "VoiceRecorderView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio data"])
                }

                // Save audio file
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let audioFileName = "voice_\(Date().timeIntervalSince1970).m4a"
                let audioFileURL = documentsPath.appendingPathComponent(audioFileName)

                try audioData.write(to: audioFileURL)
                print("✅ Audio saved to: \(audioFileURL.path)")

                phase = .complete
                onRecordingComplete(audioFileURL)
                presentationMode.wrappedValue.dismiss()

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

    private var canSubmit: Bool {
        guard let min = minDuration else { return recordingDuration > 0 }
        return recordingDuration >= min
    }

    // Convert local NotificationStyle to the global NotificationStyle
    private func convertNotificationStyle(_ style: NotificationStyle) -> VoiceStep.NotificationStyle {
        switch style {
        case .imessage: return .imessage
        case .twitch: return .twitch
        case .instagram: return .instagram
        case .push: return .push
        case .discord: return .discord
        case .tiktok: return .tiktok
        }
    }
}

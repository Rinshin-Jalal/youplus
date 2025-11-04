//
//  TwoFuturesInputView.swift
//  bigbruhh
//
//  Input view for Two Futures onboarding
//

import SwiftUI
import AVFoundation

struct TwoFuturesInputView: View {
    let config: InputConfig
    let onSubmit: (String) -> Void

    @State private var answer: String = ""
    @State private var selectedChoice: String?
    @State private var selectedTime: Date = Date()
    @State private var selectedNumber: Int = 0

    // Voice recording state
    @State private var audioRecorder = AudioRecorderManager()
    @State private var isRecording: Bool = false
    @State private var isPaused: Bool = false
    @State private var recordingDuration: Int = 0
    @State private var voiceRecordingURL: URL?
    @State private var recordingTimer: Timer?

    // Keyboard state
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Scrollable content area
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 60)

                        // Question
                        Text(resolveQuestion())
                            .font(.headlineMedium)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)

                        // Helper text
                        if let helperText = config.helperText {
                            Text(helperText)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 24)
                        }

                        Spacer()
                            .frame(height: 40)
                    }
                }

                // Input at bottom (sticks to keyboard for text)
                if case .text = config.inputType {
                    inputView
                        .padding(.bottom, keyboardHeight)
                        .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                } else if case .voice = config.inputType {
                    voiceControlsAtBottom
                } else {
                    VStack(spacing: 16) {
                        inputView

                        // Continue button for non-text/voice inputs (but not choice)
                        if case .choice = config.inputType {
                            EmptyView()
                        } else {
                            VStack(spacing: 12) {
                                // Continue button
                                Group {
                                    if #available(iOS 26, *) {
                                        Button(action: handleSubmit) {
                                            Text("Continue")
                                                .font(.bodyBold)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                        }
                                        .buttonStyle(.glassProminent)
                                    } else {
                                        Button(action: handleSubmit) {
                                            Text("Continue")
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.white.opacity(0.1))
                                                .cornerRadius(30)
                                        }
                                    }
                                }
                                .disabled(!isValid)
                                .opacity(isValid ? 1.0 : 0.5)

                                // Skip button (if allowed)
                                if config.skipAllowed {
                                    Button("Skip") {
                                        onSubmit("")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                            .padding(.top, 16)
                            .background(Color.black)
                        }
                    }
                    .background(Color.black)
                }
            }
        }
        .onAppear {
            resetInputState()
            setupKeyboardObservers()
        }
        .onDisappear {
            cleanupVoiceRecording()
            removeKeyboardObservers()
        }
    }

    @ViewBuilder
    private var inputView: some View {
        switch config.inputType {
        case .text(let placeholder):
            textInputView(placeholder: placeholder)
        case .voice:
            voiceInputView()
        case .choice(let options):
            choiceInputView(options: options)
        case .timePicker:
            timePickerView()
        case .datePicker:
            datePickerView()
        case .numberStepper(let range):
            numberStepperView(range: range)
        }
    }

    private func textInputView(placeholder: String?) -> some View {
        Group {
            if #available(iOS 26, *) {
                TextField(placeholder ?? "Your answer...", text: $answer)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .glassEffect(in: .rect(cornerRadius: 30))
                    .padding(.horizontal, 24)
                    .onSubmit {
                        if !answer.isEmpty {
                            handleSubmit()
                        }
                    }
            } else {
                TextField(placeholder ?? "Your answer...", text: $answer)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(30)
                    .padding(.horizontal, 24)
                    .onSubmit {
                        if !answer.isEmpty {
                            handleSubmit()
                        }
                    }
            }
        }
    }

    private func choiceInputView(options: [String]) -> some View {
        VStack(spacing: 16) {
            ForEach(options, id: \.self) { option in
                Group {
                    if #available(iOS 26, *) {
                        Button(action: {
                            selectedChoice = option
                            // Auto-continue after short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                handleSubmit()
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if selectedChoice == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    
                        }
                        .buttonStyle(.glass)
                    } else {
                        Button(action: {
                            selectedChoice = option
                            // Auto-continue after short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                handleSubmit()
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if selectedChoice == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: selectedChoice == option ?
                                    [Color(hex: "#4ECDC4"), Color(hex: "#3ab8b0")] :
                                    [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        selectedChoice == option ?
                                        Color.white.opacity(0.3) :
                                        Color.white.opacity(0.1),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func timePickerView() -> some View {
        Group {
            if #available(iOS 26, *) {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                }
                .glassEffect(in: .rect(cornerRadius: 30))
                .padding(.horizontal, 24)
            } else {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(30)
                .padding(.horizontal, 24)
            }
        }
    }

    private func datePickerView() -> some View {
        Group {
            if #available(iOS 26, *) {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                }
                .glassEffect(in: .rect(cornerRadius: 30))
                .padding(.horizontal, 24)
            } else {
                VStack {
                    DatePicker(
                        "",
                        selection: $selectedTime,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding()
                }
                .background(Color.white.opacity(0.1))
                .cornerRadius(30)
                .padding(.horizontal, 24)
            }
        }
    }

    private func numberStepperView(range: ClosedRange<Int>) -> some View {
        Group {
            if #available(iOS 26, *) {
                VStack(spacing: 20) {
                    Text("\(selectedNumber)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "#4ECDC4"))

                    Slider(
                        value: Binding(
                            get: { Double(selectedNumber) },
                            set: { selectedNumber = Int($0) }
                        ),
                        in: Double(range.lowerBound)...Double(range.upperBound),
                        step: 1
                    )
                    .tint(Color(hex: "#4ECDC4"))
                }
                .padding()
                .glassEffect(in: .rect(cornerRadius: 30))
                .padding(.horizontal, 24)
                .onAppear {
                    if selectedNumber < range.lowerBound || selectedNumber > range.upperBound {
                        selectedNumber = range.lowerBound
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("\(selectedNumber)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "#4ECDC4"))

                    Slider(
                        value: Binding(
                            get: { Double(selectedNumber) },
                            set: { selectedNumber = Int($0) }
                        ),
                        in: Double(range.lowerBound)...Double(range.upperBound),
                        step: 1
                    )
                    .tint(Color(hex: "#4ECDC4"))
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(30)
                .padding(.horizontal, 24)
                .onAppear {
                    if selectedNumber < range.lowerBound || selectedNumber > range.upperBound {
                        selectedNumber = range.lowerBound
                    }
                }
            }
        }
    }

    private func voiceInputView() -> some View {
        EmptyView()
    }

    @ViewBuilder
    private var voiceControlsAtBottom: some View {
        VStack(spacing: 12) {
            // Timer display (always visible when recording or recorded)
            if isRecording || isPaused || recordingDuration > 0 {
                Text(formatTime(recordingDuration))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            
            if !isRecording && !isPaused && recordingDuration == 0 {
                // RECORD button (initial state)
                Button(action: startVoiceRecording) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 24))
                        Text("RECORD")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(1.5)
                    }
                    .foregroundColor(Color.buttonTextColor(for: Color(hex: "#4A90E2")))
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                }
                .applyVoiceGlassEffect(prominent: true, accentColor: Color(hex: "#4A90E2"))
            } else {
                // Recording controls
                HStack(spacing: 12) {
                    // Pause/Resume button
                    Button(action: isRecording ? pauseVoiceRecording : resumeVoiceRecording) {
                        HStack(spacing: 8) {
                            Image(systemName: isRecording ? "pause.fill" : "play.fill")
                                .font(.system(size: 14))
                            Text(isRecording ? "PAUSE" : "RESUME")
                                .font(.system(size: 14, weight: .bold))
                                .tracking(1)
                                .textCase(.uppercase)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                    .applyVoiceGlassEffect(prominent: false, accentColor: Color(hex: "#4A90E2"))

                    // Submit button with remaining time
                    Button(action: { stopVoiceRecording(); handleSubmit() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14))
                                .foregroundColor(canSubmitVoice ? Color.buttonTextColor(for: Color(hex: "#4A90E2")) : nil)
                            Text(canSubmitVoice ? "SUBMIT" : voiceSubmitText)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(canSubmitVoice ? Color.buttonTextColor(for: Color(hex: "#4A90E2")) : nil)
                                .tracking(1)
                                .textCase(.uppercase)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                    }
                    .applyVoiceGlassEffect(prominent: canSubmitVoice, accentColor: Color(hex: "#4A90E2"))
                    .disabled(!canSubmitVoice)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .padding(.top, 16)
        .background(Color.black)
    }

    private var isValid: Bool {
        switch config.inputType {
        case .text:
            return !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voice:
            return voiceRecordingURL != nil
        case .choice:
            return selectedChoice != nil
        case .timePicker:
            return true
        case .datePicker:
            return true
        case .numberStepper:
            return true
        }
    }

    private func handleSubmit() {
        let result: String

        switch config.inputType {
        case .text:
            result = answer
        case .voice:
            result = voiceRecordingURL?.absoluteString ?? ""
        case .choice:
            result = selectedChoice ?? ""
        case .timePicker:
            result = ISO8601DateFormatter().string(from: selectedTime)
        case .datePicker:
            result = ISO8601DateFormatter().string(from: selectedTime)
        case .numberStepper:
            result = "\(selectedNumber)"
        }

        onSubmit(result)
    }

    private func resolveQuestion() -> String {
        // Replace placeholders - will be enhanced in main container
        return config.question
    }

    // MARK: - Voice Recording Computed Properties

    private var canSubmitVoice: Bool {
        guard case .voice(let minDuration, _) = config.inputType else { return false }
        guard let min = minDuration else { return recordingDuration > 0 }
        return recordingDuration >= min
    }

    private var voiceSubmitText: String {
        guard case .voice(let minDuration, _) = config.inputType else { return "SUBMIT" }
        guard let min = minDuration else { return "SUBMIT" }
        let remaining = min - recordingDuration
        return remaining > 0 ? "NEED \(remaining)s" : "SUBMIT"
    }

    // MARK: - Voice Recording Methods

    private func startVoiceRecording() {
        audioRecorder.requestPermission()
        guard audioRecorder.startRecording() else { return }

        isRecording = true
        isPaused = false
        recordingDuration = 0

        // Start recording timer
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }

        triggerHaptic(intensity: 1.0)
    }

    private func pauseVoiceRecording() {
        audioRecorder.pauseRecording()
        isRecording = false
        isPaused = true
        recordingTimer?.invalidate()
        triggerHaptic(intensity: 0.5)
    }

    private func resumeVoiceRecording() {
        guard audioRecorder.resumeRecording() else { return }

        isRecording = true
        isPaused = false

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingDuration += 1
        }

        triggerHaptic(intensity: 0.5)
    }

    private func stopVoiceRecording() {
        isRecording = false
        isPaused = false
        recordingTimer?.invalidate()

        guard let audioData = audioRecorder.stopRecording() else { return }

        // Save audio file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFileName = "voice_\(Date().timeIntervalSince1970).m4a"
        let audioFileURL = documentsPath.appendingPathComponent(audioFileName)

        do {
            try audioData.write(to: audioFileURL)
            print("✅ Audio saved to: \(audioFileURL.path)")
            voiceRecordingURL = audioFileURL
        } catch {
            print("❌ Failed to save audio file: \(error)")
        }

        triggerHaptic(intensity: 1.0)
    }

    private func cleanupVoiceRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        if seconds == 1 {
            return "1 second"
        } else {
            return "\(seconds) seconds"
        }
    }

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
    
    private func resetInputState() {
        // Reset all input states when view appears with new configuration
        answer = ""
        selectedChoice = nil
        selectedTime = Date()
        selectedNumber = 0

        // Stop any ongoing recording
        if isRecording {
            let _ = audioRecorder.stopRecording()
            isRecording = false
            isPaused = false
        }

        // Reset recording state
        recordingDuration = 0
        voiceRecordingURL = nil
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    // MARK: - Keyboard Observers

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            keyboardHeight = keyboardFrame.height
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

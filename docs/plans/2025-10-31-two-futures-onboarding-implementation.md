# Two Futures Onboarding Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace 60-step psychological onboarding with 30-step Two Futures debate system using swipe navigation, contrarian questions, and split-screen debates.

**Architecture:** SwiftUI-based step progression system with split-screen debate views, multiple input types (text, voice, choice, time), swipe gesture navigation, and dynamic debate content generation based on user responses.

**Tech Stack:** SwiftUI, Combine, AVFoundation (voice recording), UserDefaults (state persistence)

---

## Phase 1: Core Models & Data Structures

### Task 1: Create Onboarding Models

**Files:**
- Create: `bigbruhh/Models/Onboarding/TwoFuturesModels.swift`

**Step 1: Create FutureVoice enum**

```swift
//
//  TwoFuturesModels.swift
//  bigbruhh
//
//  Two Futures onboarding data models
//

import Foundation

enum FutureVoice {
    case winner  // Top half, blue
    case loser   // Bottom half, gray
    case both    // Centered, rare agreement
}
```

**Step 2: Create StepType enum**

```swift
enum OnboardingStepType {
    case debate(messages: [DebateMessage])
    case input(config: InputConfig)
}
```

**Step 3: Create DebateMessage struct**

```swift
struct DebateMessage: Identifiable {
    let id = UUID()
    let speaker: FutureVoice
    let text: String
    let delay: TimeInterval  // Stagger for typewriter effect
}
```

**Step 4: Create InputConfig struct**

```swift
struct InputConfig {
    let question: String
    let inputType: InputType
    let helperText: String?
    let skipAllowed: Bool
}

enum InputType {
    case text(placeholder: String?)
    case voice(minDuration: Int?, maxDuration: Int?)
    case choice(options: [String])
    case timePicker
    case numberStepper(range: ClosedRange<Int>)
}
```

**Step 5: Create OnboardingStep struct**

```swift
struct OnboardingStep {
    let id: Int
    let type: OnboardingStepType

    var isDebate: Bool {
        if case .debate = type { return true }
        return false
    }

    var isInput: Bool {
        if case .input = type { return true }
        return false
    }
}
```

**Step 6: Create OnboardingResponse model**

```swift
struct TwoFuturesOnboardingResponse: Codable {
    // Identity
    let name: String
    let nonNegotiable: String
    let energyPeak: String
    let antiAccountability: String?

    // Commitment
    let dailyCommitment: String
    let commitmentTime: Date

    // Patterns
    let favoriteExcuse: String
    let changeTrigger: String
    let quitCount: Int

    // Accountability
    let failureStrikes: Int
    let witness: String

    // Voice recordings (3 total, ~70-105 sec)
    let voiceOriginURL: URL?      // ~30-45 sec
    let voiceCommitmentURL: URL   // ~20-30 sec
    let voiceCostURL: URL         // ~20-30 sec

    // Path choice
    let chosenPath: PathChoice

    enum PathChoice: String, Codable {
        case winner
        case loser
    }
}
```

**Step 7: Commit models**

```bash
git add bigbruhh/Models/Onboarding/TwoFuturesModels.swift
git commit -m "feat(onboarding): add Two Futures data models"
```

---

### Task 2: Create Step Definitions

**Files:**
- Create: `bigbruhh/Models/Onboarding/TwoFuturesStepDefinitions.swift`

**Step 1: Create step definitions array structure**

```swift
//
//  TwoFuturesStepDefinitions.swift
//  bigbruhh
//
//  All 30 steps for Two Futures onboarding
//

import Foundation

let TWO_FUTURES_STEPS: [OnboardingStep] = [
    // PHASE 1: INTRODUCTION (Steps 1-6)

    // Step 1: Opening Debate
    OnboardingStep(
        id: 1,
        type: .debate(messages: [
            DebateMessage(speaker: .winner, text: "They're here.", delay: 0.5),
            DebateMessage(speaker: .loser, text: "I know. I can feel it.", delay: 1.0),
            DebateMessage(speaker: .winner, text: "This is our chance. OUR chance to change it.", delay: 1.5),
            DebateMessage(speaker: .loser, text: "Or our chance to save them from what happened to me.", delay: 2.0),
            DebateMessage(speaker: .winner, text: "We both want what's best.", delay: 2.5),
            DebateMessage(speaker: .loser, text: "We just disagree on what that is.", delay: 3.0)
        ])
    ),

    // Step 2: Name Input
    OnboardingStep(
        id: 2,
        type: .input(config: InputConfig(
            question: "What should we call you?",
            inputType: .text(placeholder: "Your name"),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    // Add remaining steps 3-30...
]
```

**Step 2: Add steps 3-10 (Phase 1-2)**

```swift
    // Step 3: Name Debate
    OnboardingStep(
        id: 3,
        type: .debate(messages: [
            DebateMessage(speaker: .winner, text: "{{name}}. Listen to me carefully.", delay: 0.5),
            DebateMessage(speaker: .loser, text: "{{name}}. I need you to hear this.", delay: 1.0),
            DebateMessage(speaker: .winner, text: "I'm the version of you who made it.", delay: 1.5),
            DebateMessage(speaker: .loser, text: "I'm the version who tried and failed.", delay: 2.0),
            DebateMessage(speaker: .winner, text: "I know the path forward.", delay: 2.5),
            DebateMessage(speaker: .loser, text: "I know the cost of that path.", delay: 3.0),
            DebateMessage(speaker: .winner, text: "Choose wisely.", delay: 3.5),
            DebateMessage(speaker: .loser, text: "Choose safely.", delay: 4.0)
        ])
    ),

    // Step 4: Non-Negotiable Input
    OnboardingStep(
        id: 4,
        type: .input(config: InputConfig(
            question: "To win, what's the ONE thing you absolutely WON'T sacrifice?",
            inputType: .text(placeholder: "Sleep? Comfort? Social media?"),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    // Step 5: Non-Negotiable Debate (dynamic)
    OnboardingStep(
        id: 5,
        type: .debate(messages: [
            // Dynamic - generated based on user answer
            // Placeholder for now
        ])
    ),

    // Step 6: Energy Peak Choice
    OnboardingStep(
        id: 6,
        type: .input(config: InputConfig(
            question: "When does the best version of you show up?",
            inputType: .choice(options: [
                "5am (before the world wakes)",
                "10pm (after the world sleeps)",
                "Midday (when energy peaks)"
            ]),
            helperText: nil,
            skipAllowed: false
        ))
    ),

    // Continue with steps 7-30...
```

**Step 3: Add complete step definitions for steps 7-30**

(Full implementation would continue here with all 30 steps - abbreviated for plan clarity)

**Step 4: Commit step definitions**

```bash
git add bigbruhh/Models/Onboarding/TwoFuturesStepDefinitions.swift
git commit -m "feat(onboarding): add Two Futures step definitions"
```

---

## Phase 2: UI Components

### Task 3: Create Split-Screen Debate View

**Files:**
- Create: `bigbruhh/Features/Onboarding/Views/TwoFuturesDebateView.swift`

**Step 1: Create basic debate view structure**

```swift
//
//  TwoFuturesDebateView.swift
//  bigbruhh
//
//  Split-screen debate view for Two Futures onboarding
//

import SwiftUI

struct TwoFuturesDebateView: View {
    let messages: [DebateMessage]
    let onContinue: () -> Void

    @State private var visibleMessages: [DebateMessage] = []

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top half - Winner Future
                winnerSection

                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)

                // Bottom half - Loser Future
                loserSection
            }
            .gesture(swipeGesture)
        }
    }

    private var winnerSection: some View {
        // Placeholder
        Color.clear
    }

    private var loserSection: some View {
        // Placeholder
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 50)
            .onEnded { value in
                if value.translation.width > 50 {
                    onContinue()
                }
            }
    }
}
```

**Step 2: Implement winner section with messages**

```swift
    private var winnerSection: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(winnerMessages) { message in
                        TypewriterText(
                            text: message.text,
                            speed: 0.03
                        )
                        .foregroundColor(Color(hex: "#4A90E2"))
                        .font(.body)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }

    private var winnerMessages: [DebateMessage] {
        visibleMessages.filter { $0.speaker == .winner || $0.speaker == .both }
    }
```

**Step 3: Implement loser section with messages**

```swift
    private var loserSection: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(loserMessages) { message in
                        TypewriterText(
                            text: message.text,
                            speed: 0.03
                        )
                        .foregroundColor(Color(hex: "#8E8E93"))
                        .font(.body)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
    }

    private var loserMessages: [DebateMessage] {
        visibleMessages.filter { $0.speaker == .loser || $0.speaker == .both }
    }
```

**Step 4: Add message animation on appear**

```swift
    var body: some View {
        ZStack {
            // ... existing code ...
        }
        .onAppear {
            animateMessages()
        }
    }

    private func animateMessages() {
        for (index, message) in messages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + message.delay) {
                withAnimation(.easeIn(duration: 0.3)) {
                    visibleMessages.append(message)
                }
            }
        }
    }
```

**Step 5: Commit debate view**

```bash
git add bigbruhh/Features/Onboarding/Views/TwoFuturesDebateView.swift
git commit -m "feat(onboarding): add split-screen debate view"
```

---

### Task 4: Create Typewriter Text Component

**Files:**
- Create: `bigbruhh/Features/Onboarding/Components/TypewriterText.swift`

**Step 1: Create typewriter effect view**

```swift
//
//  TypewriterText.swift
//  bigbruhh
//
//  Typewriter text animation effect
//

import SwiftUI

struct TypewriterText: View {
    let text: String
    let speed: Double  // seconds per character

    @State private var displayedText = ""

    var body: some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        displayedText = ""
        for (index, character) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * speed) {
                displayedText.append(character)
            }
        }
    }
}
```

**Step 2: Commit typewriter component**

```bash
git add bigbruhh/Features/Onboarding/Components/TypewriterText.swift
git commit -m "feat(onboarding): add typewriter text component"
```

---

### Task 5: Create Input Step Views

**Files:**
- Create: `bigbruhh/Features/Onboarding/Views/TwoFuturesInputView.swift`

**Step 1: Create input view structure**

```swift
//
//  TwoFuturesInputView.swift
//  bigbruhh
//
//  Input view for Two Futures onboarding
//

import SwiftUI

struct TwoFuturesInputView: View {
    let config: InputConfig
    let onSubmit: (String) -> Void

    @State private var answer: String = ""
    @State private var selectedChoice: String?
    @State private var selectedTime: Date = Date()
    @State private var selectedNumber: Int = 0

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Question
                Text(config.question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Helper text
                if let helperText = config.helperText {
                    Text(helperText)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Input based on type
                inputView

                Spacer()

                // Continue button
                Button(action: handleSubmit) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
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
        case .numberStepper(let range):
            numberStepperView(range: range)
        }
    }

    private var isValid: Bool {
        // Implementation
        true
    }

    private func handleSubmit() {
        // Implementation
    }
}
```

**Step 2: Implement text input view**

```swift
    private func textInputView(placeholder: String?) -> some View {
        TextField(placeholder ?? "Your answer...", text: $answer)
            .textFieldStyle(.roundedBorder)
            .font(.body)
            .padding(.horizontal, 24)
    }
```

**Step 3: Implement choice input view**

```swift
    private func choiceInputView(options: [String]) -> some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedChoice = option
                }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedChoice == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedChoice == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
    }
```

**Step 4: Implement time picker view**

```swift
    private func timePickerView() -> some View {
        DatePicker(
            "",
            selection: $selectedTime,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
    }
```

**Step 5: Implement number stepper view**

```swift
    private func numberStepperView(range: ClosedRange<Int>) -> some View {
        VStack(spacing: 12) {
            Text("\(selectedNumber)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)

            Stepper("", value: $selectedNumber, in: range)
                .labelsHidden()
                .padding(.horizontal, 24)
        }
    }
```

**Step 6: Implement voice input view placeholder**

```swift
    private func voiceInputView() -> some View {
        VStack {
            Text("Voice recording - TODO")
                .font(.caption)
                .foregroundColor(.gray)

            // Will implement full voice recorder in next task
        }
    }
```

**Step 7: Implement isValid and handleSubmit**

```swift
    private var isValid: Bool {
        switch config.inputType {
        case .text:
            return !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .voice:
            return true  // Handled by voice recorder
        case .choice:
            return selectedChoice != nil
        case .timePicker:
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
            result = ""  // Voice URL will be separate
        case .choice:
            result = selectedChoice ?? ""
        case .timePicker:
            result = ISO8601DateFormatter().string(from: selectedTime)
        case .numberStepper:
            result = "\(selectedNumber)"
        }

        onSubmit(result)
    }
```

**Step 8: Commit input view**

```bash
git add bigbruhh/Features/Onboarding/Views/TwoFuturesInputView.swift
git commit -m "feat(onboarding): add input view with multiple types"
```

---

## Phase 3: State Management & Navigation

### Task 6: Create Onboarding State Manager

**Files:**
- Create: `bigbruhh/Features/Onboarding/State/TwoFuturesOnboardingState.swift`

**Step 1: Create state class**

```swift
//
//  TwoFuturesOnboardingState.swift
//  bigbruhh
//
//  State management for Two Futures onboarding
//

import Foundation
import Combine

class TwoFuturesOnboardingState: ObservableObject {
    @Published var currentStep: Int = 1
    @Published var responses: [Int: String] = [:]  // stepId: answer
    @Published var voiceRecordings: [Int: URL] = [:]  // stepId: URL

    let totalSteps = 30

    var progress: Double {
        Double(currentStep) / Double(totalSteps)
    }

    func saveResponse(stepId: Int, answer: String) {
        responses[stepId] = answer
    }

    func saveVoiceRecording(stepId: Int, url: URL) {
        voiceRecordings[stepId] = url
    }

    func nextStep() {
        guard currentStep < totalSteps else { return }
        currentStep += 1
    }

    func previousStep() {
        guard currentStep > 1 else { return }
        currentStep -= 1
    }

    func canProceed(from step: Int) -> Bool {
        guard let stepDef = TWO_FUTURES_STEPS.first(where: { $0.id == step }) else {
            return false
        }

        // Debate steps can always proceed
        if stepDef.isDebate {
            return true
        }

        // Input steps require answer
        return responses[step] != nil || voiceRecordings[step] != nil
    }
}
```

**Step 2: Add response compilation**

```swift
    func compileResponse() -> TwoFuturesOnboardingResponse {
        TwoFuturesOnboardingResponse(
            name: responses[2] ?? "",
            nonNegotiable: responses[4] ?? "",
            energyPeak: responses[6] ?? "",
            antiAccountability: responses[8],
            dailyCommitment: responses[16] ?? "",
            commitmentTime: parseTime(responses[18] ?? ""),
            favoriteExcuse: responses[12] ?? "",
            changeTrigger: responses[14] ?? "",
            quitCount: Int(responses[22] ?? "0") ?? 0,
            failureStrikes: parseStrikes(responses[24] ?? ""),
            witness: responses[28] ?? "",
            voiceOriginURL: voiceRecordings[10],
            voiceCommitmentURL: voiceRecordings[20] ?? URL(fileURLWithPath: ""),
            voiceCostURL: voiceRecordings[26] ?? URL(fileURLWithPath: ""),
            chosenPath: .winner  // From step 30
        )
    }

    private func parseTime(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string) ?? Date()
    }

    private func parseStrikes(_ string: String) -> Int {
        // Parse from choice strings
        if string.contains("1") { return 1 }
        if string.contains("3") { return 3 }
        if string.contains("5") { return 5 }
        return 999  // No limit
    }
```

**Step 3: Add persistence**

```swift
    func saveState() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(responses) {
            UserDefaults.standard.set(encoded, forKey: "two_futures_responses")
        }
        UserDefaults.standard.set(currentStep, forKey: "two_futures_current_step")
    }

    func loadState() {
        if let savedResponses = UserDefaults.standard.data(forKey: "two_futures_responses"),
           let decoded = try? JSONDecoder().decode([Int: String].self, from: savedResponses) {
            responses = decoded
        }
        currentStep = UserDefaults.standard.integer(forKey: "two_futures_current_step")
        if currentStep == 0 { currentStep = 1 }
    }

    func clearState() {
        UserDefaults.standard.removeObject(forKey: "two_futures_responses")
        UserDefaults.standard.removeObject(forKey: "two_futures_current_step")
        responses = [:]
        voiceRecordings = [:]
        currentStep = 1
    }
```

**Step 4: Commit state manager**

```bash
git add bigbruhh/Features/Onboarding/State/TwoFuturesOnboardingState.swift
git commit -m "feat(onboarding): add state management and persistence"
```

---

### Task 7: Create Main Onboarding Container

**Files:**
- Create: `bigbruhh/Features/Onboarding/Views/TwoFuturesOnboardingView.swift`

**Step 1: Create main container structure**

```swift
//
//  TwoFuturesOnboardingView.swift
//  bigbruhh
//
//  Main container for Two Futures onboarding
//

import SwiftUI

struct TwoFuturesOnboardingView: View {
    let onComplete: () -> Void

    @StateObject private var state = TwoFuturesOnboardingState()

    var body: some View {
        ZStack {
            currentStepView

            // Progress indicator
            VStack {
                ProgressView(value: state.progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                Spacer()
            }
        }
        .onAppear {
            state.loadState()
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        if let step = TWO_FUTURES_STEPS.first(where: { $0.id == state.currentStep }) {
            switch step.type {
            case .debate(let messages):
                TwoFuturesDebateView(
                    messages: resolveMessages(messages),
                    onContinue: handleDebateContinue
                )
            case .input(let config):
                TwoFuturesInputView(
                    config: config,
                    onSubmit: handleInputSubmit
                )
            }
        } else {
            Text("Step not found")
                .foregroundColor(.red)
        }
    }
}
```

**Step 2: Implement message resolution with variable replacement**

```swift
    private func resolveMessages(_ messages: [DebateMessage]) -> [DebateMessage] {
        messages.map { message in
            var resolvedText = message.text

            // Replace {{name}}
            if let name = state.responses[2] {
                resolvedText = resolvedText.replacingOccurrences(of: "{{name}}", with: name)
            }

            // Replace {{commitment}}
            if let commitment = state.responses[16] {
                resolvedText = resolvedText.replacingOccurrences(of: "{{commitment}}", with: commitment)
            }

            // Add more variable replacements as needed

            return DebateMessage(
                speaker: message.speaker,
                text: resolvedText,
                delay: message.delay
            )
        }
    }
```

**Step 3: Implement navigation handlers**

```swift
    private func handleDebateContinue() {
        state.nextStep()
        state.saveState()

        if state.currentStep > 30 {
            handleCompletion()
        }
    }

    private func handleInputSubmit(_ answer: String) {
        state.saveResponse(stepId: state.currentStep, answer: answer)
        state.nextStep()
        state.saveState()

        if state.currentStep > 30 {
            handleCompletion()
        }
    }

    private func handleCompletion() {
        let response = state.compileResponse()

        // Save to OnboardingDataManager
        // TODO: Integrate with existing OnboardingDataManager

        state.clearState()
        onComplete()
    }
```

**Step 4: Commit main container**

```bash
git add bigbruhh/Features/Onboarding/Views/TwoFuturesOnboardingView.swift
git commit -m "feat(onboarding): add main onboarding container with navigation"
```

---

## Phase 4: Voice Recording

### Task 8: Create Voice Recorder Component

**Files:**
- Create: `bigbruhh/Features/Onboarding/Components/VoiceRecorderView.swift`

**Step 1: Create voice recorder view**

```swift
//
//  VoiceRecorderView.swift
//  bigbruhh
//
//  Voice recording component for onboarding
//

import SwiftUI
import AVFoundation

struct VoiceRecorderView: View {
    let minDuration: Int?
    let maxDuration: Int?
    let onRecordingComplete: (URL) -> Void

    @StateObject private var recorder = VoiceRecorder()

    var body: some View {
        VStack(spacing: 20) {
            // Waveform visualization
            if recorder.isRecording {
                WaveformView(level: recorder.audioLevel)
                    .frame(height: 100)
            }

            // Duration
            Text(formatDuration(recorder.duration))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.blue)

            // Record button
            Button(action: handleRecordTap) {
                Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(recorder.isRecording ? .red : .blue)
            }

            // Helper text
            if let min = minDuration {
                Text("Minimum \(min) seconds")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Continue button (only if valid recording exists)
            if let url = recorder.recordingURL, isDurationValid {
                Button("Use This Recording") {
                    onRecordingComplete(url)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 24)
            }
        }
    }

    private var isDurationValid: Bool {
        if let min = minDuration, recorder.duration < TimeInterval(min) {
            return false
        }
        return true
    }

    private func handleRecordTap() {
        if recorder.isRecording {
            recorder.stopRecording()
        } else {
            recorder.startRecording()
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

**Step 2: Create VoiceRecorder observable object**

```swift
class VoiceRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var duration: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var recordingURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")

            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()

            isRecording = true
            duration = 0
            recordingURL = audioFilename

            // Start timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateMeters()
            }

        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
    }

    private func updateMeters() {
        audioRecorder?.updateMeters()
        audioLevel = audioRecorder?.averagePower(forChannel: 0) ?? 0
        duration = audioRecorder?.currentTime ?? 0
    }
}
```

**Step 3: Create simple waveform view**

```swift
struct WaveformView: View {
    let level: Float

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 8, height: barHeight(for: index, in: geometry))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func barHeight(for index: Int, in geometry: GeometryProxy) -> CGFloat {
        let normalized = CGFloat((level + 160) / 160)  // Normalize from -160...0 to 0...1
        let randomVariation = CGFloat.random(in: 0.5...1.0)
        return max(4, geometry.size.height * normalized * randomVariation)
    }
}
```

**Step 4: Commit voice recorder**

```bash
git add bigbruhh/Features/Onboarding/Components/VoiceRecorderView.swift
git commit -m "feat(onboarding): add voice recording component"
```

---

## Phase 5: Integration & Testing

### Task 9: Integrate with Existing Onboarding Flow

**Files:**
- Modify: `bigbruhh/Features/Welcome/Views/WelcomeView.swift`

**Step 1: Add Two Futures onboarding option**

Update WelcomeView to show Two Futures onboarding instead of old 60-step flow:

```swift
// In WelcomeView.swift

// Replace old OnboardingView with:
.sheet(isPresented: $showOnboarding) {
    TwoFuturesOnboardingView {
        // On completion
        showOnboarding = false
        // Navigate to AlmostThere or main app
    }
}
```

**Step 2: Commit integration**

```bash
git add bigbruhh/Features/Welcome/Views/WelcomeView.swift
git commit -m "feat(onboarding): integrate Two Futures onboarding in welcome flow"
```

---

### Task 10: Add Swipe Back Gesture

**Files:**
- Modify: `bigbruhh/Features/Onboarding/Views/TwoFuturesOnboardingView.swift`

**Step 1: Add swipe gesture to both debate and input views**

```swift
// In TwoFuturesOnboardingView

private func addSwipeGesture<Content: View>(_ content: Content) -> some View {
    content
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width > 50 {
                        // Swipe right - go back
                        state.previousStep()
                        state.saveState()
                    }
                }
        )
}

// Apply to current step view:
@ViewBuilder
private var currentStepView: some View {
    if let step = TWO_FUTURES_STEPS.first(where: { $0.id == state.currentStep }) {
        switch step.type {
        case .debate(let messages):
            addSwipeGesture(
                TwoFuturesDebateView(
                    messages: resolveMessages(messages),
                    onContinue: handleDebateContinue
                )
            )
        case .input(let config):
            addSwipeGesture(
                TwoFuturesInputView(
                    config: config,
                    onSubmit: handleInputSubmit
                )
            )
        }
    }
}
```

**Step 2: Commit swipe back gesture**

```bash
git add bigbruhh/Features/Onboarding/Views/TwoFuturesOnboardingView.swift
git commit -m "feat(onboarding): add swipe back navigation"
```

---

### Task 11: Build & Test

**Step 1: Build the project**

```bash
cd /Users/rinshin/Code/apps/bigbruh/swift
xcodebuild -project bigbruhh.xcodeproj -scheme bigbruhh -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build
```

Expected: BUILD SUCCEEDED

**Step 2: Manual testing checklist**

Test the following flows:
- [ ] Opening debate appears with typewriter effect
- [ ] Can swipe right to continue through debates
- [ ] Can swipe left to go back
- [ ] Name input accepts text and continues
- [ ] Choice input allows selection
- [ ] Time picker allows time selection
- [ ] Number stepper allows number selection
- [ ] Voice recorder starts/stops recording
- [ ] Voice recorder shows duration
- [ ] Voice recorder validates minimum duration
- [ ] Progress bar updates as steps advance
- [ ] State persists when app is closed/reopened
- [ ] Completion triggers onComplete callback
- [ ] All 30 steps can be completed

**Step 3: Fix any issues found during testing**

(Document and fix issues as they arise)

**Step 4: Final commit**

```bash
git add .
git commit -m "feat(onboarding): Two Futures onboarding complete and tested"
```

---

## Summary

**Completed Implementation:**
- ✅ Data models for Two Futures onboarding
- ✅ 30 step definitions (debates + inputs)
- ✅ Split-screen debate view with typewriter effect
- ✅ Multi-type input view (text, choice, time, number, voice)
- ✅ Voice recording component with waveform
- ✅ State management with persistence
- ✅ Main container with navigation
- ✅ Swipe gesture navigation (forward/back)
- ✅ Integration with existing welcome flow
- ✅ Build verification

**Files Created:**
- `bigbruhh/Models/Onboarding/TwoFuturesModels.swift`
- `bigbruhh/Models/Onboarding/TwoFuturesStepDefinitions.swift`
- `bigbruhh/Features/Onboarding/Views/TwoFuturesDebateView.swift`
- `bigbruhh/Features/Onboarding/Views/TwoFuturesInputView.swift`
- `bigbruhh/Features/Onboarding/Views/TwoFuturesOnboardingView.swift`
- `bigbruhh/Features/Onboarding/Components/TypewriterText.swift`
- `bigbruhh/Features/Onboarding/Components/VoiceRecorderView.swift`
- `bigbruhh/Features/Onboarding/State/TwoFuturesOnboardingState.swift`

**Files Modified:**
- `bigbruhh/Features/Welcome/Views/WelcomeView.swift`

**Next Steps:**
1. Complete all 30 step definitions with dynamic debate content
2. Add analytics tracking for step completion rates
3. Add A/B testing between old and new onboarding
4. Collect user feedback and iterate

//
//  OnboardingView.swift
//  bigbruhh
//
//  Main onboarding container with state management and data handling
//  Migrated from: nrn/components/onboarding/index.tsx
//  NO STEP COMPONENTS YET - Just state, data handling, phase colors, progress tracking
//

import SwiftUI
import Combine

struct OnboardingView: View {
    let onComplete: () -> Void

    private let promptResolver: any PromptResolving = StaticPromptResolver()

    @StateObject private var state = OnboardingState()
    @StateObject private var soundManager = OnboardingSoundManager()
    @Environment(\.dismiss) private var dismiss

    // Debug
    @State private var showDebugModal = false

    // Phase transitions
    @State private var showPhaseFlash = false
    @State private var showGlitchTransition = false
    @State private var ritualLevel: Double = 0.0

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color changes based on phase
                getBackgroundColor(for: state.currentStep)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress Indicator (segmented bars - GLASSY LIQUID!)
                    PhaseProgressView(currentStep: state.currentStep, accentColor: getAccentColor(for: state.currentStep))
                        .padding(.top, 20)

                    Spacer()

                    // Current Step Content (PLACEHOLDER - No step components yet)
                    currentStepView

                    Spacer()
                }

                // Debug button - Absolute positioned top-right (iOS 26+ Liquid Glass)
                if isDevelopment {
                    VStack {
                        HStack {
                            Spacer()

                            if #available(iOS 26.0, *) {
                                Button("Debug") {
                                    showDebugModal = true
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .glassEffect(.regular.tint(.gray).interactive())
                                .padding(.trailing, 20)
                                .padding(.top, 60)
                            } else {
                                Button("Debug") {
                                    showDebugModal = true
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                .padding(.trailing, 20)
                                .padding(.top, 60)
                            }
                        }
                        Spacer()
                    }
                }

                // Glitch transition overlay
                GlitchTransitionView(isVisible: showGlitchTransition, mode: .intense, duration: 0.22)
            }
            .sheet(isPresented: $showDebugModal) {
                DebugModalView(state: state, onJumpToStep: jumpToStep)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .interactiveDismissDisabled(true)
            .onAppear {
                loadSavedState()
                updateAmbientMusic()
            }
            .onChange(of: state.currentStep) { _ in
                updateAmbientMusic()
            }
        }
    }

    // MARK: - Current Step View

    @ViewBuilder
    var currentStepView: some View {
        if let stepDef = getCurrentStepDefinition() {
            switch stepDef.type {
            case .explanation:
                ExplanationStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    onContinue: {
                        advanceStep(response: nil)
                    }
                )

            case .choice:
                ChoiceStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    secondaryAccentColor: getSecondaryAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            case .text:
                TextStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            case .dualSliders:
                DualSlidersStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            case .timeWindowPicker:
                TimePickerStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    secondaryAccentColor: getSecondaryAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            case .longPressActivate:
                LongPressStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    secondaryAccentColor: getSecondaryAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            case .voice:
                VoiceStep(
                    step: stepDef,
                    promptResolver: promptResolver,
                    backgroundColor: getBackgroundColor(for: state.currentStep),
                    textColor: getTextColor(for: state.currentStep),
                    accentColor: getAccentColor(for: state.currentStep),
                    secondaryAccentColor: getSecondaryAccentColor(for: state.currentStep),
                    onContinue: { response in
                        advanceStep(response: response)
                    }
                )

            default:
                // Placeholder for other step types
                VStack(spacing: 20) {
                    Text("Step \(stepDef.id) of 45")
                        .font(.caption)
                        .foregroundColor(getTextColor(for: state.currentStep).opacity(0.7))

                    Text(stepDef.prompt)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(getTextColor(for: state.currentStep))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text("Type: \(stepDef.type.rawValue)")
                        .font(.caption)
                        .foregroundColor(getTextColor(for: state.currentStep).opacity(0.5))

                    Text("⚠️ \(stepDef.type.rawValue) not implemented yet")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, 20)
                }
            }
        } else {
            Text("Invalid step")
                .foregroundColor(.red)
        }
    }

    // MARK: - Actions

    private func jumpToStep(_ stepNumber: Int) {
        state.currentStep = stepNumber
        showDebugModal = false
        saveState()
    }

    private func handleCompletion() {
        state.complete()
        saveState()

        print("🎯 45-step onboarding completed!")
        print("📊 Total responses: \(state.totalResponses)")
        print("👤 User name: \(state.userName ?? "N/A")")

        // Save completed onboarding data for access by other views (Paywall, Signup, etc.)
        OnboardingDataManager.shared.saveCompletedData(state)

        // Call parent callback to navigate to AlmostThere
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onComplete()
        }
    }

    private func handlePhaseChange(from oldPhase: OnboardingPhase, to newPhase: OnboardingPhase) {
        print("🔄 Phase change: \(oldPhase.rawValue) → \(newPhase.rawValue)")

        // Trigger glitch transition
        showGlitchTransition = true
        soundManager.playGlitch()
        triggerHaptic(intensity: 1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            showGlitchTransition = false
        }

        // Trigger flash animation
        withAnimation(.easeInOut(duration: 0.3)) {
            showPhaseFlash = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showPhaseFlash = false
            }
        }
    }

    // MARK: - Storage

    private func saveState() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(state) {
            UserDefaults.standard.set(encoded, forKey: "onboarding_v3_state")
            print("💾 State saved: Step \(state.currentStep)")
        }
    }

    private func loadSavedState() {
        // NOTE: In-progress state is cleared on app restart by OnboardingDataManager
        // This ensures users always start from step 1
        // Completed data is preserved separately for access by Paywall, Signup, etc.
        if let savedData = UserDefaults.standard.data(forKey: "onboarding_v3_state"),
           let decoded = try? JSONDecoder().decode(OnboardingState.self, from: savedData) {
            // Restore state (only works within same session)
            state.currentStep = decoded.currentStep
            state.responses = decoded.responses
            state.brotherName = decoded.brotherName
            state.userName = decoded.userName
            print("📂 State loaded: Step \(state.currentStep)")
        } else {
            print("📂 No in-progress state found - starting fresh from step 1")
        }
    }

    // MARK: - Logging

    private func logResponse(_ response: UserResponse) {
        print("\n🔥 === LIVE RESPONSE RECEIVED ===")
        print("🔢 Step \(response.stepId):")
        print("  📝 Type: \(response.type.rawValue)")
        print("  💾 Value: \(response.value)")
        print("  ⏰ Timestamp: \(response.timestamp)")

        if let voiceUri = response.voiceUri {
            print("  🎙️  Voice URI: \(voiceUri)")
            print("  🎵 Duration: \(response.duration ?? 0) seconds")
        }
    }

    // MARK: - Helpers

    private func getCurrentStepDefinition() -> StepDefinition? {
        return STEP_DEFINITIONS.first { $0.id == state.currentStep }
    }

    private func getCurrentPhase() -> OnboardingPhase {
        return getCurrentStepDefinition()?.phase ?? .warningInitiation
    }

    private var isDevelopment: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // MARK: - Haptics

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }

    // MARK: - Phase-Based Styling (Migrated from NRN)

    private func getBackgroundColor(for step: Int) -> Color {
        let phase = getCurrentPhase()

        switch phase {
        case .warningInitiation:
            return Color(hex: "#0D0000") // Deep blood-tinted black
        case .excuseDiscovery:
            return Color(hex: "#140A08") // Burnt umber darkness
        case .excuseConfrontation:
            return Color(hex: "#000000") // Pure void
        case .patternAwareness:
            return Color(hex: "#FFFEF0") // Warm cream (lightbulb moment)
        case .patternAnalysis:
            return Color(hex: "#F0F8FF") // Alice blue (clinical clarity)
        case .identityRebuild:
            return Color(hex: "#F0FFF4") // Honeydew (fresh growth)
        case .commitmentSystem:
            return Color(hex: "#FAF0E6") // Linen (grounded, stable)
        case .externalAnchors:
            return Color(hex: "#0A0014") // Deep purple-black (mystical)
        case .finalOath:
            return Color(hex: "#000000") // Return to void
        }
    }

    private func getTextColor(for step: Int) -> Color {
        let phase = getCurrentPhase()

        // White text on dark backgrounds
        if [.warningInitiation, .excuseDiscovery, .excuseConfrontation, .externalAnchors,.finalOath].contains(phase) {
            return .white
        }

        // Black text on light backgrounds
        return .black
    }

    private func getAccentColor(for step: Int) -> Color {
        let phase = getCurrentPhase()

        switch phase {
        case .warningInitiation:
            return Color(hex: "#FF1744") // Material Red A400 (alarm)
        case .excuseDiscovery:
            return Color(hex: "#D84315") // Deep Orange 800 (burning)
        case .excuseConfrontation:
            return Color(hex: "#C62828") // Red 800 (blood)
        case .patternAwareness:
            return Color(hex: "#FDD835") // Yellow 600 (clarity)
        case .patternAnalysis:
            return Color(hex: "#1976D2") // Blue 700 (analytical)
        case .identityRebuild:
            return Color(hex: "#00C853") // Green A700 (growth)
        case .commitmentSystem:
            return Color(hex: "#558B2F") // Light Green 800 (stable)
        case .externalAnchors:
            return Color(hex: "#7C4DFF") // Deep Purple A200 (mystical)
        case .finalOath:
            return Color(hex: "#76FF03") // Light Green A400 (LOCKED)
        }
    }

    private func getSecondaryAccentColor(for step: Int) -> Color {
        let phase = getCurrentPhase()

        switch phase {
        case .warningInitiation:
            return Color(hex: "#B01030")
        case .excuseDiscovery:
            return Color(hex: "#8B1A1A")
        case .excuseConfrontation:
            return Color(hex: "#660000")
        case .patternAwareness:
            return Color(hex: "#DAA520")
        case .patternAnalysis:
            return Color(hex: "#FF8C00")
        case .identityRebuild:
            return Color(hex: "#00CC00")
        case .commitmentSystem:
            return Color(hex: "#228B22")
        case .externalAnchors:
            return Color(hex: "#7500CC")
        case .finalOath:
            return Color(hex: "#550A8A")
        }
    }

    // MARK: - State Management

    private func advanceStep(response: UserResponse?) {
        triggerHaptic(intensity: 0.7)
        soundManager.playSuccess(for: state.currentStep)

        // Save response if provided
        if let response = response {
            state.saveResponse(response)
            logResponse(response)
        }

        // Check if completed
        if state.currentStep >= 45 {
            handleCompletion()
            return
        }

        // Advance to next step
        let previousPhase = getCurrentPhase()
        state.nextStep()
        let newPhase = getCurrentPhase()

        // Trigger phase change animation if phase changed
        if previousPhase != newPhase {
            handlePhaseChange(from: previousPhase, to: newPhase)
        }

        // Save state to storage
        saveState()
    }

    // MARK: - Audio

    private func updateAmbientMusic() {
        guard let currentStep = getCurrentStepDefinition() else { return }
        soundManager.updateAmbientForStep(
            stepId: currentStep.id,
            phase: currentStep.phase,
            stepType: currentStep.type
        )
    }
}

// MARK: - Phase Progress View (GLASSY LIQUID BARS - iOS 15+)

struct PhaseProgressView: View {
    let currentStep: Int
    let accentColor: Color

    private let phaseConfigs: [OnboardingPhase: Int] = [
        .warningInitiation: 5,
        .excuseDiscovery: 6,
        .excuseConfrontation: 5,
        .patternAwareness: 5,
        .patternAnalysis: 5,
        .identityRebuild: 5,
        .commitmentSystem: 5,
        .externalAnchors: 5,
        .finalOath: 4
    ]

    private var phaseInfo: (phase: OnboardingPhase, phaseStep: Int, totalSteps: Int) {
        guard let stepDef = STEP_DEFINITIONS.first(where: { $0.id == currentStep }) else {
            return (.warningInitiation, 1, 5)
        }

        let phase = stepDef.phase
        let totalSteps = phaseConfigs[phase] ?? 5

        let phaseSteps = STEP_DEFINITIONS.filter { $0.phase == phase }
        let currentStepIndex = phaseSteps.firstIndex(where: { $0.id == currentStep }) ?? 0
        let phaseStep = min(currentStepIndex + 1, totalSteps)

        return (phase, phaseStep, totalSteps)
    }

    var body: some View {
        let info = phaseInfo

        HStack(spacing: Spacing.xxs) {
            ForEach(1...info.totalSteps, id: \.self) { segmentNumber in
                GlassySegmentBar(
                    isCompleted: segmentNumber < info.phaseStep,
                    isActive: segmentNumber == info.phaseStep,
                    accentColor: accentColor
                )
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Glassy Liquid Segment Bar

struct GlassySegmentBar: View {
    let isCompleted: Bool
    let isActive: Bool
    let accentColor: Color

    @State private var pulseScale: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        ZStack {
            // Base bar with glassmorphism
            RoundedRectangle(cornerRadius: isActive ? 3 : 1.5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isCompleted || isActive ? [
                            accentColor.opacity(0.85),
                            accentColor,
                            accentColor.opacity(0.85)
                        ] : [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.15)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: isActive ? 5 : 2.5)
                .overlay(
                    // Glass reflection layer
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isActive ? 0.4 : 0.2),
                            Color.white.opacity(0.0),
                            Color.white.opacity(isActive ? 0.2 : 0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .mask(RoundedRectangle(cornerRadius: isActive ? 3 : 1.5, style: .continuous))
                )
                .shadow(
                    color: isActive ? accentColor.opacity(0.7) : .clear,
                    radius: isActive ? 10 : 0,
                    x: 0,
                    y: 0
                )
                .scaleEffect(y: isActive ? pulseScale : 1.0)

            // Shimmer effect on active bar
            if isActive {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.7),
                                Color.white.opacity(0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: 5)
                    .offset(x: shimmerOffset * 100)
                    .mask(RoundedRectangle(cornerRadius: 3, style: .continuous).frame(height: 5))
            }
        }
        .onAppear {
            if isActive {
                // Pulsing animation
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }

                // Shimmer animation
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = 1.0
                }
            }
        }
    }
}

// MARK: - Debug Modal

struct DebugModalView: View {
    @ObservedObject var state: OnboardingState
    let onJumpToStep: (Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Current State") {
                    Text("Step: \(state.currentStep) / 45")
                    Text("Responses: \(state.totalResponses)")
                    Text("User Name: \(state.userName ?? "Not set")")
                    Text("Progress: \(Int(state.progressPercentage))%")
                }

                Section("Jump to Step") {
                    ForEach(1...45, id: \.self) { step in
                        if let stepDef = STEP_DEFINITIONS.first(where: { $0.id == step }) {
                            Button(action: {
                                onJumpToStep(step)
                                dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Step \(step)")
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text(stepDef.type.rawValue.uppercased())
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(getTypeColor(stepDef.type))
                                            .foregroundColor(.white)
                                            .cornerRadius(4)
                                    }
                                    Text(stepDef.prompt.prefix(60) + (stepDef.prompt.count > 60 ? "..." : ""))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                        } else {
                            Button("Step \(step)") {
                                onJumpToStep(step)
                                dismiss()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func getTypeColor(_ type: StepType) -> Color {
        switch type {
        case .explanation:
            return .blue
        case .text:
            return .green
        case .voice:
            return .purple
        case .choice:
            return .orange
        case .dualSliders:
            return .pink
        case .timezoneSelection:
            return .teal
        case .longPressActivate:
            return .red
        case .timeWindowPicker:
            return .indigo
        case .visualCommitmentSummary:
            return .cyan
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(onComplete: {
        print("Preview: Onboarding completed")
    })
}

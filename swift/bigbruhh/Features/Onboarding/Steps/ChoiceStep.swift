//
//  ChoiceStep.swift
//  bigbruhh
//
//  Multiple choice component for onboarding
//  Migrated from: nrn/components/onboarding/steps/MultipleChoiceStep.tsx
//

import SwiftUI

struct ChoiceStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let secondaryAccentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var selectedOption: String?
    @State private var lockedOption: String?
    @State private var canProceed: Bool = false
    @State private var showPrompt: Bool = false
    @State private var showOptions: Bool = false
    @State private var optionScales: [CGFloat] = Array(repeating: 1.0, count: 6)
    @State private var optionOffsets: [CGFloat] = Array(repeating: 20, count: 6)
    @State private var optionOpacities: [Double] = Array(repeating: 0, count: 6)
    @Namespace private var glassNamespace

    var body: some View {
        VStack(spacing: 0) {
            // Prompt text
            HStack {
                Text(step.resolvedPrompt(using: promptResolver))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(textColor)
                    .tracking(1.5)
                    .lineSpacing(-2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 60)
                    .opacity(showPrompt ? 1 : 0)

                Spacer()
            }
            .padding(.bottom, 24)

            // Options list - Liquid Glass with GlassEffectContainer
            if #available(iOS 26.0, *) {
                ScrollView {
                    GlassEffectContainer(spacing: 12) {
                        VStack(spacing: 12) {
                            ForEach(Array((step.options ?? []).enumerated()), id: \.offset) { index, option in
                                optionButton(option: option, index: index)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
                .opacity(showOptions ? 1 : 0)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array((step.options ?? []).enumerated()), id: \.offset) { index, option in
                            optionButton(option: option, index: index)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .opacity(showOptions ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            resetState()
            startAnimations()

            // 3 second delay before allowing selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                canProceed = true
            }
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        selectedOption = nil
        lockedOption = nil
        canProceed = false
        showPrompt = false
        showOptions = false
        optionScales = Array(repeating: 1.0, count: 6)
        optionOffsets = Array(repeating: 20, count: 6)
        optionOpacities = Array(repeating: 0, count: 6)
    }

    // MARK: - Option Button

    @ViewBuilder
    func optionButton(option: String, index: Int) -> some View {
        let isSelected = (lockedOption == option || selectedOption == option)
        let isDimmed = lockedOption != nil && lockedOption != option
        let isWaiting = !canProceed && !isSelected

        Button(action: { handleOptionSelect(option: option, index: index) }) {
            buttonContent(option: option, isSelected: isSelected)
                .padding(.horizontal, 16)
                .frame(height: 64)
                .frame(maxWidth: .infinity)
        }
        .applyChoiceGlassEffect(isSelected: isSelected, accentColor: accentColor)
        .opacity(isDimmed ? 0.4 : (isWaiting ? 0.6 : 1.0))
        .scaleEffect(optionScales[index])
        .offset(y: optionOffsets[index])
        .disabled(lockedOption != nil)
    }

    @ViewBuilder
    func buttonContent(option: String, isSelected: Bool) -> some View {
        HStack(spacing: 12) {
            Text(option)
                .font(.system(size: 16, weight: .bold))
                .tracking(0.5)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.buttonTextColor(for: accentColor))
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }

    // MARK: - Animations

    private func startAnimations() {
        // Reset state
        showPrompt = false
        showOptions = false
        selectedOption = nil
        lockedOption = nil
        canProceed = false

        // Prompt fade in
        withAnimation(.easeIn(duration: 0.35)) {
            showPrompt = true
        }

        // Options fade in with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeIn(duration: 0.35)) {
                showOptions = true
            }
        }

        // Individual option animations
        let count = min(step.options?.count ?? 0, 6)
        for i in 0..<count {
            let delay = 0.15 + Double(i) * 0.1

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.35)) {
                    optionOffsets[i] = 0
                    optionOpacities[i] = 1
                }
            }
        }
    }

    // MARK: - Actions

    private func handleOptionSelect(option: String, index: Int) {
        if lockedOption != nil { return }

        triggerHaptic(intensity: 0.6)
        selectedOption = option

        // Only allow locking after 3 seconds
        if canProceed {
            triggerHaptic(intensity: 1.0)
            lockedOption = option

            // Scale animation
            withAnimation(.easeOut(duration: 0.1)) {
                optionScales[index] = 1.05
            }

            // Create response and advance
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let response = UserResponse(
                    stepId: step.id,
                    type: .choice,
                    value: .choice(option),
                    timestamp: Date(),
                    dbField: step.dbField
                )

                print("\n🎯 === CHOICE SELECTION ===")
                print("🔢 Step \(step.id):")
                print("  🎯 Selected: \"\(option)\"")
                print("  ⏰ Timestamp: \(response.timestamp)")
                print("🎯 === CHOICE SUBMITTED ===\n")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                    onContinue(response)
                }
            }
        }
    }

    // MARK: - Helpers

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Preview

#Preview {
    ChoiceStep(
        step: StepDefinition(
            id: 5,
            phase: .excuseDiscovery,
            type: .choice,
            prompt: "What do you waste time on?",
            dbField: ["waste_habits"],
            options: [
                "Phone scrolling",
                "Gaming",
                "YouTube/Netflix",
                "Overthinking",
                "Procrastinating",
                "All of the above"
            ],
            helperText: nil,
            sliders: nil,
            minDuration: nil,
            requiredPhrase: nil,
            displayType: nil
        ),
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#DC143C"),
        secondaryAccentColor: Color(hex: "#B01030"),
        onContinue: { _ in print("Continue") }
    )
}

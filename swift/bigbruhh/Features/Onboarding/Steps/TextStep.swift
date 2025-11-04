//
//  TextStep.swift
//  bigbruhh
//
//  Text input component for onboarding
//  Migrated from: nrn/components/onboarding/steps/TextStep.tsx
//

import SwiftUI

struct TextStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var phase: Phase = .input
    @State private var textValue: String = ""
    @State private var submittedText: String = ""
    @State private var emptyAttempts: Int = 0
    @State private var showJudgment: Bool = false
    @State private var shakeOffset: CGFloat = 0
    @State private var slamScale: CGFloat = 0.9
    @State private var slamOpacity: Double = 0
    @FocusState private var isInputFocused: Bool

    enum Phase {
        case input
        case complete
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                if phase == .input {
                    inputPhase
                } else {
                    completePhase
                }

                Spacer()
            }
        }
        .onAppear {
            resetState()
            isInputFocused = true
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        phase = .input
        textValue = ""
        submittedText = ""
        emptyAttempts = 0
        showJudgment = false
        shakeOffset = 0
        slamScale = 0.9
        slamOpacity = 0
    }

    // MARK: - Input Phase

    @ViewBuilder
    private var inputPhase: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Prompt
            Text(step.resolvedPrompt(using: promptResolver))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(textColor)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Helper text
            if let helperText = step.helperText {
                Text(helperText)
                    .font(.system(size: 12, weight: .bold, design: .default))
                    .foregroundColor(textColor.opacity(0.7))
                    .tracking(0.5)
                    .padding(.bottom, 10)
            }

            // Text input with bottom border
            VStack(spacing: 0) {
                TextField("", text: $textValue, axis: isMultiline ? .vertical : .horizontal)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(textColor)
                    .tracking(1.5)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .keyboardType(.default)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        handleContinue()
                    }
                    .onChange(of: textValue) { oldValue, newValue in
                        textValue = newValue.uppercased()
                        if !newValue.isEmpty {
                            triggerHaptic(intensity: 0.3)
                        }
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .placeholder(when: textValue.isEmpty) {
                        Text(getPlaceholder())
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(textColor.opacity(0.35))
                            .tracking(1.5)
                    }

                // Bottom border
                Rectangle()
                    .fill(textColor)
                    .frame(height: 4)
            }
            .offset(x: shakeOffset)
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Complete Phase

    @ViewBuilder
    private var completePhase: some View {
        Text(submittedText)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(textColor)
            .tracking(1)
            .multilineTextAlignment(.leading)
            .scaleEffect(slamScale)
            .opacity(slamOpacity)
            .padding(.horizontal, 20)
    }

    // MARK: - Actions

    private func handleContinue() {
        let trimmed = textValue.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            emptyAttempts += 1
            triggerHaptic(intensity: 1.0)

            if emptyAttempts >= 2 {
                showJudgment = true
            }

            // Shake animation
            withAnimation(.easeInOut(duration: 0.06)) {
                shakeOffset = -10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                withAnimation(.easeInOut(duration: 0.06)) {
                    shakeOffset = 10
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    shakeOffset = -6
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
                withAnimation(.easeInOut(duration: 0.04)) {
                    shakeOffset = 0
                }
            }

            return
        }

        proceedWithValue(trimmed)
    }

    private func proceedWithValue(_ value: String) {
        phase = .complete
        triggerHaptic(intensity: 1.0)
        submittedText = value
        isInputFocused = false

        // Slam animation
        withAnimation(.easeOut(duration: 0.12)) {
            slamScale = 1.05
            slamOpacity = 1
        }

        // Save user name for step 4
        if step.id == 4 {
            UserDefaults.standard.set(value, forKey: "user_name")
        }

        // Create response and advance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let response = UserResponse(
                stepId: step.id,
                type: .text,
                value: .text(value),
                timestamp: Date(),
                dbField: step.dbField
            )

            print("\n📝 === TEXT SUBMISSION ===")
            print("🔢 Step \(step.id):")
            print("  ✍️  Text: \"\(value)\"")
            print("  ⏰ Timestamp: \(response.timestamp)")
            print("📝 === TEXT SUBMITTED ===\n")

            onContinue(response)
        }
    }

    // MARK: - Helpers

    private var isMultiline: Bool {
        return step.id == 16 || step.id == 27
    }

    private func getPlaceholder() -> String {
        switch step.id {
        case 15:
            return "e.g., \"The Machine\", \"Silence\", \"Stone\""
        case 4:
            return "Your first name..."
        case 7:
            return "The version of yourself you fear becoming..."
        case 16:
            return "Your BigBruh's powerful manifesto..."
        case 27:
            return "Tomorrow's temptation and your counter-move..."
        default:
            return "Type your answer..."
        }
    }

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Placeholder Extension

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview

#Preview {
    TextStep(
        step: StepDefinition(
            id: 4,
            phase: .warningInitiation,
            type: .text,
            prompt: "WHAT'S YOUR NAME?",
            dbField: ["user_name"],
            options: nil,
            helperText: "First name only. We need to know who we're dealing with.",
            sliders: nil,
            minDuration: nil,
            requiredPhrase: nil,
            displayType: nil
        ),
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#DC143C"),
        onContinue: { _ in print("Continue") }
    )
}

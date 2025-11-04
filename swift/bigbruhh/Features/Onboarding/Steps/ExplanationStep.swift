//
//  ExplanationStep.swift
//  bigbruhh
//
//  Explanation display with typewriter effect and proper iOS glassmorphism
//  Migrated from: nrn/components/onboarding/steps/ExplanationStep.tsx
//

import SwiftUI

struct ExplanationStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let onContinue: () -> Void

    @State private var typedText: String = ""
    @State private var showButton: Bool = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var currentCTA: String = "NEXT →"

    private let abrasiveCTAs = [
        "NEXT →",
        "CONTINUE →",
        "KEEP GOING →",
        "NO BACKING DOWN →",
        "PUSH FORWARD →",
        "DON'T QUIT →",
        "STAY STRONG →",
        "FACE IT →"
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                // Main text with typewriter effect
                Text(typedText)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textColor)
                    .tracking(1.5)
                    .lineSpacing(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                Spacer()
                Spacer()
            }

            // Continue button (bottom right) - Absolute positioned with glass
            if showButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        Button(action: handleContinue) {
                            Text(currentCTA)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.buttonTextColor(for: accentColor))
                                .tracking(1)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                        }
                        .applyStepGlassEffect(prominent: true, accentColor: accentColor)
                        .scaleEffect(buttonScale)
                        .transition(.opacity.combined(with: .scale))
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 40)
                }
                .ignoresSafeArea(.all, edges: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            resetState()
            startTypewriter()
            randomizeCTA()
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        typedText = ""
        showButton = false
        buttonScale = 1.0
    }

    // MARK: - Typewriter Effect

    private func startTypewriter() {
        typedText = ""
        showButton = false

        let text = step.resolvedPrompt(using: promptResolver)
        let chars = Array(text)
        var currentIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            guard currentIndex < chars.count else {
                timer.invalidate()
                // Show button when typing complete
                withAnimation(.easeIn(duration: 0.15)) {
                    showButton = true
                }
                triggerHaptic(intensity: 1.0)
                return
            }

            typedText.append(chars[currentIndex])
            currentIndex += 1
        }
    }

    // MARK: - Button Actions

    private func handleContinue() {
        // Button scale animation
        withAnimation(.easeOut(duration: 0.05)) {
            buttonScale = 0.9
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.1)) {
                buttonScale = 1.05
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.1)) {
                buttonScale = 1.0
            }
        }

        triggerHaptic(intensity: 1.0)

        // Advance to next step
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onContinue()
        }
    }

    private func randomizeCTA() {
        currentCTA = abrasiveCTAs.randomElement() ?? "NEXT →"
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
    ExplanationStep(
        step: STEP_DEFINITIONS[0],
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#DC143C"),
        onContinue: { print("Continue") }
    )
}

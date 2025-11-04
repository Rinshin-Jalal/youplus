//
//  LongPressStep.swift
//  bigbruhh
//
//  Long press to seal contract
//  Migrated from: nrn/components/onboarding/steps/LongPressStep.tsx
//

import SwiftUI
import Combine

struct LongPressStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let secondaryAccentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var isPressed: Bool = false
    @State private var isCompleting: Bool = false
    @State private var progressText: String = ""
    @State private var remainingTime: Int = 0
    @State private var showLocked: Bool = false
    @State private var progress: Double = 0
    @State private var buttonScale: CGFloat = 1.0
    @State private var buttonOpacity: Double = 1.0
    @State private var shake: CGFloat = 0

    private let holdDurationMs: Double = 10000 // 10 seconds
    private var holdDurationSeconds: Int { Int(holdDurationMs / 1000) }

    @State private var pressTimer: Timer?
    @State private var progressTimer: Timer?

    var body: some View {
        ZStack {
            // Background - turns black when pressed
            (isPressed ? Color.black : backgroundColor)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Prompt at top - hidden when pressed
                VStack(alignment: .leading) {
                    Text(step.resolvedPrompt(using: promptResolver))
                        .font(.system(size: 32, weight: .bold))
                        .tracking(1.5)
                        .lineSpacing(3)
                        .textCase(.uppercase)
                        .foregroundColor(textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .offset(x: shake)
                .opacity(isPressed ? 0 : 1)

                Spacer()

                // Helper text - hidden when pressed
                if let helperText = step.helperText {
                    Text(helperText)
                        .font(.system(size: 14))
                        .foregroundColor(textColor.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .opacity(isPressed ? 0 : 1)
                }

                // Center circle button
                ZStack {
                    // Progress circle (clockwise fill) - always visible
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(accentColor, lineWidth: 8)
                        .frame(width: 320, height: 320)
                        .rotationEffect(.degrees(-90))

                    // Button - hidden when pressed, only text visible
                    if !isPressed {
                        Button(action: {}) {
                            VStack(spacing: 6) {
                                Text("HOLD")
                                    .font(.system(size: 32, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(Color.buttonTextColor(for: accentColor))

                                Text("DO NOT LET GO")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(1)
                                    .foregroundColor(Color.buttonTextColor(for: accentColor).opacity(0.7))
                            }
                            .frame(width: 300, height: 300)
                        }
                        .buttonStyle(.plain)
                        .applyLongPressGlassEffect(prominent: true, accentColor: accentColor)
                        .scaleEffect(buttonScale)
                        .opacity(buttonOpacity)
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0)
                                .onChanged { _ in
                                    if !isPressed && !isCompleting {
                                        handlePressIn()
                                    }
                                }
                                .onEnded { _ in
                                    if isPressed {
                                        handlePressOut()
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in
                                    if isPressed {
                                        handlePressOut()
                                    }
                                }
                        )
                        .disabled(isCompleting)
                    } else {
                        // Only timer text visible when pressed
                        Text(isCompleting ? "LOCKED" : "HOLD \(remainingTime)...")
                            .font(.system(size: 32, weight: .bold))
                            .tracking(1)
                            .foregroundColor(accentColor)
                    }
                }
                .padding(.bottom, 40)

                Spacer()

                // Bottom text - hidden when pressed
                Text("WEAK THUMBS LET GO EARLY.")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1)
                    .foregroundColor(textColor.opacity(0.4))
                    .padding(.bottom, 24)
                    .opacity(isPressed ? 0 : 1)
            }
        }
        .onAppear {
            resetState()
        }
        .onDisappear {
            cleanupTimers()
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        isPressed = false
        isCompleting = false
        progressText = ""
        remainingTime = 0
        showLocked = false
        progress = 0
        buttonScale = 1.0
        buttonOpacity = 1.0
        shake = 0
        cleanupTimers()
    }

    // MARK: - Actions

    private func handlePressIn() {
        isPressed = true
        remainingTime = holdDurationSeconds
        triggerHaptic(intensity: 0.5)

        // Button press scale
        withAnimation(.easeOut(duration: 0.15)) {
            buttonScale = 0.96
        }

        // Start progress animation
        withAnimation(.linear(duration: holdDurationMs / 1000)) {
            progress = 1.0
        }

        // Update countdown timer
        var elapsed: Double = 0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsed += 100
            let remaining = max(0, holdDurationMs - elapsed)
            let seconds = Int(ceil(remaining / 1000))

            remainingTime = seconds

            if seconds > 0 {
                progressText = "HOLD \(seconds)..."
                if Int(elapsed) % 1000 == 0 {
                    triggerHaptic(intensity: 0.2)
                }
            } else {
                progressText = "SEALING..."
            }
        }

        // Set timeout for completion
        pressTimer = Timer.scheduledTimer(withTimeInterval: holdDurationMs / 1000, repeats: false) { _ in
            handleCompletion()
        }
    }

    private func handlePressOut() {
        guard !isCompleting else { return }

        isPressed = false
        progressText = "YOU BROKE. TRY AGAIN."
        triggerHaptic(intensity: 1.0)

        // Stop all animations and reset progress immediately
        withAnimation(.none) {
            progress = 0
        }

        // Violent shake
        withAnimation(.easeInOut(duration: 0.06)) {
            shake = 4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
            withAnimation(.easeInOut(duration: 0.06)) {
                shake = -4
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.06)) {
                shake = 0
            }
        }

        // Button returns to normal scale
        withAnimation(.easeOut(duration: 0.2)) {
            buttonScale = 1.0
        }

        // Clear timers immediately to stop all progress
        cleanupTimers()

        // Clear error text after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            progressText = ""
        }
    }

    private func handleCompletion() {
        isCompleting = true
        triggerHaptic(intensity: 1.0)
        progressText = "LOCKED."
        showLocked = true

        // Clear progress timer
        progressTimer?.invalidate()
        progressTimer = nil

        // Button completion animation
        withAnimation(.easeIn(duration: 0.22)) {
            buttonScale = 0
        }
        withAnimation(.easeOut(duration: 0.24)) {
            buttonOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = UserResponse(
                stepId: step.id,
                type: .longPressActivate,
                value: .bool(true),
                timestamp: Date(),
                duration: holdDurationMs / 1000,
                dbField: step.dbField
            )

            print("\n👆 === LONG PRESS COMPLETION ===")
            print("🔢 Step \(step.id):")
            print("  👆 Duration: \(holdDurationMs)ms")
            print("  ✅ Activated: true")
            print("  ⏰ Timestamp: \(response.timestamp)")
            print("👆 === LONG PRESS SUBMITTED ===\n")

            onContinue(response)
        }
    }

    private func cleanupTimers() {
        pressTimer?.invalidate()
        pressTimer = nil
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Glass Effect Extension

extension View {
    @ViewBuilder
    func applyLongPressGlassEffect(prominent: Bool, accentColor: Color) -> some View {
        if #available(iOS 26.0, *) {
            if prominent {
                self.glassEffect(.regular.tint(accentColor).interactive())
            } else {
                self.glassEffect(.regular.interactive())
            }
        } else {
            // Fallback for older iOS versions
            if prominent {
                self.background(accentColor.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                self.background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LongPressStep(
        step: StepDefinition(
            id: 45,
            phase: .finalOath,
            type: .longPressActivate,
            prompt: "SEAL THE CONTRACT. HOLD TO LOCK IN.",
            dbField: ["contract_sealed"],
            options: nil,
            helperText: "This is your commitment. Do not let go.",
            sliders: nil,
            minDuration: nil,
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

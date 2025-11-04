//
//  DualSlidersStep.swift
//  bigbruhh
//
//  Dual slider component for onboarding
//  Migrated from: nrn/components/onboarding/steps/DualSlidersStep.tsx
//

import SwiftUI

struct DualSlidersStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var activeSliderIndex: Int = 0
    @State private var sliderValues: [Int] = []
    @State private var hasInteracted: Bool = false
    @State private var showRecorded: Bool = false

    // Animation states
    @State private var promptOpacity: Double = 0
    @State private var slidersOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var containerOpacity: Double = 1

    // Entrance animations
    @State private var slider1EnterX: CGFloat = -20
    @State private var slider2EnterX: CGFloat = 20

    // Slider positions (0-1 normalized)
    @State private var sliderPositions: [Double] = [0.5, 0.5, 0.5, 0.5]

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress Indicator
                Spacer()

                // Main content
                currentPhaseView

                Spacer()

                // Continue button
                if buttonOpacity > 0 {
                    Button(action: handleContinue) {
                        Text(activeSliderIndex >= (step.sliders?.count ?? 0) - 1 ? "LOCK IT IN" : "NEXT")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(Color.buttonTextColor(for: accentColor))
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: 60)
                    }
                    .applyDualSlidersGlassEffect(prominent: true, accentColor: accentColor)
                    .opacity(buttonOpacity)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            resetState()
            initializeSliders()
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        activeSliderIndex = 0
        sliderValues = []
        hasInteracted = false
        showRecorded = false
        promptOpacity = 0
        slidersOpacity = 0
        buttonOpacity = 0
        containerOpacity = 1
        slider1EnterX = -20
        slider2EnterX = 20
        sliderPositions = [0.5, 0.5, 0.5, 0.5]
    }

    // MARK: - Current Phase View

    @ViewBuilder
    private var currentPhaseView: some View {
        VStack(spacing: 0) {
            // Prompt at top
            Text(currentSliderTitle)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(textColor)
                .tracking(1.5)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.uppercase)
                .opacity(promptOpacity)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

            Spacer()

            // Sliders container
            VStack {
                if let slider = getCurrentSlider() {
                    sliderView(for: slider, index: activeSliderIndex)
                }
            }
            .opacity(slidersOpacity)
            .frame(maxWidth: .infinity)

            Spacer()
        }
    }

    // MARK: - Slider View

    @ViewBuilder
    private func sliderView(for slider: SliderConfig, index: Int) -> some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width - 48 // Account for padding

            VStack(alignment: .leading, spacing: 16) {
                // Track and thumb
                ZStack(alignment: .leading) {
                    // Track background
                    Rectangle()
                        .fill(Color(hex: "#222222"))
                        .frame(height: 80)

                    // Safe access to arrays with bounds checking
                    let currentValue = index < sliderValues.count ? sliderValues[index] : (slider.range.min + slider.range.max) / 2
                    let currentPosition = index < sliderPositions.count ? sliderPositions[index] : 0.5

                    // Track fill
                    Rectangle()
                        .fill(getPhaseColor(index: index, value: currentValue, slider: slider))
                        .frame(width: CGFloat(currentPosition) * trackWidth, height: 80)

                    // Thumb
                    ZStack {
                        Rectangle()
                            .fill(getPhaseColor(index: index, value: currentValue, slider: slider))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Rectangle()
                                    .stroke(getPhaseColor(index: index, value: currentValue, slider: slider), lineWidth: 2)
                            )

                        Image(systemName: "arrow.forward")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.textColor(for: getPhaseColor(index: index, value: currentValue, slider: slider)))
                    }
                    .offset(x: CGFloat(currentPosition) * trackWidth - 40) // Center the thumb
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDragChange(value: value, sliderIndex: index, slider: slider, trackWidth: trackWidth)
                            }
                            .onEnded { _ in
                                handleDragEnd(sliderIndex: index, slider: slider)
                            }
                    )
                }
                .frame(width: trackWidth, height: 80)
                .padding(.horizontal, 20)

                // Min/Max values
                HStack {
                    Text("\(slider.range.min)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                        .tracking(1)

                    Spacer()

                    Text("\(slider.range.max)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                        .tracking(1)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 150)
    }

    // MARK: - Actions

    private func initializeSliders() {
        guard let sliders = step.sliders else { return }

        // Initialize slider values with defaults
        sliderValues = sliders.map { slider in
            Int((Double(slider.range.min) + Double(slider.range.max)) / 2.0)
        }

        // Initialize positions
        sliderPositions = sliderValues.map { value in
            // Since value comes from sliderValues, firstIndex will always find a match
            guard let index = sliderValues.firstIndex(of: value) else {
                return 0.0 // Fallback, though this should never happen
            }
            let slider = sliders[index]
            let range = Double(slider.range.max - slider.range.min)
            return Double(value - slider.range.min) / range
        }

        // Animate entrance
        withAnimation(.easeOut(duration: 0.35)) {
            promptOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.5)) {
            slidersOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.5)) {
            slider1EnterX = 0
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
            slider2EnterX = 0
        }

        // Show button if current slider has been moved from center
        if movedFromCenter(activeSliderIndex) {
            withAnimation(.easeOut(duration: 0.3)) {
                buttonOpacity = 1
            }
        }
    }

    private func handleDragChange(value: DragGesture.Value, sliderIndex: Int, slider: SliderConfig, trackWidth: CGFloat) {
        guard sliderIndex < step.sliders?.count ?? 0 else { return }

        let newPosition = max(0, min(1, Double(value.location.x) / trackWidth))

        sliderPositions[sliderIndex] = newPosition

        let range = Double(slider.range.max - slider.range.min)
        let newValue = slider.range.min + Int((newPosition * range).rounded())

        if sliderValues[sliderIndex] != newValue {
            sliderValues[sliderIndex] = newValue
            hasInteracted = true

            // Show button when slider is moved from center
            if sliderIndex == activeSliderIndex && buttonOpacity == 0 {
                withAnimation(.easeOut(duration: 0.3)) {
                    buttonOpacity = 1
                }
            }

            // Haptic feedback
            triggerHaptic(intensity: 0.3)
        }
    }

    private func handleDragEnd(sliderIndex: Int, slider: SliderConfig) {
        // Snap to nearest integer
        let range = Double(slider.range.max - slider.range.min)
        let currentPosition = sliderPositions[sliderIndex]
        let snappedValue = slider.range.min + Int((currentPosition * range).rounded())
        let snappedNormalized = Double(snappedValue - slider.range.min) / range

        withAnimation(.easeOut(duration: 0.1)) {
            sliderPositions[sliderIndex] = snappedNormalized
        }

        triggerHaptic(intensity: 0.3)
    }

    private func handleContinue() {
        guard let sliders = step.sliders else { return }

        let total = sliders.count
        let isLast = activeSliderIndex >= total - 1

        if !isLast {
            triggerHaptic(intensity: 0.5)

            // Fade out current slider
            withAnimation(.easeInOut(duration: 0.18)) {
                containerOpacity = 0
                buttonOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                activeSliderIndex = min(activeSliderIndex + 1, total - 1)

                withAnimation(.easeInOut(duration: 0.18)) {
                    containerOpacity = 1
                }
            }

            return
        }

        // Final submission
        triggerHaptic(intensity: 1.0)

        let response = UserResponse(
            stepId: step.id,
            type: .dualSliders,
            value: .text(sliderValues.map(String.init).joined(separator: ",")),
            timestamp: Date(),
            dbField: step.dbField
        )

        print("\n📊 === DUAL SLIDERS SUBMISSION ===")
        print("🔢 Step \(step.id):")
        sliderValues.enumerated().forEach { index, value in
            print("  📊 Slider \(index + 1): \(value) / 10")
        }
        print("  📊 Raw value: \"\(sliderValues.map(String.init).joined(separator: ","))\"")
        print("  ⏰ Timestamp: \(response.timestamp)")
        print("📊 === SLIDERS SUBMITTED ===\n")

        onContinue(response)
    }

    // MARK: - Helpers

    private var currentSliderTitle: String {
        guard let current = getCurrentSlider() else {
            return step.resolvedPrompt(using: promptResolver)
        }

        let trimmedLabel = current.label.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedLabel.isEmpty {
            return step.resolvedPrompt(using: promptResolver)
        }

        return trimmedLabel
    }

    private func getCurrentSlider() -> SliderConfig? {
        guard let sliders = step.sliders, activeSliderIndex < sliders.count else { return nil }
        return sliders[activeSliderIndex]
    }

    private func movedFromCenter(_ index: Int) -> Bool {
        guard index < sliderValues.count && index < step.sliders?.count ?? 0 else { return false }

        // Break down the complex expression into readable steps
        guard let slider = step.sliders?[index] else { return false }
        let minValue = slider.range.min  // Already non-optional Int
        let maxValue = slider.range.max  // Already non-optional Int
        let rangeSum = Double(minValue) + Double(maxValue)
        let rangeAverage = rangeSum / 2.0
        let defaultValue = Int(rangeAverage)

        return sliderValues[index] != defaultValue
    }

    private func getPhaseColor(index: Int, value: Int, slider: SliderConfig) -> Color {
        // Normalize intensity 0..1 based on slider range
        let range = Double(slider.range.max - slider.range.min)
        let intensity = max(0, min(1, Double(value - slider.range.min) / range))

        if index == 0 {
            // Red family (danger → amber as intensity grows)
            let red = 255.0
            let green = 50.0 + intensity * 160.0 // 50 → 210
            let blue = 30.0
            return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
        }
        if index == 1 {
            // Green family (teal → green as intensity grows)
            let red = 20.0 + 40.0 * (1 - intensity) // 60 → 20
            let green = 200.0 + 55.0 * intensity // 200 → 255
            let blue = 150.0 - 80.0 * intensity // 150 → 70
            return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
        }
        // Fallback to semantic mapping for other sliders
        return getSliderColor(index: index, value: value, slider: slider)
    }

    private func getSliderColor(index: Int, value: Int, slider: SliderConfig) -> Color {
        let label = slider.label.lowercased()

        if label.contains("avoid") || label.contains("bad outcome") {
            // Fear/Avoidance slider: red → amber (increasing intensity)
            let intensity = Double(value) / Double(slider.range.max - slider.range.min)
            let red = 255.0
            let green = 100.0 + 155.0 * intensity // 100 to 255 (amber)
            let blue = 20.0
            return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
        } else if label.contains("win") || label.contains("desire") || (label.contains("want") && !label.contains("avoid")) {
            // Desire slider: teal → green (increasing growth energy)
            let intensity = Double(value) / Double(slider.range.max - slider.range.min)
            let red = 20.0 + 50.0 * (1 - intensity) // 70 to 20 (less red as intensity grows)
            let green = 200.0 + 55.0 * intensity // 200 to 255
            let blue = 180.0 - 100.0 * intensity // 180 to 80 (teal to green)
            return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
        }

        // Fallback colors
        let colors = [Color(hex: "#FF6B4A"), Color(hex: "#4AFF6B"), Color(hex: "#4A6BFF"), Color(hex: "#FFD94A")]
        return colors[index % colors.count]
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
    func applyDualSlidersGlassEffect(prominent: Bool, accentColor: Color) -> some View {
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
                    .clipShape(Capsule())
            } else {
                self.background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DualSlidersStep(
        step: StepDefinition(
            id: 12,
            phase: .patternAwareness,
            type: .dualSliders,
            prompt: "RATE YOUR CURRENT SITUATION",
            dbField: ["situation_rating"],
            options: nil,
            helperText: nil,
            sliders: [
                SliderConfig(
                    label: "How much do you want to avoid this situation?",
                    range: SliderConfig.SliderRange(min: 1, max: 10)
                ),
                SliderConfig(
                    label: "How much do you want to achieve the opposite?",
                    range: SliderConfig.SliderRange(min: 1, max: 10)
                )
            ],
            minDuration: nil,
            requiredPhrase: nil,
            displayType: nil
        ),
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#FFD700"),
        onContinue: { _ in print("Continue") }
    )
}

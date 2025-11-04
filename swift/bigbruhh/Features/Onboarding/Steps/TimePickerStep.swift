//
//  TimePickerStep.swift
//  bigbruhh
//
//  Daily Reckoning call time picker (30 minute window)
//  Migrated from: nrn/components/onboarding/steps/TimePickerStep.tsx
//

import SwiftUI

struct TimePickerStep: View {
    let step: StepDefinition
    let promptResolver: any PromptResolving
    let backgroundColor: Color
    let textColor: Color
    let accentColor: Color
    let secondaryAccentColor: Color
    let onContinue: (UserResponse) -> Void

    @State private var selectedIndex: Int = 4 // Default to 20:00 (index 4)
    @State private var opacity: Double = 0
    @State private var flashOpacity: Double = 0

    private let itemHeight: CGFloat = 48
    private let wheelHeight: CGFloat = 280

    // Evening-only: 18:00–23:30 (12 options, 30 min intervals)
    private var timeOptions: [String] {
        (0..<12).map { i in
            let startHour = 18
            let totalMinutes = startHour * 60 + i * 30
            let hour = (totalMinutes / 60) % 24
            let minute = totalMinutes % 60
            return String(format: "%02d:%02d", hour, minute)
        }
    }

    private var selectedTime: String {
        timeOptions[min(selectedIndex, timeOptions.count - 1)]
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Prompt
                VStack(alignment: .leading, spacing: 8) {
                    Text(step.resolvedPrompt(using: promptResolver))
                        .font(.system(size: 28, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("This is when BigBruh calls. No excuses.")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(textColor.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Timezone: \(getCurrentTimezone())")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(0.3)
                        .foregroundColor(textColor.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 64)
                .padding(.bottom, 20)

                // Native Picker
                Picker("Time", selection: $selectedIndex) {
                    ForEach(0..<timeOptions.count, id: \.self) { index in
                        Text(formatTimeForDisplay(timeOptions[index]))
                            .font(.system(size: 18, weight: .bold))
                            .tracking(1.5)
                            .foregroundColor(accentColor)
                            .tag(index)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: wheelHeight)
                .padding(.horizontal, 20)
                .onChange(of: selectedIndex) { _, _ in
                    triggerHaptic(intensity: 0.3)
                }

                Spacer()

                // Continue button - primary action with solid color
                Button(action: handleContinue) {
                    Text("LOCK IT IN")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(2)
                        .textCase(.uppercase)
                        .foregroundColor(Color.buttonTextColor(for: accentColor))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(.plain)
                .background(accentColor)
                .clipShape(Capsule())
                .shadow(color: accentColor.opacity(0.5), radius: 10)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .opacity(opacity)

            // Flash effect
            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)
        }
        .onAppear {
            resetState()
            withAnimation(.easeIn(duration: 0.8)) {
                opacity = 1
            }
        }
        .id(step.id) // Force re-render when step changes
    }

    // MARK: - State Reset

    private func resetState() {
        selectedIndex = 4 // Default to 20:00
        opacity = 0
        flashOpacity = 0
    }

    // MARK: - Helpers

    private func isIOS26Available() -> Bool {
        if #available(iOS 26.0, *) {
            return true
        }
        return false
    }

    private func getEndTime(_ startTime: String) -> String {
        let components = startTime.split(separator: ":").compactMap { Int($0) }
        guard components.count == 2 else { return startTime }

        let hours = components[0]
        let minutes = components[1]
        let totalMinutes = hours * 60 + minutes + 30
        let endHours = (totalMinutes / 60) % 24
        let endMins = totalMinutes % 60

        return String(format: "%02d:%02d", endHours, endMins)
    }

    private func formatTimeForDisplay(_ time: String) -> String {
        let endTime = getEndTime(time)

        let startComponents = time.split(separator: ":").compactMap { Int($0) }
        let endComponents = endTime.split(separator: ":").compactMap { Int($0) }

        guard startComponents.count == 2, endComponents.count == 2 else { return time }

        let startHours = startComponents[0]
        let startMinutes = startComponents[1]
        let startDisplayHour = startHours > 12 ? startHours - 12 : (startHours == 0 ? 12 : startHours)
        _ = startHours >= 12 ? "PM" : "AM"

        let endHours = endComponents[0]
        let endMinutes = endComponents[1]
        let endDisplayHour = endHours > 12 ? endHours - 12 : (endHours == 0 ? 12 : endHours)
        let endPeriod = endHours >= 12 ? "PM" : "AM"

        return String(format: "%d:%02d–%d:%02d %@", startDisplayHour, startMinutes, endDisplayHour, endMinutes, endPeriod)
    }
    
    private func getCurrentTimezone() -> String {
        let timezone = TimeZone.current.identifier
        return timezone.replacingOccurrences(of: "_", with: " ")
                      .replacingOccurrences(of: "/", with: " / ")
    }

    private func handleContinue() {
        triggerHaptic(intensity: 0.5)

        // Flash animation
        withAnimation(.easeIn(duration: 0.08)) {
            flashOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.16)) {
                flashOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                let response = UserResponse(
                    stepId: step.id,
                    type: .timeWindowPicker,
                    value: .timeWindow(ResponseValue.TimeWindow(
                        start: selectedTime,
                        end: getEndTime(selectedTime)
                    )),
                    timestamp: Date(),
                    dbField: step.dbField
                )

                print("\n🕐 === TIME PICKER SELECTION ===")
                print("🔢 Step \(step.id):")
                print("  🕐 Start Time: \"\(selectedTime)\"")
                print("  🕐 End Time: \"\(getEndTime(selectedTime))\"")
                print("  ⏱️  Window Duration: 30 minutes")
                print("  ⏰ Timestamp: \(response.timestamp)")
                print("🕐 === TIME PICKER SUBMITTED ===\n")

                onContinue(response)
            }
        }
    }

    private func triggerHaptic(intensity: Double = 0.5) {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: intensity > 0.8 ? .heavy : intensity > 0.5 ? .medium : .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Preview

#Preview {
    TimePickerStep(
        step: StepDefinition(
            id: 44,
            phase: .externalAnchors,
            type: .timeWindowPicker,
            prompt: "PICK YOUR DAILY RECKONING TIME",
            dbField: ["daily_reckoning_time"],
            options: nil,
            helperText: nil,
            sliders: nil,
            minDuration: nil,
            requiredPhrase: nil,
            displayType: nil
        ),
        promptResolver: StaticPromptResolver(),
        backgroundColor: .black,
        textColor: .white,
        accentColor: Color(hex: "#8B00FF"),
        secondaryAccentColor: Color(hex: "#4B0082"),
        onContinue: { _ in print("Continue") }
    )
}

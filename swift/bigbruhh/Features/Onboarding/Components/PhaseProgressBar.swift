//
//  PhaseProgressBar.swift
//  bigbruhh
//
//  Phase-based progress bar for onboarding
//

import SwiftUI

struct ConversionPhase: Identifiable, Equatable {
    let id: Int
    let title: String
    let range: Range<Int>
}

struct PhaseProgressBar: View {
    let currentStepIndex: Int
    let totalSteps: Int

    // Define phases with ranges based on current step configuration
    // Phase 1: Discovery (Indices 0-15)
    // Phase 2: Reality (Indices 16-26)
    // Phase 3: Solution (Indices 27-30)
    // Phase 4: Commitment (Indices 31-38)
    private let phases: [ConversionPhase] = [
        ConversionPhase(id: 1, title: "Discovery", range: 0..<16),
        ConversionPhase(id: 2, title: "Reality", range: 16..<27),
        ConversionPhase(id: 3, title: "Solution", range: 27..<31),
        ConversionPhase(id: 4, title: "Commitment", range: 31..<100) // Cap at max
    ]

    private var currentPhase: ConversionPhase? {
        phases.first { $0.range.contains(currentStepIndex) }
    }

    var body: some View {
        // Minimal Progress Bars
        HStack(spacing: 2) {
            ForEach(phases) { phase in
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.white.opacity(0.1))

                        // Fill
                        Capsule()
                            .fill(fillColor(for: phase))
                            .frame(width: progressWidth(for: phase, in: geometry.size.width))
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStepIndex)
                    }
                }
                .frame(height: 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    private func fillColor(for phase: ConversionPhase) -> Color {
        if currentStepIndex >= phase.range.upperBound {
            return .brutalRed // Completed phase color
        } else if phase.range.contains(currentStepIndex) {
            return .brutalRed // Active phase color
        } else {
            return Color.white.opacity(0.2) // Future phase
        }
    }

    private func progressWidth(for phase: ConversionPhase, in totalWidth: CGFloat) -> CGFloat {
        if currentStepIndex >= phase.range.upperBound {
            return totalWidth // Full width for completed phases
        } else if phase.range.contains(currentStepIndex) {
            // Calculate relative progress within the phase
            let phaseLength = Double(phase.range.count)
            let progressInPhase = Double(currentStepIndex - phase.range.lowerBound)

            // Add 1 to make it feel like you start with some progress
            let progress = (progressInPhase + 1) / phaseLength
            return totalWidth * CGFloat(min(progress, 1.0))
        } else {
            return 0 // Empty for future phases
        }
    }
}

struct PhaseProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 40) {
                PhaseProgressBar(currentStepIndex: 0, totalSteps: 40) // Start Phase 1
                PhaseProgressBar(currentStepIndex: 8, totalSteps: 40) // Mid Phase 1
                PhaseProgressBar(currentStepIndex: 15, totalSteps: 40) // End Phase 1
                PhaseProgressBar(currentStepIndex: 16, totalSteps: 40) // Start Phase 2
                PhaseProgressBar(currentStepIndex: 28, totalSteps: 40) // Phase 3
                PhaseProgressBar(currentStepIndex: 35, totalSteps: 40) // Phase 4
            }
        }
    }
}


//
//  ConversionOnboardingContainer.swift
//  bigbruhh
//
//  Main container for 42-step conversion onboarding flow
//

import SwiftUI

struct ConversionOnboardingContainer: View {
    let onComplete: (ConversionOnboardingResponse) -> Void

    @StateObject private var state = ConversionOnboardingState()

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            // Current step view
            currentStepView
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            // Progress Bar Overlay
            if !state.currentStep.isAICommentary && !state.currentStep.isLoading {
                VStack {
                    PhaseProgressBar(
                        currentStepIndex: state.currentStepIndex,
                        totalSteps: state.totalSteps
                    )
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: state.currentStepIndex)
        .onAppear {
            // FORCE FRESH START: Always reset to step 1 (index 0)
            #if DEBUG
            let currentStepId = state.currentStep.id
            print("🔍 ConversionOnboardingContainer onAppear:")
            print("   currentStepIndex: \(state.currentStepIndex)")
            print("   currentStep.id: \(currentStepId)")
            #endif

            // ALWAYS clear state on appear, even if at index 0
            // This ensures we truly start fresh every time
            #if DEBUG
            print("🧹 FORCING COMPLETE RESET to step 1 regardless of current state")
            #endif
            state.clearState()

            #if DEBUG
            print("✅ Reset complete - now at step \(state.currentStep.id) (index \(state.currentStepIndex))")
            #endif
        }
    }

    @ViewBuilder
    private var currentStepView: some View {
        let step = state.currentStep

        switch step.type {
        case .explanatory(let config):
            ExplanatoryStepView(config: config, onContinue: handleContinue)

        case .aiCommentary(let config):
            AICommentaryView(config: config, onContinue: handleContinue)
                .id(step.id)

        case .debate(let messages):
            // Handle dynamic debate messages (e.g., step 19)
            let debateMessages = step.id == 19 ? state.getDebateMessagesForStep19() : messages
            TwoFuturesDebateView(messages: debateMessages, onContinue: handleContinue)

        case .input(let config):
            TwoFuturesInputView(config: config, onSubmit: { response in
                handleInput(response, forStepId: step.id)
            })
            .id(step.id)

        case .demoCall:
            DemoCallView(onComplete: handleContinue)
                .environmentObject(state)

        case .permissionRequest(let type):
            PermissionRequestView(permissionType: type, onComplete: { granted in
                handlePermission(type, granted: granted)
            })
            .id("\(step.id)_\(type.rawValue)")

        case .loading(let config):
            CreatingFutureYouView(config: config, onComplete: handleContinue)
                .environmentObject(state)
                .id(step.id)

        case .commitmentCard:
            CommitmentCardView(onContinue: handleContinue)
                .environmentObject(state)
                .id(step.id)
        }
    }

    // MARK: - Event Handlers

    private func handleContinue() {
        // Check if we're at the last step before advancing
        if state.currentStepIndex >= state.totalSteps - 1 {
            // Complete onboarding and navigate to paywall
            if let response = state.compileFinalResponse() {
                print("✅ Conversion onboarding complete - navigating to paywall")
                onComplete(response)
            } else {
                print("❌ Failed to compile onboarding response")
            }
        } else {
            // Continue to next step
            withAnimation {
                state.nextStep()
            }
        }
    }

    private func handleInput(_ response: String, forStepId stepId: Int) {
        // Save the response
        state.saveResponse(response, forStepId: stepId)

        // Handle voice recordings with specific keys
        if case .input(let config) = state.currentStep.type,
           case .voice = config.inputType {
            if let url = URL(string: response) {
                let key = "step_\(stepId)"
                state.saveVoiceRecording(url, forKey: key)
            }
        }

        // Continue to next step
        handleContinue()
    }

    private func handlePermission(_ type: PermissionType, granted: Bool) {
        state.savePermission(type, granted: granted)
        handleContinue()
    }
}

#Preview {
    ConversionOnboardingContainer(onComplete: { response in
        print("Preview: Onboarding completed")
        print("Goal: \(response.goal)")
    })
}

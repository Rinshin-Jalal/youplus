//
//  ConversionOnboardingState.swift
//  bigbruhh
//
//  State management for 42-step conversion onboarding
//

import Foundation
import Combine

class ConversionOnboardingState: ObservableObject {
    @Published var currentStepIndex: Int = 0
    @Published var responses: [Int: String] = [:]  // stepId -> response
    @Published var voiceRecordings: [String: URL] = [:]  // key -> URL
    @Published var permissionsGranted: [PermissionType: Bool] = [:]
    @Published var isComplete: Bool = false
    @Published var sessionStartTime: Date = Date()

    // Voice cloning and demo call
    @Published var voiceCloneID: String?
    @Published var demoCallAudioURL: URL?
    @Published var demoCallTranscript: String?

    // Generated Content
    @Published var generatedCommitmentVideoURL: URL?
    @Published var generatedCommitmentAudioURL: URL?

    private let userDefaultsKey = "ConversionOnboardingState"

    init() {
        // FORCE FRESH START: Always start from step 1 (index 0)
        // Clear any saved state immediately - be aggressive about it
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // Also clear any variations of the key that might exist
        UserDefaults.standard.removeObject(forKey: "ConversionOnboardingState")
        UserDefaults.standard.removeObject(forKey: "conversion_onboarding_state")
        UserDefaults.standard.removeObject(forKey: "onboarding_state")
        
        UserDefaults.standard.synchronize()
        
        // Explicitly set to 0 BEFORE any other initialization
        currentStepIndex = 0
        responses = [:]
        voiceRecordings = [:]
        permissionsGranted = [:]
        isComplete = false
        sessionStartTime = Date()
        
        #if DEBUG
        print("🔄 ConversionOnboardingState.init(): FORCED fresh start")
        print("   currentStepIndex = \(currentStepIndex)")
        print("   Step ID: \(CONVERSION_ONBOARDING_STEPS[currentStepIndex].id)")
        print("   Cleared all UserDefaults keys")
        #endif
        
        // Don't call loadState() - we want a fresh start every time
        // loadState() // DISABLED
    }

    // MARK: - Navigation

    var currentStep: ConversionOnboardingStep {
        CONVERSION_ONBOARDING_STEPS[currentStepIndex]
    }

    var canGoBack: Bool {
        currentStepIndex > 0
    }

    var canProceed: Bool {
        let step = currentStep

        // Explanatory, AI commentary, debate, demo call can always proceed
        if step.isExplanatory || step.isAICommentary || step.isDebate || step.isDemoCall {
            return true
        }

        // Permission requests can proceed after attempting
        if step.isPermissionRequest {
            return true
        }

        // Input steps require a response
        if step.isInput {
            return responses[step.id] != nil
        }

        return true
    }

    var progress: Double {
        Double(currentStepIndex) / Double(CONVERSION_ONBOARDING_STEPS.count)
    }

    var totalSteps: Int {
        CONVERSION_ONBOARDING_STEPS.count
    }

    func nextStep() {
        guard currentStepIndex < CONVERSION_ONBOARDING_STEPS.count - 1 else {
            completeOnboarding()
            return
        }

        currentStepIndex += 1
        saveState()
    }

    func previousStep() {
        guard canGoBack else { return }
        currentStepIndex -= 1
        saveState()
    }

    func jumpToStep(_ index: Int) {
        guard index >= 0 && index < CONVERSION_ONBOARDING_STEPS.count else { return }
        currentStepIndex = index
        saveState()
    }

    // MARK: - Response Management

    func saveResponse(_ response: String, forStepId stepId: Int) {
        responses[stepId] = response
        saveState()
    }

    func saveVoiceRecording(_ url: URL, forKey key: String) {
        voiceRecordings[key] = url
        saveState()
    }

    func savePermission(_ type: PermissionType, granted: Bool) {
        permissionsGranted[type] = granted
        saveState()
    }

    func getResponse(forStepId stepId: Int) -> String? {
        responses[stepId]
    }

    func getVoiceRecording(forKey key: String) -> URL? {
        voiceRecordings[key]
    }

    // MARK: - Dynamic Content

    /// Get debate messages for step 19 based on excuse choice from step 14
    func getDebateMessagesForStep19() -> [DebateMessage] {
        guard let excuse = responses[14] else {
            return getDebateMessagesForExcuse("default")
        }
        return getDebateMessagesForExcuse(excuse)
    }

    // MARK: - State Persistence

    private func saveState() {
        // Convert PermissionType enum keys to String for UserDefaults
        var permissionsDict: [String: Bool] = [:]
        for (key, value) in permissionsGranted {
            permissionsDict[key.rawValue] = value
        }

        let _state: [String: Any] = [
            "currentStepIndex": currentStepIndex,
            "responses": responses,
            "voiceRecordings": voiceRecordings.mapValues { $0.absoluteString },
            "permissionsGranted": permissionsDict,
            "sessionStartTime": sessionStartTime.timeIntervalSince1970
        ]

//        UserDefaults.standard.set(state, forKey: userDefaultsKey)
    }

    private func loadState() {
        // FORCE FRESH START: Always start from step 1 (index 0)
        // Clear any saved state to prevent resuming from previous session
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.synchronize()
        
        #if DEBUG
        print("🔄 ConversionOnboardingState: Forced fresh start - cleared saved state")
        #endif
        
        // Always start at index 0 (step 1)
        currentStepIndex = 0
        return
                if let permissionType = PermissionType(rawValue: key) {
                    permissionsDict[permissionType] = value
                }
            }
            permissionsGranted = permissionsDict
        }

        if let startTime = state["sessionStartTime"] as? TimeInterval {
            sessionStartTime = Date(timeIntervalSince1970: startTime)
        }
        */
    }

    func clearState() {
        currentStepIndex = 0
        responses = [:]
        voiceRecordings = [:]
        permissionsGranted = [:]
        isComplete = false
        sessionStartTime = Date()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Completion

    private func completeOnboarding() {
        isComplete = true
        saveState()
    }

    func compileFinalResponse() -> ConversionOnboardingResponse? {
        // Extract all required responses by step ID (mapped to 38-step flow)
        guard let goal = responses[5],                          // Step 5: what keeps failing
              let goalDeadlineString = responses[6],            // Step 6: deadline (datePicker)
              let motivationLevelString = responses[7],         // Step 7: how badly (1-10)
              let whyItMattersURL = voiceRecordings["step_8"],  // Step 8: why can't let go (voice)
              let attemptCountString = responses[12],           // Step 12: how many times tried
              let lastAttempt = responses[13],                  // Step 13: how did you quit
              let excuse = responses[14],                       // Step 14: favorite excuse
              let disappointed = responses[10],                 // Step 10: who disappointed
              let costOfQuittingURL = voiceRecordings["step_23"], // Step 23: what dies if quit (voice)
              let futureIfNoChange = responses[24],             // Step 24: where in 6 months
              let dailyCommitment = responses[34],              // Step 34: daily action
              let callTimeString = responses[35],               // Step 35: call time (timePicker)
              let strikeLimitString = responses[36],            // Step 36: days can miss (1-5)
              let commitmentVoiceURL = voiceRecordings["step_38"] else { // Step 38: what happens if fail (voice)
            #if DEBUG
            print("❌ Failed to compile response - missing required fields:")
            print("   goal (step 5): \(responses[5] != nil)")
            print("   goalDeadline (step 6): \(responses[6] != nil)")
            print("   motivationLevel (step 7): \(responses[7] != nil)")
            print("   whyItMatters (step 8 voice): \(voiceRecordings["step_8"] != nil)")
            print("   attemptCount (step 12): \(responses[12] != nil)")
            print("   lastAttempt (step 13): \(responses[13] != nil)")
            print("   excuse (step 14): \(responses[14] != nil)")
            print("   disappointed (step 10): \(responses[10] != nil)")
            print("   costOfQuitting (step 23 voice): \(voiceRecordings["step_23"] != nil)")
            print("   futureIfNoChange (step 24): \(responses[24] != nil)")
            print("   dailyCommitment (step 34): \(responses[34] != nil)")
            print("   callTime (step 35): \(responses[35] != nil)")
            print("   strikeLimit (step 36): \(responses[36] != nil)")
            print("   commitmentVoice (step 38 voice): \(voiceRecordings["step_38"] != nil)")
            #endif
            return nil
        }

        // Parse dates and numbers
        let goalDeadline = ISO8601DateFormatter().date(from: goalDeadlineString) ?? Date()
        let motivationLevel = Int(motivationLevelString) ?? 5
        let attemptCount = Int(attemptCountString) ?? 0
        let callTime = ISO8601DateFormatter().date(from: callTimeString) ?? Date()
        let strikeLimit = Int(strikeLimitString) ?? 3

        // Step 11: biggest obstacle (use as previous attempt outcome)
        let previousAttempt = responses[11] ?? "Unknown obstacle"

        // Step 15: when do you usually quit (text) - convert to placeholder date
        // Since this is descriptive text, we'll use a placeholder date
        let quitTime = Date()

        // Defaults for missing fields (not in 35-step flow)
        let willDoThis = true  // They completed onboarding, so yes
        let chosenPath: ConversionOnboardingResponse.PathChoice = .hopeful
        let witness = "None"  // Removed from flow

        // Time spent
        let totalTimeSpent = Date().timeIntervalSince(sessionStartTime)

        return ConversionOnboardingResponse(
            goal: goal,
            goalDeadline: goalDeadline,
            motivationLevel: motivationLevel,
            whyItMatters: whyItMattersURL,
            attemptCount: attemptCount,
            lastAttemptOutcome: lastAttempt,
            previousAttemptOutcome: previousAttempt,
            favoriteExcuse: excuse,
            whoDisappointed: disappointed,
            quitTime: quitTime,
            costOfQuitting: costOfQuittingURL,
            futureIfNoChange: futureIfNoChange,
            dailyCommitment: dailyCommitment,
            callTime: callTime,
            strikeLimit: strikeLimit,
            commitmentVoice: commitmentVoiceURL,
            witness: witness,
            willDoThis: willDoThis,
            chosenPath: chosenPath,
            notificationsGranted: permissionsGranted[.notifications] ?? false,
            callsGranted: permissionsGranted[.calls] ?? false,
            completedAt: Date(),
            totalTimeSpent: totalTimeSpent
        )
    }

    // MARK: - Helper for Variable Replacement

    func resolveText(_ text: String) -> String {
        var resolved = text

        // Replace common variables
        if let goal = responses[5] {
            resolved = resolved.replacingOccurrences(of: "{{goal}}", with: goal)
        }
        if let commitment = responses[34] {
            resolved = resolved.replacingOccurrences(of: "{{commitment}}", with: commitment)
        }
        if let excuse = responses[14] {
            resolved = resolved.replacingOccurrences(of: "{{excuse}}", with: excuse)
        }

        return resolved
    }
}

// MARK: - PermissionType RawRepresentable

extension PermissionType: RawRepresentable {
    var rawValue: String {
        switch self {
        case .notifications: return "notifications"
        case .calls: return "calls"
        case .microphone: return "microphone"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "notifications": self = .notifications
        case "calls": self = .calls
        case "microphone": self = .microphone
        default: return nil
        }
    }
}

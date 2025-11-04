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

    private let userDefaultsKey = "ConversionOnboardingState"

    init() {
        loadState()
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

    /// Get debate messages for step 19 based on excuse choice from step 16
    func getDebateMessagesForStep19() -> [DebateMessage] {
        guard let excuse = responses[16] else {
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

        let state: [String: Any] = [
            "currentStepIndex": currentStepIndex,
            "responses": responses,
            "voiceRecordings": voiceRecordings.mapValues { $0.absoluteString },
            "permissionsGranted": permissionsDict,
            "sessionStartTime": sessionStartTime.timeIntervalSince1970
        ]

//       Us÷erDefaults.standard.set(state, forKey: userDefaultsKey)
    }

    private func loadState() {
        guard let state = UserDefaults.standard.dictionary(forKey: userDefaultsKey) else {
            return
        }

        if let index = state["currentStepIndex"] as? Int {
            currentStepIndex = index
        }

        if let savedResponses = state["responses"] as? [Int: String] {
            responses = savedResponses
        }

        if let savedVoiceURLs = state["voiceRecordings"] as? [String: String] {
            voiceRecordings = savedVoiceURLs.compactMapValues { URL(string: $0) }
        }

        if let savedPermissions = state["permissionsGranted"] as? [String: Bool] {
            var permissionsDict: [PermissionType: Bool] = [:]
            for (key, value) in savedPermissions {
                if let permissionType = PermissionType(rawValue: key) {
                    permissionsDict[permissionType] = value
                }
            }
            permissionsGranted = permissionsDict
        }

        if let startTime = state["sessionStartTime"] as? TimeInterval {
            sessionStartTime = Date(timeIntervalSince1970: startTime)
        }
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
        // Extract all required responses by step ID
        guard let goal = responses[6],
              let goalDeadlineString = responses[7],
              let motivationLevelString = responses[8],
              let whyItMattersURL = voiceRecordings["step_9"],
              let attemptCountString = responses[11],
              let lastAttempt = responses[12],
              let previousAttempt = responses[13],
              let excuse = responses[16],
              let disappointed = responses[17],
              let quitTimeString = responses[18],
              let costOfQuittingURL = voiceRecordings["step_21"],
              let futureIfNoChange = responses[22],
              let dailyCommitment = responses[32],
              let callTimeString = responses[33],
              let strikeLimitString = responses[34],
              let commitmentVoiceURL = voiceRecordings["step_35"],
              let witness = responses[36],
              let willDoThisString = responses[38],
              let chosenPathString = responses[40] else {
            return nil
        }

        // Parse dates and numbers
        let goalDeadline = ISO8601DateFormatter().date(from: goalDeadlineString) ?? Date()
        let motivationLevel = Int(motivationLevelString) ?? 5
        let attemptCount = Int(attemptCountString) ?? 0
        let quitTime = ISO8601DateFormatter().date(from: quitTimeString) ?? Date()
        let callTime = ISO8601DateFormatter().date(from: callTimeString) ?? Date()
        let strikeLimit = Int(strikeLimitString) ?? 3

        // Parse decisions
        let willDoThis = willDoThisString.lowercased().contains("yes")
        let chosenPath: ConversionOnboardingResponse.PathChoice =
            chosenPathString.lowercased().contains("hopeful") ? .hopeful : .doubtful

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
        if let goal = responses[6] {
            resolved = resolved.replacingOccurrences(of: "{{goal}}", with: goal)
        }
        if let commitment = responses[32] {
            resolved = resolved.replacingOccurrences(of: "{{commitment}}", with: commitment)
        }
        if let excuse = responses[16] {
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

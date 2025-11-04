//
//  OnboardingSoundManager.swift
//  bigbruhh
//
//  Sound effects and ambient music manager for onboarding
//  Migrated from: nrn/components/onboarding/useOnboardingSound.ts
//

import Foundation
import AVFoundation
import Combine

class OnboardingSoundManager: ObservableObject {
    // MARK: - Audio Players

    private var subBassPlayer: AVAudioPlayer?
    private var tickingPlayer: AVAudioPlayer?
    private var successPlayer: AVAudioPlayer?
    private var glitchPlayer: AVAudioPlayer?
    private var glitchLongPlayer: AVAudioPlayer?

    @Published var isAmbientPlaying = false
    private var currentAmbientFile: String?

    private let milestoneSuccessSteps: Set<Int> = [
        5,  // First psychological shift
        7,  // "Think" voice confession
        12, // "Kill potential" choice confrontation
        16, // Confrontation peak
        22, // Pattern admission
        27, // Identity rebuild declaration
        31, // Enemy naming
        35, // War cry
        39, // External anchor definition
        43  // Final seal hold
    ]

    private let tickingAmbientSteps: Set<Int> = [
        11, 12, 15, 16, // Late confrontation cadence
        22, 23, 24, 26, // Pattern analysis pressure
        32, 33, 34, 35, 36, // Commitment system rituals
        39, 40, 41, 42, 43, 44 // External anchors and oath sealing
    ]

    // MARK: - Initialization

    init() {
        setupAudioSession()
        loadAudioPlayers()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session: \(error)")
        }
    }

    private func loadAudioPlayers() {
        // Ambient loops
        subBassPlayer = loadAudio(named: "sub_bass", type: "mp3", volume: 0.04)
        subBassPlayer?.numberOfLoops = -1 // Infinite loop

        tickingPlayer = loadAudio(named: "ticking-clock", type: "mp3", volume: 0.015)
        tickingPlayer?.numberOfLoops = -1

        // Sound effects (one-shots)
        successPlayer = loadAudio(named: "success", type: "mp3", volume: 0.08)
        glitchPlayer = loadAudio(named: "glitch", type: "mp3", volume: 0.12)
        glitchLongPlayer = loadAudio(named: "glitch-long", type: "mp3", volume: 0.006)
    }

    private func loadAudio(named name: String, type: String, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: type) else {
            print("⚠️ Audio file not found: \(name).\(type)")
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            return player
        } catch {
            print("⚠️ Failed to load audio \(name): \(error)")
            return nil
        }
    }

    // MARK: - Ambient Music Logic

    /// Determines which ambient audio to play based on phase and step type
    private func getContextualAudio(phase: OnboardingPhase, stepType: StepType, stepId: Int, recordingTime: TimeInterval? = nil) -> String? {
        if tickingAmbientSteps.contains(stepId) {
            return "ticking"
        }

        if stepType == .voice, let time = recordingTime, time > 30 {
            return "sub_bass"
        }

        if stepType == .voice, stepId >= 22, stepId <= 27 {
            return "sub_bass"
        }

        return nil
    }

    /// Update ambient music based on current step
    func updateAmbientForStep(stepId: Int, phase: OnboardingPhase, stepType: StepType, recordingTime: TimeInterval? = nil) {
        let selection = getContextualAudio(phase: phase, stepType: stepType, stepId: stepId, recordingTime: recordingTime)

        guard let audioFile = selection else {
            if isAmbientPlaying {
                stopAmbient()
            }
            return
        }

        // Don't restart if already playing the correct file
        if currentAmbientFile == audioFile {
            return
        }

        playAmbient(audioFile)
    }

    private func playAmbient(_ kind: String) {
        stopAmbient()

        let player: AVAudioPlayer?
        switch kind {
        case "sub_bass":
            player = subBassPlayer
        case "ticking":
            player = tickingPlayer
        default:
            return
        }

        player?.currentTime = 0
        player?.play()

        currentAmbientFile = kind
        isAmbientPlaying = true

        print("🎵 Playing ambient: \(kind)")
    }

    func stopAmbient() {
        subBassPlayer?.pause()
        tickingPlayer?.pause()
        isAmbientPlaying = false
        currentAmbientFile = nil
    }

    // MARK: - Sound Effects

    /// Play success sound on step completion
    func playSuccess(for stepId: Int) {
        guard milestoneSuccessSteps.contains(stepId) else { return }
        successPlayer?.currentTime = 0
        successPlayer?.play()
    }

    /// Play glitch sound for phase transitions
    func playGlitch() {
        glitchPlayer?.currentTime = 0
        glitchPlayer?.play()
    }

    /// Play sharp snap sound for ritual moments
    func playSnap() {
        successPlayer?.volume = 0.2
        successPlayer?.currentTime = 0
        successPlayer?.play()

        // Reset volume for normal success sounds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.successPlayer?.volume = 0.08
        }
    }

    /// Play long glitch sound for seal completion (very quiet)
    func playGlitchLong() {
        glitchLongPlayer?.currentTime = 0
        glitchLongPlayer?.play()
    }

    // MARK: - Cleanup

    deinit {
        stopAmbient()
    }
}

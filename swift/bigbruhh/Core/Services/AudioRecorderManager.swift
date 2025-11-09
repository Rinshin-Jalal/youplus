//
//  AudioRecorderManager.swift
//  bigbruhh
//
//  Audio recording manager for voice input in onboarding
//

import Foundation
import AVFoundation

class AudioRecorderManager {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var isPaused: Bool = false

    // MARK: - Permission

    func requestPermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                if !granted {
                    print("⚠️ Microphone permission denied")
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    print("⚠️ Microphone permission denied")
                }
            }
        }
    }

    // MARK: - Recording

    func startRecording() -> Bool {
        // Request permission first
        let audioSession = AVAudioSession.sharedInstance()

        let hasPermission: Bool
        if #available(iOS 17.0, *) {
            hasPermission = AVAudioApplication.shared.recordPermission == .granted
        } else {
            hasPermission = audioSession.recordPermission == .granted
        }

        guard hasPermission else {
            requestPermission()
            return false
        }

        do {
            // Configure audio session
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)

            // Create temporary file URL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFileName = "recording_\(Date().timeIntervalSince1970).m4a"
            recordingURL = documentsPath.appendingPathComponent(audioFileName)

            guard let url = recordingURL else { return false }

            // Audio settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]

            // Create recorder
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()

            // Start recording
            guard audioRecorder?.record() == true else {
                print("❌ Failed to start recording")
                return false
            }

            isPaused = false
            print("✅ Recording started")
            return true

        } catch {
            print("❌ Failed to setup recording: \(error)")
            return false
        }
    }

    func pauseRecording() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.pause()
        isPaused = true
        print("⏸️ Recording paused")
    }

    func resumeRecording() -> Bool {
        guard let recorder = audioRecorder, isPaused else { return false }

        guard recorder.record() else {
            print("❌ Failed to resume recording")
            return false
        }

        isPaused = false
        print("▶️ Recording resumed")
        return true
    }

    func stopRecording() -> Data? {
        guard let recorder = audioRecorder else { return nil }

        recorder.stop()

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }

        // Read audio data
        guard let url = recordingURL else {
            print("❌ No recording URL found")
            return nil
        }

        do {
            let audioData = try Data(contentsOf: url)
            print("✅ Audio data read: \(audioData.count) bytes")

            // Cleanup
            audioRecorder = nil
            recordingURL = nil
            isPaused = false

            return audioData
        } catch {
            print("❌ Failed to read audio data: \(error)")
            return nil
        }
    }
}

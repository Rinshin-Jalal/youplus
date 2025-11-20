import Foundation
import AVFoundation

/// A structure representing an audio recording used in a demo call.
/// 
/// Contains the URL of the audio file, its transcript, and the duration of the audio in seconds.
public struct DemoCallAudio {
    /// The URL pointing to the audio file.
    public let audioURL: URL
    
    /// The transcript of the audio content.
    public let transcript: String
    
    /// The duration of the audio in seconds.
    public let duration: Double
    
    /// Creates a new `DemoCallAudio` instance.
    /// 
    /// - Parameters:
    ///   - audioURL: The URL of the audio file.
    ///   - transcript: The transcript of the audio.
    ///   - duration: The duration of the audio in seconds.
    public init(audioURL: URL, transcript: String, duration: Double) {
        self.audioURL = audioURL
        self.transcript = transcript
        self.duration = duration
    }
}

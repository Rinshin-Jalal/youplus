//
//  VideoExporter.swift
//  bigbruhh
//
//  Created by Antigravity on 2025-11-20.
//

import Foundation
import AVFoundation
import UIKit

enum VideoExportError: Error {
    case audioLoadFailed
    case videoWriterInitializationFailed
    case videoInputInitializationFailed
    case pixelBufferAdaptorInitializationFailed
    case assetWriterStartFailed
    case pixelBufferCreationFailed
    case exportSessionFailed
}

class VideoExporter {
    static let shared = VideoExporter()
    
    private init() {}
    
    /// Exports a video by combining a static image and an audio file.
    /// - Parameters:
    ///   - image: The static image to display throughout the video.
    ///   - audioURL: The URL of the audio file to play.
    ///   - completion: Called with the URL of the generated video file, or nil if failed.
    func exportVideo(from image: UIImage, audioURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVURLAsset(url: audioURL)
        
        // Load duration asynchronously
        Task {
            do {
                let duration = try await asset.load(.duration)
                let durationSeconds = CMTimeGetSeconds(duration)
                
                // Ensure we have a valid duration
                guard durationSeconds > 0 else {
                    completion(.failure(VideoExportError.audioLoadFailed))
                    return
                }
                
                self.createVideo(image: image, audioAsset: asset, duration: duration, completion: completion)
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func createVideo(image: UIImage, audioAsset: AVAsset, duration: CMTime, completion: @escaping (Result<URL, Error>) -> Void) {
        let outputFileName = "commitment_card_\(UUID().uuidString).mp4"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName)
        
        // Remove existing file if any
        try? FileManager.default.removeItem(at: outputURL)
        
        // Video Settings
        // Use a standard resolution, e.g., 1080x1080 for square, or match image aspect ratio
        // For safety, let's ensure dimensions are even numbers
        let width = Int(image.size.width) / 2 * 2
        let height = Int(image.size.height) / 2 * 2
        let videoSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            completion(.failure(VideoExportError.videoWriterInitializationFailed))
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoWriterInput.expectsMediaDataInRealTime = false
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        } else {
            completion(.failure(VideoExportError.videoInputInitializationFailed))
            return
        }
        
        // Audio Setup
        let audioTrack = audioAsset.tracks(withMediaType: .audio).first
        var audioWriterInput: AVAssetWriterInput?
        
        if let audioTrack = audioTrack {
            let audioOutputSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100.0,
                AVEncoderBitRateKey: 128000
            ]
            
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioOutputSettings)
            audioWriterInput?.expectsMediaDataInRealTime = false
            
            if let input = audioWriterInput, videoWriter.canAdd(input) {
                videoWriter.add(input)
            }
        }
        
        // Start Writing
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        // Write Video Frame (Static Image)
        let frameDuration = CMTime(value: 1, timescale: 30) // 30 FPS
        let totalFrames = Int(duration.seconds * 30)
        
        videoWriterInput.requestMediaDataWhenReady(on: DispatchQueue(label: "videoQueue")) {
            guard let pixelBuffer = self.pixelBuffer(from: image, size: videoSize) else {
                print("Failed to create pixel buffer")
                return
            }
            
            // We only need to append one frame that lasts the whole duration?
            // Actually, for a static image video, we usually append the same buffer at increasing timestamps
            // OR just one frame with a long duration if the player supports it, but safer to write frames.
            // Optimization: Write one frame at time 0.
            
            if videoWriterInput.isReadyForMoreMediaData {
                pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: .zero)
            }
            
            // And maybe one at the end to ensure duration?
            // Let's try writing just the first frame and see if it holds.
            // Usually for static video, we need to feed it frames or it might be black after the first frame.
            // Let's write a frame every second to be safe but efficient.
            
            var frameCount = 0
            while videoWriterInput.isReadyForMoreMediaData && frameCount < totalFrames {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                if !pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    break
                }
                frameCount += 1
            }
            
            videoWriterInput.markAsFinished()
            
            // Handle Audio
            if let audioInput = audioWriterInput, let track = audioTrack {
                // We need to read from the audio asset and write to the writer
                // This requires an AVAssetReader
                self.processAudio(asset: audioAsset, track: track, writerInput: audioInput) {
                    videoWriter.finishWriting {
                        DispatchQueue.main.async {
                            if videoWriter.status == .completed {
                                completion(.success(outputURL))
                            } else {
                                completion(.failure(videoWriter.error ?? VideoExportError.exportSessionFailed))
                            }
                        }
                    }
                }
            } else {
                // No audio, just finish
                videoWriter.finishWriting {
                    DispatchQueue.main.async {
                        if videoWriter.status == .completed {
                            completion(.success(outputURL))
                        } else {
                            completion(.failure(videoWriter.error ?? VideoExportError.exportSessionFailed))
                        }
                    }
                }
            }
        }
    }
    
    private func processAudio(asset: AVAsset, track: AVAssetTrack, writerInput: AVAssetWriterInput, completion: @escaping () -> Void) {
        guard let reader = try? AVAssetReader(asset: asset) else {
            writerInput.markAsFinished()
            completion()
            return
        }
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        if reader.canAdd(readerOutput) {
            reader.add(readerOutput)
        } else {
            writerInput.markAsFinished()
            completion()
            return
        }
        
        reader.startReading()
        
        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "audioQueue")) {
            while writerInput.isReadyForMoreMediaData {
                if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(sampleBuffer)
                } else {
                    writerInput.markAsFinished()
                    completion()
                    break
                }
            }
        }
    }
    
    private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixelData,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(origin: .zero, size: size))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}

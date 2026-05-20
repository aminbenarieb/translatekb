import Foundation

/// Minimal audio container passed to `VoiceProvider.transcribe(_:language:)`.
/// PCM-encoded for v2 simplicity — the keyboard captures via `AVAudioEngine`
/// and hands the raw float32 samples here. Compression would buy us nothing
/// on-device (Apple Speech reads PCM directly).
public struct AudioBuffer: Sendable {
    public let samples: Data
    public let sampleRate: Int
    public let channels: Int

    public init(samples: Data, sampleRate: Int, channels: Int = 1) {
        self.samples = samples
        self.sampleRate = sampleRate
        self.channels = channels
    }
}

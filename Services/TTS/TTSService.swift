import AVFoundation

@MainActor
final class TTSService: NSObject, AVSpeechSynthesizerDelegate {
    private lazy var synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, lang: String = "es-MX", rate: Float = AVSpeechUtteranceDefaultSpeechRate) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🔊 TTS terminó de hablar: \(utterance.speechString)")
    }
}

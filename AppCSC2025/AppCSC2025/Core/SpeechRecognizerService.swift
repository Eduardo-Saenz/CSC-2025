import Foundation
import Speech
import AVFoundation

@MainActor
final class SpeechRecognizerService: ObservableObject {
    var onPartial: ((String) -> Void)?
    var onFinal: ((String) -> Void)?
    var onError: ((Error) -> Void)?

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var lastPartialUpdate = Date()

    static func ensurePermissions() async throws {
        try await withCheckedThrowingContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted { continuation.resume() }
                else { continuation.resume(throwing: NSError(domain: "Speech", code: 1)) }
            }
        }

        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized: break
        case .notDetermined:
            try await withCheckedThrowingContinuation { cont in
                SFSpeechRecognizer.requestAuthorization { status in
                    if status == .authorized { cont.resume() }
                    else { cont.resume(throwing: NSError(domain: "Speech", code: 2)) }
                }
            }
        default:
            throw NSError(domain: "Speech", code: 3)
        }
    }

    func start(locale: Locale) throws {
        stop()
        let recognizer = SFSpeechRecognizer(locale: locale)
        guard recognizer?.isAvailable == true else {
            throw NSError(domain: "Speech", code: 4)
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString
                let now = Date()
                if now.timeIntervalSince(self.lastPartialUpdate) > 1.5 {
                    self.onPartial?(text)
                    self.lastPartialUpdate = now
                }
                if result.isFinal {
                    self.onFinal?(text)
                }
            }
            if let error = error {
                self.onError?(error)
                self.stop()
            }
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true)

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    func stop() {
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
}


//

import Foundation
final class SubtitleService {
    private let langDetector = LanguageDetectionService()
    private let translator: TranslationService

    init(translator: TranslationService = NoOpTranslationService()) {
        self.translator = translator
    }

    func processChunk(
        _ text: String,
        targetLang: String?,
        start: TimeInterval,
        end: TimeInterval,
        latency: TimeInterval
    ) async -> TranscriptSegment {

        let src = langDetector.detectLanguage(for: text) ?? "und"

        // Traducir si se requiere
        var translated: String? = nil
        if let target = targetLang, target != src, !text.isEmpty {
            translated = try? await translator.translate(text, from: src, to: target)
        }

        return TranscriptSegment(
            text: text,
            sourceLang: src,
            targetLang: targetLang,
            translatedText: translated,
            startTime: start,
            endTime: end,
            latencyMs: latency * 1000.0
        )
    }
}

/// Modelo de subtítulo para visualización
struct TranscriptSegment: Identifiable {
    let id = UUID()
    let text: String
    let sourceLang: String
    let targetLang: String?
    let translatedText: String?
    let startTime: TimeInterval
    let endTime: TimeInterval
    let latencyMs: Double
}

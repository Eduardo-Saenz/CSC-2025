//
//  OCRProcessor.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import Foundation
import Vision

final class OCRProcessor {
    private let translator = TranslationService()
    var recognitionLevel: VNRequestTextRecognitionLevel = .accurate
    var minimumTextHeight: Float = 0.02
    var confidenceThreshold: Float = 0.50

    func scanAndTranslateText(
        pixelBuffer: CVPixelBuffer,
        target: RecognizedLanguage,
        forceSource: RecognizedLanguage? = nil
    ) async -> (translated: String, avgConfidence: Float) {
        let (raw, avg) = await recognize(pixelBuffer: pixelBuffer)
        guard avg >= confidenceThreshold else { return ("", avg) }

        let src = forceSource ?? (LanguageDetector.detect(raw) ?? .es)
        let t = await translator.translate(raw, from: src, to: target)
        return (t, avg)
    }

    func recognize(pixelBuffer: CVPixelBuffer) async -> (text: String, avgConfidence: Float) {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = recognitionLevel
        request.usesLanguageCorrection = true
        request.minimumTextHeight = minimumTextHeight

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try handler.perform([request])
            guard let results = request.results else { return ("", 0) }

            var texts: [String] = []
            var confidences: [Float] = []

            for obs in results {
                if let best = obs.topCandidates(1).first {
                    texts.append(best.string)
                    confidences.append(best.confidence)
                }
            }

            let full = texts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let avg = confidences.isEmpty ? 0 : (confidences.reduce(0,+) / Float(confidences.count))
            return (full, avg)
        } catch {
            print("OCR error:", error.localizedDescription)
            return ("", 0)
        }
    }
}

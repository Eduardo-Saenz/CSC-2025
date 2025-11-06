//
//  TTSService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/05/25.
//

import AVFoundation
import Foundation

final class TTSService {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, language: RecognizedLanguage, rate: Float = 0.5) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language.localeIdentifier)
        utterance.rate = rate
        synthesizer.speak(utterance)
    }
}

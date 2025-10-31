//
//  LanguageDetector.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import NaturalLanguage

struct LanguageDetector {
    static func detect(_ text: String) -> RecognizedLanguage? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let lang = recognizer.dominantLanguage else { return nil }

        switch lang {
        case .spanish: return .es
        case .english: return .en
        case .french:  return .fr
        default: return nil
        }
    }
}

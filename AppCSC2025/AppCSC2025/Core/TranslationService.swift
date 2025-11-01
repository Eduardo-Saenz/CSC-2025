//
//  TranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import Foundation

final class TranslationService {
    func translate(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "" }
        if from == to { return text }
        return await translateStub(text, from: from, to: to)
    }

    private func translateStub(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        // Diccionario de traducción hardcodeado
        let glossary: [String: [RecognizedLanguage: String]] = [
            "hola": [.en: "hello", .fr: "bonjour", .es: "hola"],
            "gracias": [.en: "thank you", .fr: "merci", .es: "gracias"],
            "méxico": [.en: "mexico", .fr: "mexique", .es: "méxico"],
            "gol": [.en: "goal", .fr: "but", .es: "gol"],
            "equipo": [.en: "team", .fr: "équipe", .es: "equipo"],
            "bienvenidos": [.en: "welcome", .fr: "bienvenue", .es: "bienvenidos"]
        ]

        let tokens = text.lowercased().split(separator: " ")
        let mapped = tokens.map { token -> String in
            if let m = glossary[String(token)]?[to] { return m }
            return String(token)
        }
        return mapped.joined(separator: " ")
    }
}

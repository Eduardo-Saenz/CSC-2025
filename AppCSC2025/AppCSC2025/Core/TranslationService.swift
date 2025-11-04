//
//  TranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Versión Deluxe: conectores y frases compuestas.
//

import Foundation

final class TranslationService {
    func translate(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "" }
        if from == to { return text }
        return await translateEnhanced(text, from: from, to: to)
    }

    private func normalizeTokens(_ text: String) -> [String] {
        let rawTokens = text.lowercased().components(separatedBy: .whitespaces)
        let punctuation = CharacterSet.punctuationCharacters
        return rawTokens.map { token in
            let trimmed = token.trimmingCharacters(in: punctuation)
            return trimmed.folding(options: .diacriticInsensitive, locale: .current)
        }
    }

    private func translateEnhanced(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        // 🧠 Frases naturales y conectores comunes
        let glossary: [String: [RecognizedLanguage: String]] = [
            // Conectores
            "y": [.en: "and", .fr: "et", .es: "y"],
            "con": [.en: "with", .fr: "avec", .es: "con"],
            "de": [.en: "of", .fr: "de", .es: "de"],
            "en": [.en: "in", .fr: "dans", .es: "en"],
            "para": [.en: "for", .fr: "pour", .es: "para"],
            "al": [.en: "to the", .fr: "au", .es: "al"],

            // Frases compuestas comunes
            "pollo con arroz": [.en: "chicken with rice", .fr: "poulet avec riz", .es: "pollo con arroz"],
            "carne con papas": [.en: "beef with potatoes", .fr: "boeuf avec pommes de terre", .es: "carne con papas"],
            "tacos de pollo": [.en: "chicken tacos", .fr: "tacos au poulet", .es: "tacos de pollo"],
            "ensalada de tomate": [.en: "tomato salad", .fr: "salade de tomates", .es: "ensalada de tomate"],
            "sopa de verduras": [.en: "vegetable soup", .fr: "soupe de légumes", .es: "sopa de verduras"],
            "agua natural": [.en: "natural water", .fr: "eau naturelle", .es: "agua natural"],
            "pastel de chocolate": [.en: "chocolate cake", .fr: "gâteau au chocolat", .es: "pastel de chocolate"],
            "hamburguesa con queso": [.en: "burger with cheese", .fr: "hamburger au fromage", .es: "hamburguesa con queso"],
            "papas fritas": [.en: "french fries", .fr: "pommes de terre frites", .es: "papas fritas"],
            "sándwich de jamón": [.en: "ham sandwich", .fr: "sandwich au jambon", .es: "sándwich de jamón"],
            "helado de vainilla": [.en: "vanilla ice cream", .fr: "glace à la vanille", .es: "helado de vainilla"],

            // Palabras básicas (por compatibilidad)
            "pollo": [.en: "chicken", .fr: "poulet", .es: "pollo"],
            "carne": [.en: "beef", .fr: "boeuf", .es: "carne"],
            "pescado": [.en: "fish", .fr: "poisson", .es: "pescado"],
            "arroz": [.en: "rice", .fr: "riz", .es: "arroz"],
            "sopa": [.en: "soup", .fr: "soupe", .es: "sopa"],
            "ensalada": [.en: "salad", .fr: "salade", .es: "ensalada"],
            "café": [.en: "coffee", .fr: "café", .es: "café"],
            "agua": [.en: "water", .fr: "eau", .es: "agua"]
        ]

        let lower = text.lowercased()
        // 🧩 Buscar primero frases completas antes de traducir palabra por palabra
        for phrase in glossary.keys.sorted(by: { $0.count > $1.count }) {
            if lower.contains(phrase) {
                let translated = glossary[phrase]?[to] ?? phrase
                return lower.replacingOccurrences(of: phrase, with: translated)
            }
        }

        // Traducción por palabra
        let tokens = normalizeTokens(text)
        let translatedTokens = tokens.map { word in
            glossary[word]?[to] ?? word
        }
        return translatedTokens.joined(separator: " ")
    }
}

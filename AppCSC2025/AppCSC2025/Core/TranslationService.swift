//
//  TranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Custom Glossary Edition for Multivoice AI – 11/06/25
//

import Foundation

/// Servicio de traducción local con glosario personalizado.
/// Pensado para modo offline de Multivoice AI (Mundial 2026).
/// Incluye frases turísticas, de atención, comida y transporte.
final class TranslationService {

    func translate(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return "" }
        if from == to { return clean }

        return await translateWithGlossary(clean, from: from, to: to)
    }

    // MARK: - Traducción personalizada
    private func translateWithGlossary(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {

        let glossary: [String: [RecognizedLanguage: String]] = [
            // 👋 Conversaciones básicas
            "hello": [.es: "hola", .fr: "salut", .en: "hello"],
            "hi": [.es: "hola", .fr: "salut", .en: "hi"],
            "good morning": [.es: "buenos días", .fr: "bonjour", .en: "good morning"],
            "good afternoon": [.es: "buenas tardes", .fr: "bon après-midi", .en: "good afternoon"],
            "good night": [.es: "buenas noches", .fr: "bonne nuit", .en: "good night"],
            "how are you": [.es: "¿cómo estás?", .fr: "comment ça va ?", .en: "how are you"],
            "i'm fine": [.es: "estoy bien", .fr: "je vais bien", .en: "i'm fine"],
            "thank you": [.es: "gracias", .fr: "merci", .en: "thank you"],
            "please": [.es: "por favor", .fr: "s’il vous plaît", .en: "please"],
            "excuse me": [.es: "disculpe", .fr: "excusez-moi", .en: "excuse me"],
            "sorry": [.es: "lo siento", .fr: "désolé", .en: "sorry"],
            "goodbye": [.es: "adiós", .fr: "au revoir", .en: "goodbye"],
            "welcome to multivoice ai": [.es: "bienvenido a multivoice ai", .fr: "bienvenue sur multivoice ai", .en: "welcome to multivoice ai"],

            // 🍽️ Restaurante
            "menu": [.es: "menú", .fr: "menu", .en: "menu"],
            "i would like": [.es: "quisiera", .fr: "je voudrais", .en: "i would like"],
            "can i get": [.es: "¿puedo pedir?", .fr: "puis-je avoir ?", .en: "can i get"],
            "a table for two": [.es: "una mesa para dos", .fr: "une table pour deux", .en: "a table for two"],
            "the bill please": [.es: "la cuenta, por favor", .fr: "l’addition, s’il vous plaît", .en: "the bill please"],
            "water": [.es: "agua", .fr: "eau", .en: "water"],
            "coffee": [.es: "café", .fr: "café", .en: "coffee"],
            "beer": [.es: "cerveza", .fr: "bière", .en: "beer"],
            "chicken": [.es: "pollo", .fr: "poulet", .en: "chicken"],
            "tacos": [.es: "tacos", .fr: "tacos", .en: "tacos"],
            "spicy": [.es: "picante", .fr: "épicé", .en: "spicy"],
            "no spicy": [.es: "sin picante", .fr: "pas épicé", .en: "no spicy"],
            "delicious": [.es: "delicioso", .fr: "délicieux", .en: "delicious"],

            // 🚖 Transporte
            "where is the station": [.es: "¿dónde está la estación?", .fr: "où est la gare ?", .en: "where is the station"],
            "bus": [.es: "autobús", .fr: "bus", .en: "bus"],
            "taxi": [.es: "taxi", .fr: "taxi", .en: "taxi"],
            "airport": [.es: "aeropuerto", .fr: "aéroport", .en: "airport"],
            "how much is it": [.es: "¿cuánto cuesta?", .fr: "combien ça coûte ?", .en: "how much is it"],
            "ticket": [.es: "boleto", .fr: "billet", .en: "ticket"],

            // 🏨 Hotel
            "reservation": [.es: "reserva", .fr: "réservation", .en: "reservation"],
            "i have a reservation": [.es: "tengo una reserva", .fr: "j’ai une réservation", .en: "i have a reservation"],
            "room": [.es: "habitación", .fr: "chambre", .en: "room"],
            "bathroom": [.es: "baño", .fr: "salle de bain", .en: "bathroom"],
            "key": [.es: "llave", .fr: "clé", .en: "key"],
            "towel": [.es: "toalla", .fr: "serviette", .en: "towel"],

            // ⚽️ Mundial / Turismo
            "where is the stadium": [.es: "¿dónde está el estadio?", .fr: "où est le stade ?", .en: "where is the stadium"],
            "mexico": [.es: "méxico", .fr: "mexique", .en: "mexico"],
            "canada": [.es: "canadá", .fr: "canada", .en: "canada"],
            "united states": [.es: "estados unidos", .fr: "états-unis", .en: "united states"],
            "go team": [.es: "vamos equipo", .fr: "allez l’équipe !", .en: "go team"],
            "goal": [.es: "gol", .fr: "but", .en: "goal"],
            "referee": [.es: "árbitro", .fr: "arbitre", .en: "referee"],
            "fans": [.es: "aficionados", .fr: "supporters", .en: "fans"],

            // 🔄 Conectores
            "and": [.es: "y", .fr: "et", .en: "and"],
            "or": [.es: "o", .fr: "ou", .en: "or"],
            "with": [.es: "con", .fr: "avec", .en: "with"],
            "without": [.es: "sin", .fr: "sans", .en: "without"],
            "to": [.es: "a", .fr: "à", .en: "to"],
            "from": [.es: "de", .fr: "de", .en: "from"],
            "in": [.es: "en", .fr: "dans", .en: "in"],
            "for": [.es: "para", .fr: "pour", .en: "for"]
        ]

        let lower = text.lowercased()
        for phrase in glossary.keys.sorted(by: { $0.count > $1.count }) {
            if lower.contains(phrase) {
                let translated = glossary[phrase]?[to] ?? phrase
                let replaced = lower.replacingOccurrences(of: phrase, with: translated)
                return replaced.prefix(1).capitalized + replaced.dropFirst()
            }
        }

        // Traducción palabra por palabra
        let tokens = normalizeTokens(lower)
        let translatedTokens = tokens.map { glossary[$0]?[to] ?? $0 }
        let result = translatedTokens.joined(separator: " ")

        guard let first = result.first else { return result }
        return String(first).uppercased() + result.dropFirst()
    }

    private func normalizeTokens(_ text: String) -> [String] {
        let rawTokens = text.lowercased().components(separatedBy: .whitespaces)
        let punctuation = CharacterSet.punctuationCharacters
        return rawTokens.map {
            $0.trimmingCharacters(in: punctuation)
                .folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

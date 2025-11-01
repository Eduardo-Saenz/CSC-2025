//
//  TranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Actualizado para soportar más vocabulario y normalizar tokens.
//  Corrección: se usa String.folding(options:locale:) en lugar de .diacriticInsensitive.

import Foundation

final class TranslationService {
    /// Traduce una cadena desde el idioma `from` al idioma `to`. Si el texto está vacío
    /// o ambos idiomas son iguales, devuelve el texto tal cual.
    func translate(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        // Evitar traducir cadenas vacías o traducciones a sí mismo
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "" }
        if from == to { return text }
        return await translateStub(text, from: from, to: to)
    }

    /// Normaliza el texto: convierte a minúsculas, elimina signos de puntuación
    /// al principio y final de cada token y quita los diacríticos (tildes).
    private func normalizeTokens(_ text: String) -> [String] {
        let rawTokens = text.lowercased().components(separatedBy: .whitespaces)
        let punctuation = CharacterSet.punctuationCharacters
        return rawTokens.map { token in
            // Recorta signos de puntuación
            let trimmed = token.trimmingCharacters(in: punctuation)
            // Elimina diacríticos (ej. á -> a)
            let withoutDiacritics = trimmed.folding(options: .diacriticInsensitive, locale: .current)
            return withoutDiacritics
        }
    }

    /// Traduce usando un diccionario de palabras estático. Se puede ampliar según necesidades.
    private func translateStub(_ text: String, from: RecognizedLanguage, to: RecognizedLanguage) async -> String {
        // Diccionario de traducción para palabras frecuentes en menús y frases comunes
        let glossary: [String: [RecognizedLanguage: String]] = [
            // Saludos y frases básicas
            "hola": [.en: "hello", .fr: "bonjour", .es: "hola"],
            "gracias": [.en: "thank you", .fr: "merci", .es: "gracias"],
            "mexico": [.en: "mexico", .fr: "mexique", .es: "méxico"],
            "méxico": [.en: "mexico", .fr: "mexique", .es: "méxico"],
            // Bebidas
            "agua": [.en: "water", .fr: "eau", .es: "agua"],
            "vino": [.en: "wine", .fr: "vin", .es: "vino"],
            "cerveza": [.en: "beer", .fr: "bière", .es: "cerveza"],
            "cafe": [.en: "coffee", .fr: "café", .es: "café"],
            "caf\u{E9}": [.en: "coffee", .fr: "café", .es: "café"], // forma con acento para seguridad
            "te": [.en: "tea", .fr: "thé", .es: "té"],
            "té": [.en: "tea", .fr: "thé", .es: "té"],
            // Platos principales
            "pollo": [.en: "chicken", .fr: "poulet", .es: "pollo"],
            "carne": [.en: "beef", .fr: "boeuf", .es: "carne"],
            "pescado": [.en: "fish", .fr: "poisson", .es: "pescado"],
            "cerdo": [.en: "pork", .fr: "porc", .es: "cerdo"],
            "arroz": [.en: "rice", .fr: "riz", .es: "arroz"],
            "frijoles": [.en: "beans", .fr: "haricots", .es: "frijoles"],
            "ensalada": [.en: "salad", .fr: "salade", .es: "ensalada"],
            "sopa": [.en: "soup", .fr: "soupe", .es: "sopa"],
            "pizza": [.en: "pizza", .fr: "pizza", .es: "pizza"],
            "hamburguesa": [.en: "burger", .fr: "hamburger", .es: "hamburguesa"],
            // Postres
            "pastel": [.en: "cake", .fr: "gâteau", .es: "pastel"],
            "tarta": [.en: "pie", .fr: "tarte", .es: "tarta"],
            "helado": [.en: "ice cream", .fr: "glace", .es: "helado"],
            "galleta": [.en: "cookie", .fr: "biscuit", .es: "galleta"],
            "chocolate": [.en: "chocolate", .fr: "chocolat", .es: "chocolate"],
            // Otros ingredientes y platos comunes
            "queso": [.en: "cheese", .fr: "fromage", .es: "queso"],
            "tomate": [.en: "tomato", .fr: "tomate", .es: "tomate"],
            "cebolla": [.en: "onion", .fr: "oignon", .es: "cebolla"],
            "lechuga": [.en: "lettuce", .fr: "laitue", .es: "lechuga"],
            "papas": [.en: "potatoes", .fr: "pommes de terre", .es: "papas"],
            "patatas": [.en: "potatoes", .fr: "pommes de terre", .es: "patatas"],
            "huevo": [.en: "egg", .fr: "œuf", .es: "huevo"],
            "huevos": [.en: "eggs", .fr: "œufs", .es: "huevos"],
            "tostada": [.en: "toast", .fr: "toast", .es: "tostada"],
            "sandwich": [.en: "sandwich", .fr: "sandwich", .es: "sándwich"],
            "sándwich": [.en: "sandwich", .fr: "sandwich", .es: "sándwich"],
            // Añade tantos términos como necesites…
        ]

        // Normaliza el texto y traduce token por token
        let tokens = normalizeTokens(text)
        let translatedTokens = tokens.map { token in
            glossary[token]?[to] ?? token
        }
        return translatedTokens.joined(separator: " ")
    }
}

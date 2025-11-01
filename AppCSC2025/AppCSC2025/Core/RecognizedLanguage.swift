//
//  RecognizedLanguage.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import Foundation

enum RecognizedLanguage: String, CaseIterable, Codable {
    case es, en, fr

    var localeIdentifier: String {
        switch self {
        case .es: return "es-MX"
        case .en: return "en-US"
        case .fr: return "fr-FR"
        }
    }

    var label: String {
        switch self {
        case .es: return "Español"
        case .en: return "Inglés"
        case .fr: return "Francés"
        }
    }

    var flag: String {
        switch self {
        case .es: return "🇲🇽"
        case .en: return "🇺🇸"
        case .fr: return "🇫🇷"
        }
    }

    var flaggedLabel: String { "\(flag) \(label)" }
}

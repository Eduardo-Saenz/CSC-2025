//
//  AppSettings.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation
import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: return "Sistema"
        case .light:  return "Claro"
        case .dark:   return "Oscuro"
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("selectedCountry") var selectedCountry: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = ""
    @AppStorage("themeMode") private var themeRaw: String = ThemeMode.system.rawValue
    var themeMode: ThemeMode {
        get { ThemeMode(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue; objectWillChange.send() }
    }

    @Published var didFinishLogin: Bool = false

    var isConfigured: Bool {
        !selectedCountry.isEmpty && !selectedLanguage.isEmpty
    }
}

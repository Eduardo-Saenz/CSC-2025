//
//  ContentView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = AppSettings()

    var body: some View {
        if settings.isConfigured {
            HomeTabView()
                .environmentObject(settings)
                .environment(\.locale, Locale(identifier: localeCode))
        } else {
            LoginView()
                .environmentObject(settings)
        }
    }

    private var localeCode: String {
        switch settings.selectedLanguage {
        case "Español": return "es"
        case "English": return "en"
        case "Français": return "fr"
        case "Deutsch": return "de"
        case "Português": return "pt"
        default: return "es"
        }
    }
}

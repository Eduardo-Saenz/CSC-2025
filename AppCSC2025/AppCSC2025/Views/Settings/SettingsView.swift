//
//  SettingsView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    private let countries = [
        "México 🇲🇽", "Estados Unidos 🇺🇸", "Canadá 🇨🇦",
        "Argentina 🇦🇷", "Brasil 🇧🇷", "Alemania 🇩🇪",
        "Francia 🇫🇷", "Japón 🇯🇵"
    ]
    private let languages = [
        "Español", "English", "Français", "Deutsch", "Português"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferencias")) {
                    Picker("País", selection: $settings.selectedCountry) {
                        ForEach(countries, id: \.self) { Text($0).tag($0) }
                    }
                    Picker("Idioma", selection: $settings.selectedLanguage) {
                        ForEach(languages, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        settings.selectedCountry = ""
                        settings.selectedLanguage = ""
                    } label: {
                        Text("Reiniciar configuración (volver al login)")
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}

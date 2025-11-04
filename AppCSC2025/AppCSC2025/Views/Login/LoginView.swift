//
//  LoginView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

/// Permite seleccionar país e idioma antes de entrar a la app.
struct LoginView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedCountry: String = ""
    @State private var selectedLanguage: String = ""

    private let countries = [
        "México 🇲🇽", "Estados Unidos 🇺🇸", "Canadá 🇨🇦",
        "Argentina 🇦🇷", "Brasil 🇧🇷", "Alemania 🇩🇪",
        "Francia 🇫🇷", "Japón 🇯🇵"
    ]
    private let languages = [
        "Español", "English", "Français", "Deutsch", "Português"
    ]

    var body: some View {
        ZStack {
            Image("hero")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 2)

            Color.black.opacity(0.45).edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                Text("🌍 Bienvenido al Mundial 2026")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Selecciona tu país:")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)

                    Picker("País", selection: $selectedCountry) {
                        Text("Selecciona").tag("")
                        ForEach(countries, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Selecciona tu idioma:")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)

                    Picker("Idioma", selection: $selectedLanguage) {
                        Text("Selecciona").tag("")
                        ForEach(languages, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                }

                Button(action: saveSettings) {
                    Text("Continuar ⚽️")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCountry.isEmpty || selectedLanguage.isEmpty ? Color.gray.opacity(0.4) : Color.green)
                        .cornerRadius(12)
                }
                .disabled(selectedCountry.isEmpty || selectedLanguage.isEmpty)
                .padding(.top, 10)
            }
            .padding()
        }
    }

    private func saveSettings() {
        settings.selectedCountry = selectedCountry
        settings.selectedLanguage = selectedLanguage
    }
}

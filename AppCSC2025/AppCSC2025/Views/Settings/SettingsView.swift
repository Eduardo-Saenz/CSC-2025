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

    // 🎨 Paleta FIFA 2026
    private let green = Color(red: 0.0, green: 0.41, blue: 0.28) // #006847
    private let red = Color(red: 0.81, green: 0.07, blue: 0.14)  // #CE1125f

    var body: some View {
        NavigationStack {
            Form {
                preferencesSection
                appearanceSection
                userInfoSection
                resetSection
            }
            .navigationTitle("Configuración ⚙️")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    // MARK: - Sección: Preferencias
    private var preferencesSection: some View {
        Section(header: Text("Preferencias")
            .font(.headline)
            .foregroundStyle(.secondary)
        ) {
            Picker("🌎 País", selection: $settings.selectedCountry) {
                ForEach(countries, id: \.self) { country in
                    Text(country).tag(country)
                }
            }

            Picker("💬 Idioma", selection: $settings.selectedLanguage) {
                ForEach(languages, id: \.self) { lang in
                    Text(lang).tag(lang)
                }
            }
        }
        .listRowBackground(Color(.systemGray6))
    }

    // MARK: - Sección: Apariencia
    private var appearanceSection: some View {
        Section(header: Text("Apariencia")
            .font(.headline)
            .foregroundStyle(.secondary)
        ) {
            appearancePicker
        }
        .listRowBackground(Color(.systemGray6))
    }

    // Desglosamos el picker fuera para que compile sin trabas
    private var appearancePicker: some View {
        Picker("Modo", selection: $settings.themeMode) {
            ForEach(ThemeMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK:
    private var userInfoSection: some View {
        Section {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(green)
                VStack(alignment: .leading) {
                    Text("Eduardo Saenz")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                }
            }
            .padding(.vertical, 6)
        }
        .listRowBackground(Color(.systemGray6))
    }

    // MARK: - Sección: Reiniciar configuración
    private var resetSection: some View {
        Section {
            Button(role: .destructive) {
                withAnimation(.easeInOut) {
                    settings.selectedCountry = ""
                    settings.selectedLanguage = ""
                }
            } label: {
                Label("Reiniciar configuración", systemImage: "arrow.counterclockwise.circle.fill")
                    .foregroundColor(red)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowBackground(Color(.systemGray6))
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AppSettings())
}

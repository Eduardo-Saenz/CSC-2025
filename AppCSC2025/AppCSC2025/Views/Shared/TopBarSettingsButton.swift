//
//  TopBarSettingsButton.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/5/25.
//

import SwiftUI

struct TopBarSettingsButton: View {
    @State private var showSettings = false
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        Button(action: { showSettings.toggle() }) {
            Image(systemName: "person.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.blue)
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .environmentObject(settings)
                    .navigationTitle("Ajustes")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .accessibilityLabel("Abrir ajustes")
    }
}

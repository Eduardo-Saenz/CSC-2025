//
//  MobilityListView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

struct MobilityListView: View {
    @StateObject private var vm: MobilityViewModel

    init(manager: WorldCupManager) {
        _vm = StateObject(wrappedValue: MobilityViewModel(manager: manager))
    }

    // 🎨 Colores FIFA 2026
    private let fifaGreen = Color(hex: "006847") // 🇲🇽
    private let fifaRed   = Color(hex: "CE1125") // 🇨🇦
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // 🇺🇸

    var body: some View {
        ZStack {
            // 🌍 Fondo FIFA tricolor dinámico
            LinearGradient(
                gradient: Gradient(colors: [
                    fifaGreen.opacity(0.25),
                    Color.white,
                    fifaBlue.opacity(0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 🔲 Capa translúcida para profundidad
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            NavigationStack {
                VStack(spacing: 0) {
                    // 🟢 Franja decorativa superior
                    LinearGradient(
                        gradient: Gradient(colors: [fifaGreen, fifaBlue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3)
                    .cornerRadius(3)
                    .padding(.bottom, 3)

                    // 🚗 Lista principal de movilidad
                    List {
                        ForEach(vm.filtered, id: \.id) { m in
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        fifaBlue.opacity(0.08)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .cornerRadius(12)
                                .shadow(color: fifaGreen.opacity(0.1), radius: 3, y: 2)

                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(m.stadium)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(m.city)
                                            .foregroundColor(.secondary)
                                    }

                                    if let advisories = m.advisories, !advisories.isEmpty {
                                        Text(advisories.joined(separator: " · "))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }

                                    if !m.modes.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 6) {
                                                ForEach(m.modes, id: \.self) { mode in
                                                    Text(mode.kind.rawValue.capitalized)
                                                        .font(.caption2)
                                                        .padding(.vertical, 4)
                                                        .padding(.horizontal, 8)
                                                        .background(fifaGreen.opacity(0.15))
                                                        .clipShape(Capsule())
                                                }
                                            }
                                            .padding(.top, 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                            }
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 4)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.9),
                                fifaGreen.opacity(0.08)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .navigationTitle("Movilidad")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(fifaGreen.opacity(0.9), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // 🟢 Filtro por ciudad
                        Menu {
                            Picker("Ciudad", selection: $vm.selectedCity) {
                                ForEach(vm.cityOptions, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            Label(
                                vm.selectedCity == "All" ? "Ciudad" : vm.selectedCity,
                                systemImage: "mappin.and.ellipse"
                            )
                            .font(.subheadline)
                            .foregroundColor(fifaGreen)
                            .padding(6)
                            .background(fifaGreen.opacity(0.1))
                            .cornerRadius(8)
                        }

                        // 🔵 Filtro por modo
                        if vm.kindOptions.count > 1 {
                            Menu {
                                Picker("Modo", selection: $vm.selectedKind) {
                                    ForEach(vm.kindOptions, id: \.self) {
                                        Text($0.capitalized).tag($0)
                                    }
                                }
                            } label: {
                                Label(
                                    vm.selectedKind == "All" ? "Modo" : vm.selectedKind.capitalized,
                                    systemImage: "car.2.fill"
                                )
                                .font(.subheadline)
                                .foregroundColor(fifaBlue)
                                .padding(6)
                                .background(fifaBlue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }

                        // 🔴 Accesibilidad (toggle)
                        Toggle(isOn: $vm.onlyAccessible) {
                            Image(systemName: "figure.roll.runningpace")
                        }
                        .toggleStyle(.button)
                        .tint(fifaRed)
                    }
                }
                .searchable(
                    text: $vm.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar estadio o aviso"
                )
                .tint(fifaGreen)
            }
        }
    }
}

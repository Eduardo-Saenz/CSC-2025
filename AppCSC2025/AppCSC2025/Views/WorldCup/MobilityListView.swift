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

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.filtered, id: \.id) { m in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(m.stadium).font(.headline)
                            Spacer()
                            Text(m.city).foregroundStyle(.secondary)
                        }

                        // Avisos (si tu modelo los dejó opcionales)
                        if let advisories = m.advisories, !advisories.isEmpty {
                            Text(advisories.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        // ✅ m.modes NO opcional
                        if !m.modes.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(m.modes, id: \.self) { mode in
                                        Text(mode.kind.rawValue.capitalized)
                                            .font(.caption2)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(Color.gray.opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Movilidad")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // Filtro ciudad
                    Menu {
                        Picker("Ciudad", selection: $vm.selectedCity) {
                            ForEach(vm.cityOptions, id: \.self) { Text($0).tag($0) }
                        }
                    } label: {
                        Label(vm.selectedCity == "All" ? "Ciudad" : vm.selectedCity,
                              systemImage: "mappin.and.ellipse")
                    }

                    // Filtro modo (si hay más de uno)
                    if vm.kindOptions.count > 1 {
                        Menu {
                            Picker("Modo", selection: $vm.selectedKind) {
                                ForEach(vm.kindOptions, id: \.self) { Text($0.capitalized).tag($0) }
                            }
                        } label: {
                            Label(vm.selectedKind == "All" ? "Modo" : vm.selectedKind.capitalized,
                                  systemImage: "line.3.horizontal.decrease.circle")
                        }
                    }

                    // Accesibilidad
                    Toggle(isOn: $vm.onlyAccessible) {
                        Image(systemName: "figure.roll.runningpace")
                    }
                    .toggleStyle(.button)
                }
            }
            .searchable(text: $vm.searchText, prompt: "Buscar estadio o aviso")
        }
    }
}

//
//  GroupListView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

struct GroupListView: View {
    @StateObject private var vm: GroupsViewModel

    @State private var selectedConf: String = "All"
    @State private var searchText: String = ""

    init(manager: WorldCupManager) {
        _vm = StateObject(wrappedValue: GroupsViewModel(manager: manager))
    }

    // 🎨 Colores FIFA 2026
    private let fifaGreen = Color(hex: "006847") // 🇲🇽
    private let fifaRed   = Color(hex: "CE1125") // 🇨🇦
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // 🇺🇸

    private var confOptions: [String] {
        let all = vm.groups.flatMap { $0.teams }.map { $0.confederation }
        let uniq = Array(Set(all)).sorted()
        return ["All"] + uniq
    }

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

                    // 📋 Lista de grupos
                    List {
                        ForEach(filteredGroups(), id: \.id) { group in
                            let filteredTeams = filteredTeams(in: group)
                            if !filteredTeams.isEmpty {
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

                                    GroupCardView(
                                        group: group,
                                        teams: filteredTeams.sorted { $0.fifa_rank < $1.fifa_rank }
                                    )
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 8)
                                }
                                .listRowInsets(EdgeInsets())
                                .padding(.vertical, 4)
                                .listRowSeparator(.hidden)
                            }
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
                .navigationTitle("Grupos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(fifaGreen.opacity(0.9), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        // 🌍 Menú de confederaciones
                        Menu {
                            Picker("Confederación", selection: $selectedConf) {
                                ForEach(confOptions, id: \.self) { conf in
                                    Text(conf).tag(conf)
                                }
                            }
                        } label: {
                            Label(
                                selectedConf == "All" ? "Conf" : selectedConf,
                                systemImage: "globe.europe.africa.fill"
                            )
                            .font(.subheadline)
                            .foregroundColor(fifaBlue)
                            .padding(6)
                            .background(fifaBlue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar equipo o código"
                )
                .tint(fifaGreen)
            }
        }
    }

    // MARK: - Filtrado
    private func filteredGroups() -> [Group] {
        guard !searchText.isEmpty else { return vm.groups }
        let q = searchText.lowercased()
        return vm.groups.filter { g in
            g.teams.contains { t in
                t.name.lowercased().contains(q) || t.code.lowercased().contains(q)
            }
        }
    }

    private func filteredTeams(in group: Group) -> [Team] {
        group.teams.filter { t in
            let passConf = (selectedConf == "All") || (t.confederation == selectedConf)
            if searchText.isEmpty { return passConf }
            let q = searchText.lowercased()
            let passSearch = t.name.lowercased().contains(q) || t.code.lowercased().contains(q)
            return passConf && passSearch
        }
    }
}

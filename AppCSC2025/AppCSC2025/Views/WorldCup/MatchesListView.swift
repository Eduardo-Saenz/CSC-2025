//
//  MatchesListView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

struct MatchesListView: View {
    @StateObject private var matchesVM: MatchesViewModel
    @StateObject private var groupsVM: GroupsViewModel

    init(manager: WorldCupManager) {
        _matchesVM = StateObject(wrappedValue: MatchesViewModel(manager: manager))
        _groupsVM  = StateObject(wrappedValue: GroupsViewModel(manager: manager))
    }

    @State private var selectedGroup: String? = nil
    @State private var selectedStage: String = "Todos"
    @State private var selectedStatus: String = "Todos"
    @State private var searchText: String = ""

    // 🎨 Colores FIFA 2026
    private let fifaGreen = Color(hex: "006847") // 🇲🇽
    private let fifaRed   = Color(hex: "CE1125") // 🇨🇦
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // 🇺🇸

    private var stageOptions: [String] {
        let raw = Set(matchesVM.all.map { $0.stage })
        return ["Todos"] + raw.sorted()
    }

    private var groupOptions: [String] {
        let raw = Set(matchesVM.all.compactMap { $0.group })
        return ["Todos"] + raw.sorted()
    }

    private var statusOptions: [String] { ["Todos", "Programado", "En vivo", "Finalizado"] }

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

            // 🔲 Fondo difuminado translúcido para profundidad
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            NavigationStack {
                VStack(spacing: 0) {
                    // Encabezado superior decorativo
                    LinearGradient(
                        gradient: Gradient(colors: [fifaGreen, fifaBlue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 3)
                    .cornerRadius(3)
                    .padding(.bottom, 3)

                    // Lista principal de partidos
                    List {
                        ForEach(filteredMatches(), id: \.id) { match in
                            let home = groupsVM.teamsByCode[match.home]
                            let away = groupsVM.teamsByCode[match.away]

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

                                MatchRowView(match: match, home: home, away: away)
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
                .navigationTitle("Partidos")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(fifaGreen.opacity(0.9), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        // 🟢 Grupo
                        Menu {
                            Picker("Grupo", selection: Binding(
                                get: { selectedGroup ?? "Todos" },
                                set: { selectedGroup = ($0 == "Todos") ? nil : $0 }
                            )) {
                                ForEach(groupOptions, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            Label(selectedGroup ?? "Grupo", systemImage: "square.grid.3x3.square.fill")
                                .font(.subheadline)
                                .foregroundColor(fifaGreen)
                                .padding(6)
                                .background(fifaGreen.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // 🔵 Fase
                        Menu {
                            Picker("Fase", selection: $selectedStage) {
                                ForEach(stageOptions, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            Label(selectedStage, systemImage: "flag.2.crossed")
                                .font(.subheadline)
                                .foregroundColor(fifaBlue)
                                .padding(6)
                                .background(fifaBlue.opacity(0.1))
                                .cornerRadius(8)
                        }

                        // 🔴 Estado
                        Menu {
                            Picker("Estado", selection: $selectedStatus) {
                                ForEach(statusOptions, id: \.self) { Text($0).tag($0) }
                            }
                        } label: {
                            Label(selectedStatus, systemImage: "clock.badge.checkmark")
                                .font(.subheadline)
                                .foregroundColor(fifaRed)
                                .padding(6)
                                .background(fifaRed.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar equipo, ciudad o estadio"
                )
                .tint(fifaGreen)
            }
        }
    }

    // MARK: - Filtrado
    private func filteredMatches() -> [Match] {
        var base = matchesVM.upcoming

        if let g = selectedGroup {
            base = base.filter { $0.group == g }
        }

        if selectedStage != "Todos" {
            base = base.filter { $0.stage == selectedStage }
        }

        if selectedStatus != "Todos" {
            let statusMap = [
                "Programado": "scheduled",
                "En vivo": "live",
                "Finalizado": "finished"
            ]
            base = base.filter { $0.status == statusMap[selectedStatus] }
        }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            base = base.filter { m in
                let home = groupsVM.teamsByCode[m.home]
                let away = groupsVM.teamsByCode[m.away]
                let hayEquipo = [home?.name, home?.code, away?.name, away?.code]
                    .compactMap { $0?.lowercased() }
                    .contains(where: { $0.contains(q) })
                let hayVenue = "\(m.venue.city) \(m.venue.stadium)"
                    .lowercased()
                    .contains(q)
                return hayEquipo || hayVenue
            }
        }

        return base
    }
}

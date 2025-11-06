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

    // init que recibe el manager y construye los StateObject
    init(manager: WorldCupManager) {
        _matchesVM = StateObject(wrappedValue: MatchesViewModel(manager: manager))
        _groupsVM  = StateObject(wrappedValue: GroupsViewModel(manager: manager))
    }

    // Filtros locales
    @State private var selectedGroup: String? = nil
    @State private var selectedStage: String = "All"
    @State private var selectedStatus: String = "All"
    @State private var searchText: String = ""

    private var stageOptions: [String] {
        let raw = Set(matchesVM.all.map { $0.stage })
        return ["All"] + raw.sorted()
    }
    private var groupOptions: [String] {
        let raw = Set(matchesVM.all.compactMap { $0.group })
        return ["All"] + raw.sorted()
    }
    private var statusOptions: [String] { ["All", "scheduled", "live", "finished"] }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredMatches(), id: \.id) { match in
                    let home = groupsVM.teamsByCode[match.home]
                    let away = groupsVM.teamsByCode[match.away]
                    MatchRowView(match: match, home: home, away: away)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Partidos")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Picker("Group", selection: Binding(
                            get: { selectedGroup ?? "All" },
                            set: { selectedGroup = ($0 == "All") ? nil : $0 }
                        )) {
                            ForEach(groupOptions, id: \.self) { Text($0).tag($0) }
                        }
                    } label: {
                        Label(selectedGroup ?? "All", systemImage: "square.grid.3x3.square")
                    }

                    Menu {
                        Picker("Stage", selection: $selectedStage) {
                            ForEach(stageOptions, id: \.self) { Text($0).tag($0) }
                        }
                    } label: {
                        Label(selectedStage, systemImage: "flag.2.crossed")
                    }

                    Menu {
                        Picker("Status", selection: $selectedStatus) {
                            ForEach(statusOptions, id: \.self) { Text($0.capitalized).tag($0) }
                        }
                    } label: {
                        Label(selectedStatus.capitalized, systemImage: "clock.badge.checkmark")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Buscar equipo, ciudad o estadio")
        }
    }

    // MARK: - Filtrado
    private func filteredMatches() -> [Match] {
        var base = matchesVM.upcoming
        if let g = selectedGroup { base = base.filter { $0.group == g } }
        if selectedStage != "All" { base = base.filter { $0.stage == selectedStage } }
        if selectedStatus != "All" { base = base.filter { $0.status == selectedStatus } }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            base = base.filter { m in
                let home = groupsVM.teamsByCode[m.home]
                let away = groupsVM.teamsByCode[m.away]
                let hayEquipo = [home?.name, home?.code, away?.name, away?.code]
                    .compactMap { $0?.lowercased() }
                    .contains(where: { $0.contains(q) })
                let hayVenue = "\(m.venue.city) \(m.venue.stadium)".lowercased().contains(q)
                return hayEquipo || hayVenue
            }
        }
        return base
    }
}

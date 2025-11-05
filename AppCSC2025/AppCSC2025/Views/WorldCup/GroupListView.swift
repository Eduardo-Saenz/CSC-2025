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

    private var confOptions: [String] {
        let all = vm.groups.flatMap { $0.teams }.map { $0.confederation }
        let uniq = Array(Set(all)).sorted()
        return ["All"] + uniq
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredGroups(), id: \.id) { group in
                    let filteredTeams = filteredTeams(in: group)
                    if !filteredTeams.isEmpty {
                        GroupCardView(group: group,
                                      teams: filteredTeams.sorted { $0.fifa_rank < $1.fifa_rank })
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 6)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Grupos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Confederation", selection: $selectedConf) {
                            ForEach(confOptions, id: \.self) { conf in
                                Text(conf).tag(conf)
                            }
                        }
                    } label: {
                        Label(selectedConf == "All" ? "Conf" : selectedConf,
                              systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Buscar equipo o código")
        }
    }

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

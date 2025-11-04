//
//  WorldCupView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

/// Vista principal con tres secciones: grupos, partidos y movilidad.
struct WorldCupView: View {
    @StateObject private var manager = WorldCupManager()
    @State private var selectedSection: Section = .groups

    enum Section: String, CaseIterable, Identifiable {
        case groups = "Grupos"
        case matches = "Partidos"
        case mobility = "Movilidad"

        var id: String { rawValue }
    }

    var body: some View {
        VStack {
            Picker("Sección", selection: $selectedSection) {
                ForEach(Section.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            switch selectedSection {
            case .groups:
                ScrollView {
                    ForEach(manager.groups) { group in
                        GroupCardView(group: group)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                }
            case .matches:
                List(manager.matches) { match in
                    MatchRow(match: convertToEvent(match))
                }
                .listStyle(PlainListStyle())
            case .mobility:
                // Puedes reutilizar MobilityView aquí o dejarlo vacío
                MobilityView()
            }
        }
    }

    private func convertToEvent(_ data: MatchData) -> MatchEvent {
        let home = data.teams.first ?? ""
        let away = data.teams.dropFirst().first ?? ""
        let stadium = data.stadium
        // Derive city from mobility dataset by matching stadium; fallback empty if not found.
        let city = manager.mobility.first(where: { $0.stadium == stadium })?.city ?? ""

        // Parse "YYYY-MM-DD"
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: data.date) ?? Date()

        return MatchEvent(homeTeam: home, awayTeam: away, stadium: stadium, city: city, date: date)
    }
}


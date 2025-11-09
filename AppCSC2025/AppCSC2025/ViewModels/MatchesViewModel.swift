//
//  MatchesViewModel.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation
import Combine

@MainActor
final class MatchesViewModel: ObservableObject {
    @Published private(set) var all: [Match] = []
    @Published private(set) var upcoming: [Match] = []
    @Published var selectedGroup: String? = nil

    private let manager: WorldCupManager
    private var bag = Set<AnyCancellable>()

    init(manager: WorldCupManager) {
        self.manager = manager

        manager.$matches
            .receive(on: DispatchQueue.main)
            .sink { [weak self] matches in
                guard let self else { return }
                self.all = matches.sorted { ($0.kickoffDateUTC ?? .distantFuture) < ($1.kickoffDateUTC ?? .distantFuture) }
                self.recomputeUpcoming()
            }
            .store(in: &bag)
    }

    func setFilter(group: String?) {
        selectedGroup = group
        recomputeUpcoming()
    }

    private func recomputeUpcoming() {
        let now = Date()
        let base = (selectedGroup == nil) ? all : all.filter { $0.group == selectedGroup }
        upcoming = base.filter { m in
            guard let d = m.kickoffDateUTC else { return true }
            return d >= now || m.status == "scheduled"
        }
    }

    func daySections() -> [(dayKey: String, matches: [Match])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let pairs: [(String, Match)] = upcoming.compactMap { match in
            guard let date = match.kickoffDateUTC else { return nil }
            let tz = TimeZone(identifier: match.venue.tz) ?? .autoupdatingCurrent
            var comps = Calendar.current.dateComponents(in: tz, from: date)
            comps.hour = 0; comps.minute = 0; comps.second = 0
            let day = comps.date ?? date
            return (formatter.string(from: day), match)
        }

        let grouped = Dictionary(grouping: pairs, by: { $0.0 })
            .mapValues { $0.map(\.1) }

        let sections: [(dayKey: String, matches: [Match])] = grouped
            .map { (dayKey: $0.key,
                    matches: $0.value.sorted(by: {
                        ($0.kickoffDateUTC ?? .distantFuture) < ($1.kickoffDateUTC ?? .distantFuture)
                    })) }

        return sections.sorted(by: { $0.dayKey < $1.dayKey }) 

    }
}

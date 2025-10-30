//
//  SampleData.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import Foundation

enum SampleData {
    static let news: [NewsItem] = [
        NewsItem(title: "Opening Fan Fest",
                 subtitle: "Live music & food trucks near the main plaza.",
                 tag: "Today",
                 date: .now,
                 icon: "sparkles"),
        NewsItem(title: "Shuttle Service Update",
                 subtitle: "Extra buses added for stadium routes A & B.",
                 tag: "Transport",
                 date: .now.addingTimeInterval(3600),
                 icon: "bus"),
        NewsItem(title: "Cultural Tour",
                 subtitle: "Guided downtown walk at 4:00 PM. Spots limited!",
                 tag: "Activity",
                 date: .now.addingTimeInterval(5_400),
                 icon: "map")
    ]

    static let matches: [MatchEvent] = [
        MatchEvent(
            homeTeam: "Mexico",
            awayTeam: "Italy",
            stadium: "Estadio Azteca",
            city: "CDMX",
            date: DateComponents(calendar: .current, year: 2026, month: 6, day: 12, hour: 19, minute: 0).date ?? .now
        ),
        MatchEvent(
            homeTeam: "USA",
            awayTeam: "Japan",
            stadium: "MetLife Stadium",
            city: "NY/NJ",
            date: DateComponents(calendar: .current, year: 2026, month: 6, day: 13, hour: 16, minute: 30).date ?? .now
        ),
        MatchEvent(
            homeTeam: "Canada",
            awayTeam: "Spain",
            stadium: "BC Place",
            city: "Vancouver",
            date: DateComponents(calendar: .current, year: 2026, month: 6, day: 14, hour: 14, minute: 0).date ?? .now
        )
    ]
}

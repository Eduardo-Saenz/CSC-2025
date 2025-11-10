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
}

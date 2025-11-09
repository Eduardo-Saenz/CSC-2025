//
//  Match.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation

// MARK: - Match
struct Match: Decodable, Identifiable, Hashable {
    struct Venue: Decodable, Hashable {
        let stadium: String
        let city: String
        let country: String
        let tz: String
        let capacity: Int
    }

    struct Ticketing: Decodable, Hashable {
        let status: String      
        let min_price: Int
    }

    struct Prediction: Decodable, Hashable {
        let home_win_prob: Double
        let draw_prob: Double
        let away_win_prob: Double
    }

    let id: String
    let stage: String
    let group: String?
    let matchday: Int
    let kickoff_utc: String
    let kickoff_local: String
    let venue: Venue
    let home: String
    let away: String
    let status: String
    let tags: [String]
    let importance: String
    let ticketing: Ticketing
    let broadcast: [String]
    let prediction: Prediction
}

// MARK: - Computed helpers
extension Match {
    var kickoffDateUTC: Date? {
        ISO8601DateFormatter.cached.date(from: kickoff_utc)
    }

    func formattedLocal(dateStyle: DateFormatter.Style = .medium,
                        timeStyle: DateFormatter.Style = .short) -> String {
        guard let date = kickoffDateUTC else { return kickoff_local }
        let df = DateFormatter()
        df.locale = Locale.autoupdatingCurrent
        df.timeZone = TimeZone(identifier: venue.tz) ?? .autoupdatingCurrent
        df.dateStyle = dateStyle
        df.timeStyle = timeStyle
        return df.string(from: date)
    }
}

// MARK: - ISO8601 cached formatter
private extension ISO8601DateFormatter {
    static let cached: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}

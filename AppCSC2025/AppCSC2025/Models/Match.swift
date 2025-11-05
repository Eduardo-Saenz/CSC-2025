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
        let status: String      // "high" | "medium" | "low" | "very-low"
        let min_price: Int
    }

    struct Prediction: Decodable, Hashable {
        let home_win_prob: Double
        let draw_prob: Double
        let away_win_prob: Double
    }

    let id: String
    let stage: String          // "Group", "R16", "QF", etc.
    let group: String?         // nil en fases KO
    let matchday: Int
    let kickoff_utc: String
    let kickoff_local: String  // redundante, útil para previews offline
    let venue: Venue
    let home: String           // Team.code
    let away: String           // Team.code
    let status: String         // "scheduled" | "live" | "finished"
    let tags: [String]
    let importance: String
    let ticketing: Ticketing
    let broadcast: [String]
    let prediction: Prediction
}

// MARK: - Computed helpers
extension Match {
    /// Convierte kickoff_utc (ISO-8601) a `Date`. Devuelve nil si el string está mal.
    var kickoffDateUTC: Date? {
        ISO8601DateFormatter.cached.date(from: kickoff_utc)
    }

    /// Fecha local formateada a partir de `kickoffDateUTC` usando la zona horaria del venue.tz si existe, si no, la del sistema.
    func formattedLocal(dateStyle: DateFormatter.Style = .medium,
                        timeStyle: DateFormatter.Style = .short) -> String {
        guard let date = kickoffDateUTC else { return kickoff_local } // fallback al string del JSON
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
        // Acepta "YYYY-MM-DDTHH:mm:ssZ"
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}

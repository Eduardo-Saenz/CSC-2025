//
//  MatchData.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation

struct MatchData: Codable, Identifiable {
    let date: String       // Formato ISO "YYYY-MM-DD"
    let teams: [String]    // [Local, Visitante]
    let stadium: String
    let group: String
    
    var id: String { "\(date)-\(teams.joined())" }


    var matchDate: Date? {
        ISO8601DateFormatter().date(from: date)
    }
}

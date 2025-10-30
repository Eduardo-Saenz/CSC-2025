//
//  MatchEvent.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import Foundation

struct MatchEvent: Identifiable, Hashable {
    let id = UUID()
    let homeTeam: String
    let awayTeam: String
    let stadium: String
    let city: String
    let date: Date
}

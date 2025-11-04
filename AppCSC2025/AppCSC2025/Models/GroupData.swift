//
//  GroupData.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation


struct GroupData: Codable, Identifiable {
    let id: String
    let teams: [TeamData]
}

struct TeamData: Codable, Identifiable {
    let name: String
    let flag: String
    let points: Int
    let played: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
    var id: String { name }
}

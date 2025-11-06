//
//  Team.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation

// MARK: - Team
struct Team: Decodable, Hashable, Identifiable {
    var id: String { code }
    let code: String
    let name: String
    let confederation: String
    let fifa_rank: Int
    let flag: String
}

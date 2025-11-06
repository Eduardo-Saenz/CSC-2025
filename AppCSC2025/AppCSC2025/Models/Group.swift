//
//  Group.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation

// MARK: - GroupSet (raíz de groups.json)
struct GroupSet: Decodable {
    let groups: [Group]
}

// MARK: - Group
struct Group: Decodable, Hashable, Identifiable {
    var id: String { group }
    let group: String
    let teams: [Team]
}

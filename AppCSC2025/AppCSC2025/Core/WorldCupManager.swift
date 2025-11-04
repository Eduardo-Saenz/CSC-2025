//
//  WorldCupManager.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation
import SwiftUI

/// Carga datos del Mundial (grupos, partidos, movilidad) desde JSON.
final class WorldCupManager: ObservableObject {
    @Published var groups: [GroupData] = []
    @Published var matches: [MatchData] = []
    @Published var mobility: [MobilityData] = []
    
    init() {
        loadData()
    }
    
    func loadData() {
        groups = load("groups", as: [GroupData].self)
        matches = load("matches", as: [MatchData].self)
        mobility = load("mobility", as: [MobilityData].self)
        matches.sort { ($0.matchDate ?? Date()) < ($1.matchDate ?? Date()) }
    }
    
    private func load<T: Decodable>(_ name: String, as type: T.Type) -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] as! T }
        let decoder = JSONDecoder()
        return (try? decoder.decode(T.self, from: data)) ?? [] as! T
    }
}

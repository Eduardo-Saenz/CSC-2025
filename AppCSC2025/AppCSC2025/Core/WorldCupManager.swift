//
//  WorldCupManager.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation
import SwiftUI

/// Carga datos del Mundial (grupos, partidos, movilidad) desde JSON usando nuestros modelos.
@MainActor
final class WorldCupManager: ObservableObject {
    // 👇 Publica NUESTROS modelos (no GroupData/MatchData)
    @Published private(set) var groups: [Group] = []
    @Published private(set) var matches: [Match] = []
    @Published private(set) var mobility: [Mobility] = []

    init() {
        loadData()
    }

    func loadData() {
        // 1) Grupos
        // - Nuestros groups vienen enraizados en GroupSet { groups: [Group] }
        if let set: GroupSet? = tryDecode("groups.json") {
            groups = set?.groups ?? []
        }

        // 2) Partidos
        // - Nuestro archivo es una lista directa de Match
        if let ms: [Match]? = tryDecode("matches.json") {
            matches = ms ?? []
        }

        // 3) Movilidad
        if let mob: [Mobility]? = tryDecode("mobility.json") {
            mobility = mob ?? []
        }

        // Ordenar partidos por fecha (utiliza nuestro helper `kickoffDateUTC`)
        matches.sort { ($0.kickoffDateUTC ?? .distantFuture) < ($1.kickoffDateUTC ?? .distantFuture) }
    }

    // MARK: - Generic decode helper (usa JSONLoader internamente si quieres)
    private func tryDecode<T: Decodable>(_ filename: String) -> T? {
        guard let url = Bundle.main.url(forResource: (filename as NSString).deletingPathExtension,
                                        withExtension: (filename as NSString).pathExtension.isEmpty ? "json" : (filename as NSString).pathExtension)
        else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let dec = JSONDecoder()
            return try dec.decode(T.self, from: data)
        } catch {
            // print("Decode error for \(filename): \(error)")
            return nil
        }
    }
}

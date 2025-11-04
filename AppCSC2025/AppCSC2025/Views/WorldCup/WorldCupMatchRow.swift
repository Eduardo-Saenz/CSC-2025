//
//  MatchRow.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

struct WorldCupMatchRow: View {
    let match: MatchData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(formattedDate) — Grupo \(match.group)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(match.teams[0]) 🆚 \(match.teams[1])")
                .font(.headline)
            Text(match.stadium)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }

    private var formattedDate: String {
        guard let date = match.matchDate else { return match.date }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

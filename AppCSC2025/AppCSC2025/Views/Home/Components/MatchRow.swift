//
//  MatchRow.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct MatchRow: View {
    let match: MatchEvent
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(spacing: 6) {
                Text(match.date.monthAbbrev.uppercased())
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
                Text(match.date.dayNumber)
                    .font(.title2).bold()
            }
            .frame(width: 48)
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(match.homeTeam) vs \(match.awayTeam)")
                        .font(.headline)
                    Spacer()
                }
                HStack(spacing: 10) {
                    Label(match.date.timeShort, systemImage: "clock")
                    Label("\(match.stadium)", systemImage: "building.2")
                    Label("\(match.city)", systemImage: "mappin.and.ellipse")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

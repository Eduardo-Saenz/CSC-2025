//
//  MatchRow.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct MatchRow: View {
    let match: Match
    
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(spacing: 6) {
                Text(match.kickoffDateUTC!.monthAbbrev.uppercased())
                    .font(.caption2).bold()
                    .foregroundStyle(.secondary)
                Text(match.kickoffDateUTC!.dayNumber)
                    .font(.title2).bold()
            }
            .frame(width: 48)
            .padding(8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("\(match.home) vs \(match.away)")
                        .font(.headline)
                    Spacer()
                }
                HStack(spacing: 10) {
                    Label(match.kickoffDateUTC!.timeShort, systemImage: "clock")
                    Label("\(match.venue.stadium)", systemImage: "building.2")
                    Label("\(match.venue.city)", systemImage: "mappin.and.ellipse")
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

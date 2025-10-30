//
//  MatchDetailView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct MatchDetail: View {
    let match: MatchEvent

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("\(match.homeTeam) vs \(match.awayTeam)")
                    .font(.largeTitle).bold()
                Text("\(match.stadium) · \(match.city)")
                    .foregroundStyle(.secondary)
                Text(match.date, style: .date)
                Text(match.date, style: .time)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Match")
        .navigationBarTitleDisplayMode(.inline)
    }
}


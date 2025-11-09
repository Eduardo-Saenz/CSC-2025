//
//  MatchRowView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

struct MatchRowView: View {
    let match: Match
    let home: Team?
    let away: Team?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if let g = match.group {
                    pill("Group \(g)")
                } else {
                    pill(match.stage)
                }
                pill("MD \(match.matchday)")
                pill(match.status.capitalized, color: colorForStatus(match.status))
                Spacer()
            }

            HStack(spacing: 10) {
                teamLabel(team: home, fallbackCode: match.home, alignRight: false)
                Text("vs").font(.footnote).foregroundStyle(.secondary)
                teamLabel(team: away, fallbackCode: match.away, alignRight: true)
                Spacer()
            }
            .font(.headline)

            VStack(alignment: .leading, spacing: 2) {
                Text(match.formattedLocal())
                    .font(.subheadline)
                Text("\(match.venue.stadium), \(match.venue.city)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                if !match.tags.isEmpty {
                    ForEach(match.tags.prefix(2), id: \.self) { tag in
                        pill(tag, color: .gray.opacity(0.2), textColor: .secondary)
                    }
                }
                Spacer()
                ticketPill(match.ticketing.status)
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }

    // MARK: - Subviews/Helpers
    private func teamLabel(team: Team?, fallbackCode: String, alignRight: Bool) -> some View {
        HStack(spacing: 6) {
            if alignRight {
                Text(team?.code ?? fallbackCode).fontWeight(.semibold)
                Text(team?.flag ?? "🏳️")
            } else {
                Text(team?.flag ?? "🏳️")
                Text(team?.code ?? fallbackCode).fontWeight(.semibold)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private func pill(_ text: String,
                      color: Color = .green.opacity(0.15),
                      textColor: Color = .green) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(textColor)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(color)
            .clipShape(Capsule())
    }

    private func ticketPill(_ status: String) -> some View {
        let style: (Color, Color) = {
            switch status {
            case "very-low": return (.red.opacity(0.15), .red)
            case "low":      return (.orange.opacity(0.15), .orange)
            case "medium":   return (.yellow.opacity(0.15), .yellow)
            default:         return (.green.opacity(0.15), .green)
            }
        }()
        return pill("Tickets: \(status)", color: style.0, textColor: style.1)
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "live": return .red
        case "finished": return .gray
        default: return .blue
        }
    }
}

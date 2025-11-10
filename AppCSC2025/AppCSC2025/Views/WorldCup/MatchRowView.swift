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

    // 🎨 Paleta FIFA 2026 más suave
    private let fifaGreen = Color(hex: "006847")
    private let fifaRed   = Color(hex: "E85A5A")
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 🏷️ Línea de etiquetas (grupo, jornada, estado)
            HStack(spacing: 6) {
                if let g = match.group {
                    pill("Grupo \(g)")
                } else {
                    pill(match.stage)
                }
                pill("MD \(match.matchday)")
                pill(match.status.capitalized, color: colorForStatus(match.status).opacity(0.15),
                     textColor: colorForStatus(match.status))
                Spacer()
            }

            // ⚽️ Equipos
            HStack(spacing: 10) {
                teamLabel(team: home, fallbackCode: match.home, alignRight: false)
                Text("vs").font(.footnote).foregroundStyle(.secondary)
                teamLabel(team: away, fallbackCode: match.away, alignRight: true)
                Spacer()
            }
            .font(.headline)

            // 📍 Fecha y sede
            VStack(alignment: .leading, spacing: 2) {
                Text(match.formattedLocal())
                    .font(.subheadline)
                Text("\(match.venue.stadium), \(match.venue.city)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // 🎟️ Tickets y tags
            HStack(spacing: 8) {
                if !match.tags.isEmpty {
                    ForEach(match.tags.prefix(2), id: \.self) { tag in
                        pill(tag, color: .gray.opacity(0.15), textColor: .secondary)
                    }
                }
                Spacer()
                ticketPill(match.ticketing.status)
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: fifaGreen.opacity(0.08), radius: 3, x: 0, y: 2)
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
                      color: Color = Color.gray.opacity(0.1),
                      textColor: Color = .secondary) -> some View {
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
            case "very-low": return (fifaRed.opacity(0.15), fifaRed)
            case "low":      return (.orange.opacity(0.15), .orange)
            case "medium":   return (fifaBlue.opacity(0.12), fifaBlue)
            default:         return (fifaGreen.opacity(0.15), fifaGreen)
            }
        }()
        return pill("Tickets: \(status.capitalized)", color: style.0, textColor: style.1)
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status {
        case "live": return fifaRed
        case "finished": return .gray.opacity(0.7)
        default: return fifaBlue
        }
    }
}

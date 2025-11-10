//
//  MatchDetailView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/10/25.
//

import SwiftUI

struct MatchDetailView: View {
    let match: Match

    // 🎨 Colores FIFA 2026
    private let fifaGreen = Color(hex: "006847") // 🇲🇽
    private let fifaRed   = Color(hex: "CE1125") // 🇨🇦
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // 🇺🇸

    var body: some View {
        ZStack {
            // 🌍 Fondo tricolor
            LinearGradient(
                gradient: Gradient(colors: [
                    fifaGreen.opacity(0.25),
                    Color.white,
                    fifaBlue.opacity(0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 🏆 Encabezado principal
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text(match.home)
                                .font(.title)
                                .fontWeight(.semibold)
                            Text("vs")
                                .foregroundColor(.secondary)
                            Text(match.away)
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(fifaGreen)

                        Text("\(match.venue.stadium) · \(match.venue.city)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            Label {
                                Text(match.formattedLocal(dateStyle: .medium, timeStyle: .none))
                            } icon: {
                                Image(systemName: "calendar")
                            }

                            Label {
                                Text(match.formattedLocal(dateStyle: .none, timeStyle: .short))
                            } icon: {
                                Image(systemName: "clock")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)

                    // 🖼️ Espacio para la foto del estadio
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .frame(height: 220)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(fifaGreen.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: fifaGreen.opacity(0.08), radius: 4, y: 2)

                        Text("Foto del estadio aquí")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)

                    // 🎟️ Información del partido
                    VStack(alignment: .leading, spacing: 16) {
                        infoRow(icon: "flag.2.crossed", title: "Fase", value: match.stage)
                        if let group = match.group {
                            infoRow(icon: "square.grid.3x3.square.fill", title: "Grupo", value: group)
                        }
                        infoRow(
                            icon: "clock.badge.checkmark",
                            title: "Estado",
                            value: match.status.capitalized,
                            color: colorForStatus(match.status)
                        )

                        infoRow(icon: "person.3.sequence", title: "Importancia", value: formatImportance(match.importance))
                        infoRow(icon: "ticket.fill", title: "Boletos", value: ticketDescription(match.ticketing))
                    }
                    .font(.subheadline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: fifaGreen.opacity(0.1), radius: 4, y: 2)
                    )
                    .padding(.horizontal)

                    // 📺 Transmisión y Predicción
                    VStack(alignment: .leading, spacing: 16) {
                        if !match.broadcast.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Transmisión", systemImage: "tv")
                                    .font(.subheadline.weight(.semibold))
                                Text(match.broadcast.joined(separator: " · "))
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Predicción", systemImage: "chart.bar.fill")
                                .font(.subheadline.weight(.semibold))
                            HStack {
                                predictionBar(team: match.home, probability: match.prediction.home_win_prob, color: fifaGreen)
                                predictionBar(team: "Empate", probability: match.prediction.draw_prob, color: .gray)
                                predictionBar(team: match.away, probability: match.prediction.away_win_prob, color: fifaBlue)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.9))
                            .shadow(color: fifaGreen.opacity(0.1), radius: 4, y: 2)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Partido")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers
    private func infoRow(icon: String, title: String, value: String, color: Color? = nil) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundColor(color ?? .primary)
        }
    }

    private func formatImportance(_ importance: String) -> String {
        switch importance {
        case "group-opener": return "Apertura de grupo"
        case "final": return "Final"
        case "semi-final": return "Semifinal"
        default: return importance.capitalized
        }
    }

    private func ticketDescription(_ ticket: Match.Ticketing) -> String {
        let status = ticket.status.capitalized
        let price = ticket.min_price > 0 ? "$\(ticket.min_price)" : "N/D"
        return "\(status) · Desde \(price)"
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "live": return fifaRed
        case "finished": return .gray.opacity(0.7)
        default: return fifaBlue
        }
    }

    private func predictionBar(team: String, probability: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(team)
                .font(.caption2)
                .foregroundColor(.secondary)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 6)
                Capsule()
                    .fill(color.opacity(0.8))
                    .frame(width: CGFloat(probability) * 100, height: 6)
            }
            Text("\(Int(probability * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

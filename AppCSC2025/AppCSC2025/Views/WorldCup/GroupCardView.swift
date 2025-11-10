//
//  GroupCardView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

struct GroupCardView: View {
    let group: Group
    let teams: [Team]

    // 🎨 Colores FIFA 2026
    private let fifaGreen = Color(hex: "006847") // 🇲🇽 México
    private let fifaRed   = Color(hex: "CE1125") // 🇨🇦 Canadá
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // 🇺🇸 USA

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Encabezado del grupo
            HStack {
                Text("Grupo \(group.group)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [fifaGreen, fifaBlue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                Spacer()
            }

            // Encabezado de columnas
            HStack {
                Text("Equipo").fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Código").frame(width: 44, alignment: .trailing)
                Text("Conf.").frame(width: 68, alignment: .trailing)
                Text("Ranking").frame(width: 52, alignment: .trailing)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)

            Divider()
                .overlay(fifaGreen.opacity(0.3))

            // Equipos
            ForEach(teams, id: \.code) { team in
                HStack {
                    Text("\(team.flag) \(team.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)

                    Text(team.code)
                        .frame(width: 44, alignment: .trailing)
                        .foregroundColor(.primary)

                    Text(shortConf(team.confederation))
                        .frame(width: 68, alignment: .trailing)
                        .foregroundColor(.secondary)

                    Text("\(team.fifa_rank)")
                        .frame(width: 52, alignment: .trailing)
                        .fontWeight(.medium)
                        .foregroundColor(fifaBlue)
                }
                .font(.caption2)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                        .opacity(0.4)
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(.systemGray6).opacity(0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: fifaGreen.opacity(0.15), radius: 5, x: 0, y: 3)
    }

    private func shortConf(_ conf: String) -> String {
        switch conf.lowercased() {
        case "uefa": return "Europa"
        case "conmebol": return "Sudamérica"
        case "concacaf": return "Norteamérica"
        case "caf": return "África"
        case "afc": return "Asia"
        case "ofc": return "Oceanía"
        default: return conf
        }
    }
}


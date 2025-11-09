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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grupo \(group.group)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.green)
                .cornerRadius(8)

            HStack {
                Text("Equipo").fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Code").frame(width: 44, alignment: .trailing)
                Text("Conf").frame(width: 68, alignment: .trailing)
                Text("Rank").frame(width: 40, alignment: .trailing)
            }
            .font(.caption)
            .padding(.horizontal, 4)

            ForEach(teams, id: \.code) { team in
                HStack {
                    Text("\(team.flag) \(team.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    Text(team.code).frame(width: 44, alignment: .trailing)
                    Text(shortConf(team.confederation)).frame(width: 68, alignment: .trailing)
                    Text("\(team.fifa_rank)").frame(width: 40, alignment: .trailing)
                }
                .font(.caption2)
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func shortConf(_ conf: String) -> String {
        
        conf
    }
}

//
//  GroupCardView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

struct GroupCardView: View {
    let group: GroupData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grupo \(group.id)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.green)
                .cornerRadius(8)

            HStack {
                Text("Equipo").fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .leading)
                Text("Pts").frame(width: 30, alignment: .trailing)
                Text("J").frame(width: 20, alignment: .trailing)
                Text("G").frame(width: 20, alignment: .trailing)
                Text("E").frame(width: 20, alignment: .trailing)
                Text("P").frame(width: 20, alignment: .trailing)
            }
            .font(.caption)
            .padding(.horizontal, 4)

            ForEach(group.teams) { team in
                HStack {
                    Text("\(team.flag) \(team.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    Text("\(team.points)").frame(width: 30, alignment: .trailing)
                    Text("\(team.played)").frame(width: 20, alignment: .trailing)
                    Text("\(team.wins)").frame(width: 20, alignment: .trailing)
                    Text("\(team.draws)").frame(width: 20, alignment: .trailing)
                    Text("\(team.losses)").frame(width: 20, alignment: .trailing)
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
}

//
//  NewsCard.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct NewsCard: View {
    let item: NewsItem

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [Color.accentColor.opacity(0.25), Color.blue.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.primary.opacity(0.06))
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(item.tag.uppercased())
                        .font(.caption2).bold()
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.primary.opacity(0.08), in: Capsule())
                    Spacer()
                    Image(systemName: item.icon)
                        .imageScale(.medium)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(item.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 2)
    }
}

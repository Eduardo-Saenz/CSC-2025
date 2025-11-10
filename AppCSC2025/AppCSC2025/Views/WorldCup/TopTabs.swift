//
//  TopTabs.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

struct TopTabs: View {
    @Binding var selection: WorldCupPage
    let namespace: Namespace.ID

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                
                Spacer()
                
                ForEach(WorldCupPage.allCases) { page in
                    Button {
                        selection = page
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: page.systemImage)
                                Text(page.title)
                                    .fontWeight(selection == page ? .semibold : .regular)
                            }
                            .font(.subheadline)

                            ZStack {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(height: 2)
                                if selection == page {
                                    Rectangle()
                                        .fill(Color.accentColor)
                                        .frame(height: 2)
                                        .matchedGeometryEffect(id: "underline", in: namespace)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            Capsule()
                                .fill(selection == page ? Color.accentColor.opacity(0.10) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        }
        .background(.ultraThinMaterial)
    }
}

//
//  WorldCupView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI

struct WorldCupView: View {
    @StateObject private var manager = WorldCupManager()
    @State private var selection: WorldCupPage = .matches
    @Namespace private var underlineNS
    @EnvironmentObject var settings: AppSettings

    // 🎨 Colores oficiales FIFA 2026
    private let fifaGreen = Color(hex: "006847") 
    private let fifaRed   = Color(hex: "CE1125")
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94)

    var body: some View {
        ZStack {
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

            VStack(spacing: 0) {
                TopTabs(selection: $selection, namespace: underlineNS)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.85),
                                fifaGreen.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: fifaGreen.opacity(0.1), radius: 4, y: 2)

                TabView(selection: $selection) {
                    MatchesListView(manager: manager)
                        .tag(WorldCupPage.matches)
                    GroupListView(manager: manager)
                        .tag(WorldCupPage.groups)
                    MobilityListView(manager: manager)
                        .tag(WorldCupPage.mobility)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: selection)
            }
        }
        .navigationTitle("Copa Mundial 2026")
        .navigationBarTitleDisplayMode(.inline)
    }
}

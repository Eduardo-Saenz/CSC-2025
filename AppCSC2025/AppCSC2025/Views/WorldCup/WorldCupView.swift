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

    var body: some View {
        VStack(spacing: 0) {
            TopTabs(selection: $selection, namespace: underlineNS)

            TabView(selection: $selection) {
                MatchesListView(manager: manager)
                    .tag(WorldCupPage.matches)
                GroupListView(manager: manager)
                    .tag(WorldCupPage.groups)
                MobilityListView(manager: manager)
                    .tag(WorldCupPage.mobility)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selection)
        }
        .navigationTitle("World Cup 2026")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                TopBarSettingsButton()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}


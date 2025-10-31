//
//  HomeTabView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct HomeTabView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .environmentObject(vm)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("Explore", systemImage: "safari")
            }
            NavigationStack {
                CameraView()
            
            }.tabItem {
                Label("Camera", systemImage: "camera")
            }
        }
    }
}


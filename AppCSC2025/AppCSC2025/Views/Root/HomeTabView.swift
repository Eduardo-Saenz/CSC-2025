//
//  HomeTabView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct HomeTabView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            // Pestaña Home (original)
            NavigationStack {
                HomeView()
                    .environmentObject(vm)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            // Nueva pestaña Mundial 2026
            NavigationStack {
                WorldCupView()
            }
            .tabItem {
                Label("Mundial", systemImage: "sportscourt.fill")
            }
            
            // Cámara (conservada del proyecto original)
            NavigationStack {
                CameraView()
            }
            .tabItem {
                Label("Camera", systemImage: "camera")
            }
            
            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label("Explorar", systemImage: "binoculars")
            }

            // Traductor
            //NavigationStack {
            // TranslatorView()
            // }
            //.tabItem {
            //    Label("Traductor", systemImage: "mic.fill")
            //}

            // Ajustes
            NavigationStack {
                SettingsView()
                    .environmentObject(settings)
            }
            .tabItem {
                Label("Ajustes", systemImage: "gear")
            }

            
        }
    }
}

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
            NavigationStack { HomeView().environmentObject(vm) }
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            NavigationStack { WorldCupView() }
                .tabItem { Label("Mundial", systemImage: "sportscourt.fill") }
            
            NavigationStack { CameraView() }
                .tabItem { Label("Camera", systemImage: "camera") }
            
            NavigationStack{ ConversationView() }
                .tabItem{ Label("Interprete", systemImage: "mic.fill")}

            
        }
    }
}

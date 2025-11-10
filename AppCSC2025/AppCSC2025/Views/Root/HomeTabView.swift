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

    private let fifaRed = Color(red: 0.81, green: 0.07, blue: 0.14) // #CE1125
    private let fifaGreen = Color(red: 0.0, green: 0.41, blue: 0.28) // #006847
    private let fifaGold = Color(red: 0.93, green: 0.78, blue: 0.40)

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.red)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.red)
        ]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    var body: some View {
        TabView {
            NavigationStack { HomeView().environmentObject(vm) }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            NavigationStack { WorldCupView() }
                .tabItem {
                    Label("Mundial", systemImage: "sportscourt.fill")
                }

            NavigationStack { CameraView() }
                .tabItem {
                    Label("Cámara", systemImage: "camera.fill")
                }

            NavigationStack { ConversationView() }
                .tabItem {
                    Label("Intérprete", systemImage: "mic.fill")
                }
        }
        .accentColor(fifaRed)
        .tint(fifaRed)
        .background(.ultraThinMaterial)
    }
}

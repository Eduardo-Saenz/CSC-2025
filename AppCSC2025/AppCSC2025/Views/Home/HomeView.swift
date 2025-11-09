//
//  HomeView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                newsCarousel
                matchesSection
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 24)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        .background(Color(.systemBackground))
    }
    
    // MARK: Header
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Good morning, \(vm.userName)")
                    .font(.largeTitle).bold()
                    .lineLimit(2)
                Text(Date.now, format: .dateTime.weekday(.wide).day().month().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TopBarSettingsButton()
        }
    }


    
    private var newsCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today Highlights", systemImage: "bolt.fill")
                    .font(.title3).bold()
                Spacer()
                Button("See all") {}
                    .font(.subheadline)
            }
            
            TabView {
                ForEach(vm.news) { item in
                    NewsCard(item: item)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 2)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 180)
        }
    }
    
    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Your Matches", systemImage: "calendar")
                    .font(.title3).bold()
                Spacer()
                Button(action: {}) { Text("Add") }
                    .font(.subheadline)
            }
            
            VStack(spacing: 10) {
                ForEach(vm.matches) { match in
                    NavigationLink(value: match) {
                        MatchRow(match: match)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationDestination(for: MatchEvent.self) { match in
                MatchDetail(match: match)
            }
        }
    }
}

#Preview {
    HomeView()
}


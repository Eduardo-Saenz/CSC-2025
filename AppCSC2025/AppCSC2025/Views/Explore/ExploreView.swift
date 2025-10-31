//
//  ExploreView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct ExploreView: View {
    @EnvironmentObject private var vm: HomeViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Coming soon ✨")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .navigationTitle("Explore")
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
}

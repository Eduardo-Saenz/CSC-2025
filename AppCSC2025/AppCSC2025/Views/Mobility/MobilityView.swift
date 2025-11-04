//
//  MobilityView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import SwiftUI
import MapKit

struct MobilityView: View {
    @StateObject private var manager = WorldCupManager()
    @State private var selectedCity: String = ""
    
    private var cities: [String] {
        Array(Set(manager.mobility.map { $0.city })).sorted()
    }
    private var filtered: [MobilityData] {
        manager.mobility.filter { $0.city == selectedCity }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if !cities.isEmpty {
                    Picker("Sede", selection: $selectedCity) {
                        ForEach(cities, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filtered) { entry in
                            MobilityCard(entry: entry)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                if let first = cities.first { selectedCity = first }
            }
            .navigationTitle("Movilidad")
        }
    }
}

private struct MobilityCard: View {
    let entry: MobilityData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(entry.city) — \(entry.stadium)")
                .font(.headline)
                .foregroundColor(.green)
            LabelRow(title: "Metro", value: entry.metro)
            LabelRow(title: "Autobús", value: entry.bus)
            LabelRow(title: "Caminata", value: entry.walk)
            LabelRow(title: "Tip", value: entry.tip)
            Button {
                openInMaps(place: "\(entry.stadium), \(entry.city)")
            } label: {
                HStack { Image(systemName: "map.fill"); Text("Cómo llegar") }
                    .font(.subheadline.bold())
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private func openInMaps(place: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = place
        MKLocalSearch(request: request).start { response, _ in
            guard let item = response?.mapItems.first else { return }
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}

private struct LabelRow: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
            Text(value)
                .font(.caption2)
        }
    }
}

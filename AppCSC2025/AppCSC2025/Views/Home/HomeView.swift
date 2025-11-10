//
//  HomeView.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var HomeVM: HomeViewModel
    @EnvironmentObject var MatchesVM: MatchesViewModel

    // 🎨 Paleta del Mundial
    private let green = Color(hex: "006847")
    private let red = Color(hex: "CE1125")

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    highlightsSection
                    matchesSection
                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
        .toolbar { ToolbarItem(placement: .principal) { EmptyView() } }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - HEADER
    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning, \(HomeVM.userName)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text(Date.now, format: .dateTime.weekday(.wide).day().month().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TopBarSettingsButton()
        }
        .padding(.bottom, 4)
    }

    // MARK: - TODAY HIGHLIGHTS
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Today Highlights", systemImage: "bolt.fill")
                    .font(.title3.bold())
                    .foregroundStyle(green)
                Spacer()
            }

            TabView {
                ForEach(HomeVM.news) { item in
                    NewsCard(item: item)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 3)
                        .padding(.horizontal, 2)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 180)
        }
    }

    // MARK: - YOUR MATCHES
    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Your Matches", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(green)
            }

            VStack(spacing: 12) {
                ForEach(MatchesVM.userMatches) { match in
                    NavigationLink(value: match) {
                        VStack(alignment: .leading, spacing: 10) {
                            // Fecha del partido
                            Text(match.formattedLocal(dateStyle: .medium, timeStyle: .none))
                                .font(.caption.bold())
                                .foregroundStyle(.secondary)

                            // 🏳️ Equipos con banderas
                            HStack {
                                flag(for: match.home)
                                    .font(.title3)
                                Text(match.home)
                                    .font(.headline)
                                    .foregroundColor(color(for: match.home))

                                Spacer()

                                Text("vs")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text(match.away)
                                    .font(.headline)
                                    .foregroundColor(color(for: match.away))
                                flag(for: match.away)
                                    .font(.title3)
                            }

                            // 📍 Detalles
                            HStack(spacing: 8) {
                                Label(match.venue.stadium, systemImage: "building.2.fill")
                                Label(match.venue.city, systemImage: "mappin.and.ellipse")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(
                            matchGradient(for: match)
                                .opacity(0.18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        )
                        .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationDestination(for: Match.self) { match in
                MatchDetailView(match: match)
            }
        }
    }

    // MARK: - Gradient per match
    private func matchGradient(for match: Match) -> LinearGradient {
        let colorA = color(for: match.home)
        let colorB = color(for: match.away)
        return LinearGradient(
            colors: [colorA, colorB],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Colors and Flags
    private func color(for team: String) -> Color {
        switch team.lowercased() {
        case "mex", "mexico": return Color(hex: "006847") // 🇲🇽
        case "usa", "estados unidos", "united states": return .blue // 🇺🇸
        case "can", "canada": return .red // 🇨🇦
        case "jpn", "japan", "japón": return .black // 🇯🇵
        case "esp", "spain", "españa": return Color(hex: "C60B1E") // 🇪🇸
        case "ita", "italy", "italia": return Color(hex: "009246") // 🇮🇹
        case "bra", "brazil", "brasil": return Color(hex: "009C3B") // 🇧🇷
        case "ger", "germany", "alemania": return .black // 🇩🇪
        case "fra", "france", "francia": return Color(hex: "0055A4") // 🇫🇷
        case "arg", "argentina": return Color(hex: "75AADB") // 🇦🇷
        default: return .gray
        }
    }

    private func flag(for team: String) -> Text {
        switch team.lowercased() {
        case "mex", "mexico": return Text("🇲🇽")
        case "usa", "united states", "estados unidos": return Text("🇺🇸")
        case "can", "canada": return Text("🇨🇦")
        case "jpn", "japan", "japón": return Text("🇯🇵")
        case "esp", "spain", "españa": return Text("🇪🇸")
        case "ita", "italy", "italia": return Text("🇮🇹")
        case "bra", "brazil", "brasil": return Text("🇧🇷")
        case "ger", "germany", "alemania": return Text("🇩🇪")
        case "fra", "france", "francia": return Text("🇫🇷")
        case "arg", "argentina": return Text("🇦🇷")
        default: return Text("🏳️")
        }
    }

}

// MARK: - COLOR HELPER
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}

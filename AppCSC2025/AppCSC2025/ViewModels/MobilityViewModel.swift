//
//  MobilityViewModel.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation
import Combine

@MainActor
final class MobilityViewModel: ObservableObject {
    @Published private(set) var all: [Mobility] = []
    @Published private(set) var filtered: [Mobility] = []

    
    @Published var selectedCity: String = "All"
    @Published var selectedKind: String = "All"
    @Published var onlyAccessible: Bool = false
    @Published var searchText: String = ""

    private let manager: WorldCupManager
    private var bag = Set<AnyCancellable>()

    init(manager: WorldCupManager) {
        self.manager = manager

        manager.$mobility
            .receive(on: DispatchQueue.main)
            .sink { [weak self] list in
                self?.all = list
                self?.applyFilters()
            }
            .store(in: &bag)

        
        Publishers.CombineLatest4($selectedCity, $selectedKind, $onlyAccessible, $searchText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _, _, _ in
                self?.applyFilters()
            }
            .store(in: &bag)
    }

    // MARK: - Helpers
    var cityOptions: [String] {
        let cities = Set(all.map { $0.city }).sorted()
        return ["All"] + cities
    }

    var kindOptions: [String] {
        
        let kinds = Set(all.flatMap { $0.modes.compactMap { $0.kind } })
            .map { $0.rawValue }
            .sorted()
        return ["All"] + kinds
    }

    private func applyFilters() {
        var base = all

        if selectedCity != "All" {
            base = base.filter { $0.city == selectedCity }
        }
        if selectedKind != "All" {
            base = base.filter { m in
                (m.modes).contains { $0.kind.rawValue == selectedKind }
            }
        }
        if onlyAccessible {
            base = base.filter { m in
                (m.modes).contains { $0.accessible == true }
            }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            base = base.filter { m in
                "\(m.city) \(m.stadium) \(m.advisories?.joined(separator: " ") ?? "")"
                    .lowercased().contains(q)
            }
        }

        filtered = base
    }
}

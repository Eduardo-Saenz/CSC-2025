//
//  GroupsViewModel.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation
import Combine

@MainActor
final class GroupsViewModel: ObservableObject {
    @Published private(set) var groups: [Group] = []
    @Published private(set) var teamsByCode: [String: Team] = [:]

    private let manager: WorldCupManager
    private var bag = Set<AnyCancellable>()

    init(manager: WorldCupManager) {
        self.manager = manager

        // Suscripción: cuando cambie manager.groups, actualizamos el VM
        manager.$groups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                self?.groups = groups
                self?.teamsByCode = groups
                    .flatMap { $0.teams }
                    .reduce(into: [String: Team]()) { $0[$1.code] = $1 }
            }
            .store(in: &bag)
    }
}

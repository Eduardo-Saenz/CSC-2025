//
//  WorldCupPage.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import SwiftUI

enum WorldCupPage: Int, CaseIterable, Identifiable {
    case matches, groups, mobility
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .matches: return "Partidos"
        case .groups:  return "Grupos"
        case .mobility:return "Movilidad"
        }
    }

    var systemImage: String {
        switch self {
        case .matches: return "soccerball"
        case .groups:  return "square.grid.3x3.square"
        case .mobility:return "tram.fill"
        }
    }
}

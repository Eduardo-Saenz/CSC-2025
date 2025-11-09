//
//  Mobility.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 11/5/25.
//

import Foundation

struct Mobility: Codable, Identifiable, Hashable {
    struct Coords: Codable, Hashable { let lat: Double; let lon: Double }

    struct Mode: Codable, Hashable {
        enum Kind: String, Codable { case metro, bus, walk, rideshare, bike, parking }
        let kind: Kind
        let lines: [String]?
        let avg_time_min: Int?
        let fare_min: Double?
        let fare_currency: String?
        let accessible: Bool?
        let notes: String?
        let map_url: String?
    }

    struct Gate: Codable, Hashable {
        let name: String
        let near: [String]?          
        let note: String?
    }

    let id: String
    let city: String
    let stadium: String
    let tz: String?
    let coords: Coords?
    let crowd_level: Int?
    let advisories: [String]?
    let last_updated: String?

    let modes: [Mode]
    let gates: [Gate]?
}


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
        let lines: [String]?          // ["L2", "Ruta A", "M1"] para metro/bus
        let avg_time_min: Int?        // tiempo promedio desde un punto de referencia
        let fare_min: Double?         // estimado
        let fare_currency: String?    // "MXN"
        let accessible: Bool?         // accesibilidad (rampas/elevadores)
        let notes: String?            // texto corto: “Sube en X, baja en Y”
        let map_url: String?          // deeplink Google/Apple Maps
    }

    struct Gate: Codable, Hashable {
        let name: String              // “Puerta 3”
        let near: [String]?           // puntos de referencia cercanos
        let note: String?
    }

    let id: String                    // "\(city)|\(stadium)"
    let city: String                  // "Mexico City"
    let stadium: String               // "Estadio Azteca"
    let tz: String?                   // "America/Mexico_City"
    let coords: Coords?               // coords del estadio
    let crowd_level: Int?             // 1-5 (para UI de “afluencia”)
    let advisories: [String]?         // ["Cierre parcial Línea 9", "Operativo de seguridad"]
    let last_updated: String?         // ISO-8601

    let modes: [Mode]                 // opciones de llegada
    let gates: [Gate]?                // entradas recomendadas
}


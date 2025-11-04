//
//  MobilityData.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//
import Foundation

struct MobilityData: Codable, Identifiable {
    let city: String
    let stadium: String
    let metro: String
    let bus: String
    let walk: String
    let tip: String
    
    var id: String { stadium }
}


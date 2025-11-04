//
//  AppSettings.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 11/3/25.
//

import Foundation
import SwiftUI


class AppSettings: ObservableObject {
    @AppStorage("selectedCountry") var selectedCountry: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = ""

    var isConfigured: Bool {
        !selectedCountry.isEmpty && !selectedLanguage.isEmpty
    }
}

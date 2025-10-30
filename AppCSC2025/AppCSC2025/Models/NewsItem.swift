//
//  NewsItem.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import Foundation

struct NewsItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tag: String
    let date: Date
    let icon: String
}

//
//  HomeViewModel.swift
//  AppCSC2025
//
//  Created by Eduardo Saenz on 10/29/25.
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published var userName: String = "Edu"
    @Published var news: [NewsItem] = SampleData.news
    @Published var matches: [MatchEvent] = SampleData.matches
}

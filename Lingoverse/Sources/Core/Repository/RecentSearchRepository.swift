//
//  RecentSearchRepository.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation

protocol RecentSearchRepositoryProtocol {
    func saveSearch(_ term: String)
    func fetchRecentSearches() -> [String]
    func deleteSearch(_ term: String)
}

final class RecentSearchRepository: RecentSearchRepositoryProtocol {
    
    private let userDefaults: UserDefaults
    private let key = "recent_searches_key"
    private let maxCount = 15

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveSearch(_ term: String) {
        let normalizedTerm = term.lowercased()
        guard !normalizedTerm.isEmpty else { return }
        var currentSearches = fetchRecentSearches()
        currentSearches.removeAll { $0 == normalizedTerm }
        currentSearches.insert(normalizedTerm, at: 0)
        let limitedSearches = Array(currentSearches.prefix(maxCount))
        userDefaults.set(limitedSearches, forKey: key)
    }

    func fetchRecentSearches() -> [String] {
        return userDefaults.stringArray(forKey: key) ?? []
    }
    
    func deleteSearch(_ term: String) {
        let normalizedTerm = term.lowercased()
        var currentSearches = fetchRecentSearches()
        currentSearches.removeAll { $0 == normalizedTerm }
        userDefaults.set(currentSearches, forKey: key)
    }
}

//
//  RecentSearchRepository.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation

struct CachedSearch: Codable, Equatable {
    let term: String
    let results: [WKWord]
    let timestamp: Date
}

protocol RecentSearchRepositoryProtocol {
    func saveSearch(_ term: String, results: [WKWord])
    func fetchRecentSearches() -> [String]
    func getCachedResults(for term: String) -> [WKWord]?
    func deleteSearch(_ term: String)
}

final class RecentSearchRepository: RecentSearchRepositoryProtocol {

    private let userDefaults: UserDefaults
    private let key = "recent_searches_v2"
    private let oldKey = "recent_searches_key"
    private let maxCount = 15

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        migrateIfNeeded()
    }

    private func migrateIfNeeded() {
        if userDefaults.data(forKey: key) != nil { return }

        if let oldTerms = userDefaults.stringArray(forKey: oldKey) {
            let cachedItems = oldTerms.map {
                CachedSearch(term: $0, results: [], timestamp: Date())
            }
            save(items: cachedItems)
userDefaults.removeObject(forKey: oldKey)
        } else {
            let defaultTerms = ["can", "you", "rate", "this", "application"]
            let items = defaultTerms.map { CachedSearch(term: $0, results: [], timestamp: Date()) }
            save(items: items)
        }
    }

    func saveSearch(_ term: String, results: [WKWord]) {
        let normalizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedTerm.isEmpty else { return }

        var currentItems = fetchCachedItems()

        currentItems.removeAll { $0.term == normalizedTerm }

        let newItem = CachedSearch(term: normalizedTerm, results: results, timestamp: Date())
        currentItems.insert(newItem, at: 0)

        let limitedItems = Array(currentItems.prefix(maxCount))
        save(items: limitedItems)
    }

    func fetchRecentSearches() -> [String] {
        return fetchCachedItems().map { $0.term }
    }

    func getCachedResults(for term: String) -> [WKWord]? {
        let normalizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let items = fetchCachedItems()
        return items.first(where: { $0.term == normalizedTerm })?.results
    }

    func deleteSearch(_ term: String) {
        let normalizedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var currentItems = fetchCachedItems()
        currentItems.removeAll { $0.term == normalizedTerm }
        save(items: currentItems)
    }


    private func fetchCachedItems() -> [CachedSearch] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        do {
            let items = try JSONDecoder().decode([CachedSearch].self, from: data)
            return items
        } catch {
            print("Failed to decode recent searches: \(error)")
            return []
        }
    }

    private func save(items: [CachedSearch]) {
        do {
            let data = try JSONEncoder().encode(items)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to encode recent searches: \(error)")
        }
    }
}

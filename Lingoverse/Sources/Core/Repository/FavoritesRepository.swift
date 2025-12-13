//
//  FavoritesRepository.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 5.11.2025.
//

import Foundation

protocol FavoritesRepositoryProtocol {
    func saveFavorite(_ term: String)
    func fetchFavorites() -> [String]
    func deleteFavorite(_ term: String)
    func isFavorite(_ term: String) -> Bool
}

final class FavoritesRepository: FavoritesRepositoryProtocol {
    
    private let userDefaults: UserDefaults
    private let key = "favorites_key"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveFavorite(_ term: String) {
        let normalizedTerm = term.lowercased()
        guard !normalizedTerm.isEmpty else { return }
        
        var currentFavorites = fetchFavorites()
        
        if !isFavorite(normalizedTerm) {
            currentFavorites.insert(normalizedTerm, at: 0)
            userDefaults.set(currentFavorites, forKey: key)
        }
    }

    func fetchFavorites() -> [String] {
        return userDefaults.stringArray(forKey: key) ?? []
    }
    
    func deleteFavorite(_ term: String) {
        let normalizedTerm = term.lowercased()
        var currentFavorites = fetchFavorites()
        currentFavorites.removeAll { $0 == normalizedTerm }
        userDefaults.set(currentFavorites, forKey: key)
    }
    
    func isFavorite(_ term: String) -> Bool {
        return fetchFavorites().contains(term.lowercased())
    }
}

//
//  SearchInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation

protocol SearchInteractorInput: AnyObject {
    func performSearch(query: String, source: String, target: String) async
    func fetchRecentSearches() async
    func saveSearch(_ term: String) async
    func deleteRecentSearch(term: String) async
    func saveFavorite(_ term: String) async
}

protocol SearchInteractorOutput: AnyObject {
    func didLoad(results: [WKWord])
    func didLoadRecentSearches(_ terms: [String])
    func didFail(_ message: String)
}

final class SearchInteractor: SearchInteractorInput {
    private let client: WordKitClient
    private let recentRepo: RecentSearchRepositoryProtocol
    private let favoritesRepo: FavoritesRepositoryProtocol
    
    weak var output: SearchInteractorOutput?
    
    init(client: WordKitClient,
         recentRepo: RecentSearchRepositoryProtocol = RecentSearchRepository(),
         favoritesRepo: FavoritesRepositoryProtocol = FavoritesRepository()) {
        self.client = client
        self.recentRepo = recentRepo
        self.favoritesRepo = favoritesRepo
    }
    
    func performSearch(query: String, source: String, target: String) async {
        do {
            let res = try await client.search(query: query, sourceLang: source, targetLang: target, page: nil)
            output?.didLoad(results: res)
        } catch {
            if let clientError = error as? WordKitClientError {
                switch clientError {
                case .notFound:
                    output?.didLoad(results: [])
                default:
                    output?.didFail(error.localizedDescription)
                }
            } else {
                output?.didFail(error.localizedDescription)
            }
        }
    }
    
    func fetchRecentSearches() async {
        let terms = recentRepo.fetchRecentSearches()
        output?.didLoadRecentSearches(terms)
    }
    
    func saveSearch(_ term: String) async {
        recentRepo.saveSearch(term)
    }
    
    func deleteRecentSearch(term: String) async {
        recentRepo.deleteSearch(term)
    }
    
    func saveFavorite(_ term: String) async {
        favoritesRepo.saveFavorite(term)
    }
}

//
//  FavoritesInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 5.11.2025.
//

import Foundation

protocol FavoritesInteractorInput: AnyObject {
    func fetchFavorites()
    func deleteFavorite(_ term: String)
    func fetchWordDetail(for term: String) async
}

protocol FavoritesInteractorOutput: AnyObject {
    func didLoadFavorites(_ terms: [String])
    func didLoadWordDetail(_ word: WKWord)
    func didFail(message: String)
}

final class FavoritesInteractor: FavoritesInteractorInput {
    
    private let client: WordKitClient
    private let repository: FavoritesRepositoryProtocol
    
    weak var output: FavoritesInteractorOutput?
    
    init(client: WordKitClient,
         repository: FavoritesRepositoryProtocol = FavoritesRepository()) {
        self.client = client
        self.repository = repository
    }
    
    func fetchFavorites() {
        let terms = repository.fetchFavorites()
        output?.didLoadFavorites(terms)
    }
    
    func deleteFavorite(_ term: String) {
        repository.deleteFavorite(term)
    }
    
    func fetchWordDetail(for term: String) async {
        do {
            let res = try await client.search(query: term, sourceLang: "en", targetLang: "tr", page: nil)
            if let firstWord = res.first {
                output?.didLoadWordDetail(firstWord)
            } else {
                output?.didFail(message: "Word not found")
            }
        } catch {
            output?.didFail(message: error.localizedDescription)
        }
    }
}

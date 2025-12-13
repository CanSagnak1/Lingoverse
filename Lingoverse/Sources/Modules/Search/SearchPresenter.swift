//
//  SearchPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation
import UIKit

enum SearchState: Equatable {
    case idle
    case loading
    case recent([String])
    case empty(String)
    case error(String)
}

protocol SearchViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapSearchButton(query: String)
    func didChangeQueryClear(text: String)
    func didSelectRow(_ index: Int)
    func searchDidDismiss()
    func didDeleteRecentSearch(term: String)
    func didTapFavoriteRecentSearch(term: String)
    func didTapFavoritesButton()
}

@MainActor
final class SearchPresenter: SearchViewOutput, SearchInteractorOutput {
    
    private weak var view: SearchViewInput?
    private let interactor: SearchInteractorInput
    private let router: SearchRouterProtocol
    private var recentSearches: [String] = []
    private var currentQuery: String = ""
    private var wordToRoute: WKWord?
    
    init(view: SearchViewInput, interactor: SearchInteractorInput, router: SearchRouterProtocol) {
        self.view = view; self.interactor = interactor; self.router = router
    }

    func viewDidLoad() {
        view?.render(.idle)
    }
    
    func viewWillAppear() {
        if wordToRoute == nil {
            Task { await self.interactor.fetchRecentSearches() }
        }
    }

    func didChangeQueryClear(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            currentQuery = ""
            Task { await self.interactor.fetchRecentSearches() }
        }
    }

    func didTapSearchButton(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        currentQuery = trimmed
        view?.render(.loading)
        Task {
            await self.interactor.performSearch(query: trimmed, source: "en", target: "tr")
        }
    }

    func didSelectRow(_ index: Int) {
        guard !recentSearches.isEmpty, index < recentSearches.count else { return }
        
        let term = recentSearches[index]
        currentQuery = term
        view?.render(.loading)
        Task {
            await self.interactor.performSearch(query: term, source: "en", target: "tr")
        }
    }
    
    func didLoad(results: [WKWord]) {
        
        if !currentQuery.isEmpty {
            Task { await self.interactor.saveSearch(currentQuery) }
        }
        
        guard let firstWord = results.first else {
            view?.render(.empty("No results found for '\(currentQuery)'."))
            return
        }
        self.wordToRoute = firstWord
        view?.dismissSearch()
    }
    func searchDidDismiss() {
        guard let word = wordToRoute, let vc = view as? UIViewController else {
            if currentQuery.isEmpty {
                 Task { await self.interactor.fetchRecentSearches() }
            }
            return
        }
        self.wordToRoute = nil
        self.router.routeToDetail(from: vc, word: word)
        currentQuery = ""
        Task { await self.interactor.fetchRecentSearches() }
    }
    
    func didLoadRecentSearches(_ terms: [String]) {
        recentSearches = terms
        if currentQuery.isEmpty {
            view?.render(.recent(terms))
        }
    }


    func didDeleteRecentSearch(term: String) {
        recentSearches.removeAll { $0 == term }
        Task {
            await interactor.deleteRecentSearch(term: term)
        }
    }

    func didTapFavoriteRecentSearch(term: String) {
        Task {
            await interactor.saveFavorite(term)
        }
    }

    func didTapFavoritesButton() {
        guard let vc = view as? UIViewController else { return }
        router.routeToFavorites(from: vc)
    }
    
    func didFail(_ message: String) {
        recentSearches = []
        view?.render(.error(message))
    }
}

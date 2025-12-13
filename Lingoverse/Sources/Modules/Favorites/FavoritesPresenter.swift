//
//  FavoritesPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 5.11.2025.
//

import Foundation
import UIKit

enum FavoritesState: Equatable {
    case loading
    case content([String])
    case empty
}

protocol FavoritesViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didSelectRow(_ index: Int)
    func didDeleteFavorite(at index: Int)
    func searchDidDismiss()
}

@MainActor
final class FavoritesPresenter: FavoritesViewOutput, FavoritesInteractorOutput {
    
    private weak var view: FavoritesViewInput?
    private let interactor: FavoritesInteractorInput
    private let router: FavoritesRouterProtocol
    
    private var currentFavorites: [String] = []
    private var wordToRoute: WKWord?
    
    init(view: FavoritesViewInput, interactor: FavoritesInteractorInput, router: FavoritesRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        view?.render(.loading)
        interactor.fetchFavorites()
    }
    
    func viewWillAppear() {
        if wordToRoute == nil {
            interactor.fetchFavorites()
        }
    }
    
    func didLoadFavorites(_ terms: [String]) {
        currentFavorites = terms
        if terms.isEmpty {
            view?.render(.empty)
        } else {
            view?.render(.content(terms))
        }
    }
    
    func didSelectRow(_ index: Int) {
        guard index < currentFavorites.count else { return }
        let term = currentFavorites[index]
        
        view?.render(.loading)
        Task {
            await interactor.fetchWordDetail(for: term)
        }
    }
    
    func didDeleteFavorite(at index: Int) {
        guard index < currentFavorites.count else { return }
        
        let term = currentFavorites[index]
        interactor.deleteFavorite(term)
        
        currentFavorites.remove(at: index)
        if currentFavorites.isEmpty {
            view?.render(.empty)
        } else {
            view?.render(.content(currentFavorites))
        }
    }
    
    func didLoadWordDetail(_ word: WKWord) {
        self.wordToRoute = word
        view?.dismissSearch()
    }
    
    func didFail(message: String) {
        if currentFavorites.isEmpty {
            view?.render(.empty)
        } else {
            view?.render(.content(currentFavorites))
        }
    }
    
    func searchDidDismiss() {
        guard let word = wordToRoute, let vc = view as? UIViewController else {
            return
        }
        self.wordToRoute = nil
        self.router.routeToDetail(from: vc, word: word)
    }
}

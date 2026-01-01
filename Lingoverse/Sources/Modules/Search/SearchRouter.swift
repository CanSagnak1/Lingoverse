//
//  SearchRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

protocol SearchRouterProtocol: AnyObject {
    func routeToDetail(from vc: UIViewController, word: WKWord)
    func routeToFavorites(from vc: UIViewController)
    func routeToSettings(from vc: UIViewController)
    func routeToLearn(from vc: UIViewController)
}

final class SearchRouter: SearchRouterProtocol {

    static func createModule(client: WordKitClient = WordKitClientLive()) -> UIViewController {
        let view = SearchViewController()
        let router = SearchRouter()

        let interactor = SearchInteractor(
            client: client,
            recentRepo: RecentSearchRepository(),
            favoritesRepo: FavoritesRepository())

        let presenter = SearchPresenter(view: view, interactor: interactor, router: router)

        interactor.output = presenter
        view.presenter = presenter

        return view
    }

    func routeToDetail(from vc: UIViewController, word: WKWord) {
        let detailVC = SearchDetailRouter.createModule(with: word)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }

    func routeToFavorites(from vc: UIViewController) {
        let favoritesVC = FavoritesRouter.createModule()
        vc.navigationController?.pushViewController(favoritesVC, animated: true)
    }

    func routeToSettings(from vc: UIViewController) {
        let settingsVC = SettingsRouter.createModule()
        vc.navigationController?.pushViewController(settingsVC, animated: true)
    }

    func routeToLearn(from vc: UIViewController) {
        let learnVC = LearnRouter.createModule()
        vc.navigationController?.pushViewController(learnVC, animated: true)
    }
}

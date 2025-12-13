//
//  FavoritesRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 5.11.2025.
//

import UIKit

protocol FavoritesRouterProtocol: AnyObject {
    func routeToDetail(from vc: UIViewController, word: WKWord)
}

final class FavoritesRouter: FavoritesRouterProtocol {
    
    static func createModule(client: WordKitClient = WordKitClientLive()) -> UIViewController {
        let view = FavoritesViewController()
        let router = FavoritesRouter()
        
        let interactor = FavoritesInteractor(client: client, repository: FavoritesRepository())
        
        let presenter = FavoritesPresenter(view: view, interactor: interactor, router: router)
        
        interactor.output = presenter
        view.presenter = presenter
        
        return view
    }
    
    func routeToDetail(from vc: UIViewController, word: WKWord) {
        let detailVC = SearchDetailRouter.createModule(with: word)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
}

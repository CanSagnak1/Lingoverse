//
//  SearchDetailRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

protocol SearchDetailRouterProtocol: AnyObject {
    
}

final class SearchDetailRouter: SearchDetailRouterProtocol {

    static func createModule(with word: WKWord) -> UIViewController {
        let view = SearchDetailViewController()
        let router = SearchDetailRouter()
        
        let interactor = SearchDetailInteractor(initialWord: word)
        
        let presenter = SearchDetailPresenter(view: view,
                                            interactor: interactor,
                                            router: router)
        
        interactor.output = presenter
        view.presenter = presenter
        
        return view
    }
}

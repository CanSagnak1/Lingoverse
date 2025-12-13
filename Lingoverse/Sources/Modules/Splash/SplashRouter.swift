//
//  SplashRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 6.11.2025.
//

import UIKit

enum SplashRoute {
    case home
}

protocol SplashRouterProtocol: AnyObject {
    func navigate(to route: SplashRoute)
}

final class SplashRouter: SplashRouterProtocol {
    
    weak var viewController: UIViewController?
    weak var window: UIWindow?
    
    static func createModule(window: UIWindow) -> UIViewController {
        let view = SplashViewController()
        let router = SplashRouter()
        let interactor = SplashInteractor()
        let presenter = SplashPresenter(view: view,
                                        interactor: interactor,
                                        router: router)
        
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        router.window = window
        
        return view
    }
    
    func navigate(to route: SplashRoute) {
        guard let window = self.window else { return }
        
        switch route {
        case .home:
            let mainVC = ApplicationRoot.makeRoot()
            let duration = 0.5
            UIView.transition(with: window,
                              duration: duration,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = mainVC
            },
                              completion: nil)
        }
    }
}

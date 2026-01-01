//
//  OnboardingRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol OnboardingRouterProtocol {
    func navigateToMain()
}

final class OnboardingRouter: OnboardingRouterProtocol {

    private weak var viewController: UIViewController?
    private weak var window: UIWindow?

    static func createModule(window: UIWindow?) -> UIViewController {
        let view = OnboardingViewController()
        let router = OnboardingRouter()
        let presenter = OnboardingPresenter(view: view, router: router)

        view.presenter = presenter
        router.viewController = view
        router.window = window

        return view
    }

    func navigateToMain() {
        guard let window = window else { return }

        let mainVC = ApplicationRoot.makeRoot()

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = mainVC
            }, completion: nil)
    }
}

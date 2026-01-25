//
//  ProfileRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import UIKit

protocol ProfileRouterProtocol: AnyObject {
    // Future navigation methods can be added here
}

final class ProfileRouter: ProfileRouterProtocol {

    static func createModule() -> UIViewController {
        let view = ProfileViewController()
        let interactor = ProfileInteractor()
        let presenter = ProfilePresenter(view: view, interactor: interactor)

        interactor.output = presenter
        view.presenter = presenter

        return view
    }
}

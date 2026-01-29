//
//  ARScannerRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import UIKit

protocol ARScannerRouterProtocol: AnyObject {
    func dismiss()
}

final class ARScannerRouter: ARScannerRouterProtocol {
    weak var viewController: UIViewController?

    static func createModule() -> UIViewController {
        let view = ARScannerViewController()
        let interactor = ARScannerInteractor()
        let presenter = ARScannerPresenter()
        let router = ARScannerRouter()

        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        router.viewController = view

        return view
    }

    func dismiss() {
        viewController?.dismiss(animated: true)
    }
}

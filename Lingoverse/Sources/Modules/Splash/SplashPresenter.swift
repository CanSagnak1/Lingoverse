//
//  SplashPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 6.11.2025.
//

import Foundation

protocol SplashViewOutput: AnyObject {
    func viewDidLoad()
    func videoDidFinish()
}

final class SplashPresenter: SplashViewOutput, SplashInteractorOutput {
    private weak var view: SplashViewInput?
    private let interactor: SplashInteractorInput
    private let router: SplashRouterProtocol
    private var isInternetAvailable: Bool = false

    init(
        view: SplashViewInput,
        interactor: SplashInteractorInput,
        router: SplashRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        interactor.checkInternet()
        view?.playVideo()
    }

    func videoDidFinish() {
        if isInternetAvailable {
            // Check if user has seen onboarding
            if OnboardingManager.shared.hasSeenOnboarding {
                router.navigate(to: .home)
            } else {
                router.navigate(to: .onboarding)
            }
        } else {
            view?.showAlert(title: Strings.errorLabel, message: Strings.errorIntCon)
        }
    }

    func internetCheckCompleted(isSuccess: Bool) {
        self.isInternetAvailable = isSuccess
    }
}

//
//  LearnRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol LearnRouterProtocol {
    func routeToFlashcard(from vc: UIViewController, words: [String])
    func routeToQuiz(from vc: UIViewController, words: [String])
    func routeToStats(from vc: UIViewController)
}

final class LearnRouter: LearnRouterProtocol {

    static func createModule() -> UIViewController {
        let view = LearnViewController()
        let router = LearnRouter()
        let presenter = LearnPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }

    func routeToFlashcard(from vc: UIViewController, words: [String]) {
        let flashcardVC = FlashcardViewController(words: words)
        flashcardVC.modalPresentationStyle = .fullScreen
        vc.present(flashcardVC, animated: true)
    }

    func routeToQuiz(from vc: UIViewController, words: [String]) {
        let quizVC = QuizViewController(words: words)
        quizVC.modalPresentationStyle = .fullScreen
        vc.present(quizVC, animated: true)
    }

    func routeToStats(from vc: UIViewController) {
        let statsVC = StatsViewController()
        vc.navigationController?.pushViewController(statsVC, animated: true)
    }
}

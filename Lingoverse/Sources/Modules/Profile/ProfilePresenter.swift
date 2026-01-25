//
//  ProfilePresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import Foundation

struct ProfileViewModel {
    let totalXP: Int
    let currentLevel: Int
    let currentStreak: Int
    let badges: [Badge]
    let unlockedBadgesCount: Int
    let totalBadgesCount: Int
}

protocol ProfileViewOutput: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
}

@MainActor
final class ProfilePresenter: ProfileViewOutput, ProfileInteractorOutput {

    private weak var view: ProfileViewInput?
    private let interactor: ProfileInteractorInput

    init(view: ProfileViewInput, interactor: ProfileInteractorInput) {
        self.view = view
        self.interactor = interactor
    }

    func viewDidLoad() {
        // Initial setup if needed
    }

    func viewWillAppear() {
        interactor.fetchProfileData()
    }

    // MARK: - ProfileInteractorOutput

    func didLoadProfile(progress: UserProgress, badges: [Badge]) {
        let unlockedCount = badges.filter { $0.isUnlocked }.count

        let viewModel = ProfileViewModel(
            totalXP: progress.totalXP,
            currentLevel: progress.currentLevel,
            currentStreak: progress.currentStreak,
            badges: badges,
            unlockedBadgesCount: unlockedCount,
            totalBadgesCount: badges.count
        )

        view?.render(viewModel: viewModel)
    }
}

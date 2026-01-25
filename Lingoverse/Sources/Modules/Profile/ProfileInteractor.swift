//
//  ProfileInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import Foundation

protocol ProfileInteractorInput: AnyObject {
    func fetchProfileData()
}

protocol ProfileInteractorOutput: AnyObject {
    func didLoadProfile(progress: UserProgress, badges: [Badge])
}

final class ProfileInteractor: ProfileInteractorInput {

    private let gamificationService: GamificationServiceProtocol
    weak var output: ProfileInteractorOutput?

    init(gamificationService: GamificationServiceProtocol = GamificationService()) {
        self.gamificationService = gamificationService
    }

    func fetchProfileData() {
        gamificationService.checkBadges()
        output?.didLoadProfile(
            progress: gamificationService.progress,
            badges: gamificationService.badges
        )
    }
}

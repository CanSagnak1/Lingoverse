//
//  GamificationService.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 23.01.2026.
//

import Foundation

protocol GamificationServiceProtocol {
    var progress: UserProgress { get }
    var badges: [Badge] { get }

    func addXP(amount: Int)
    func updateStreak()
    func checkBadges()  // Call this periodically or after actions

    // Observables could be added here (Combine/Delegates) if needed later
}

final class GamificationService: GamificationServiceProtocol {
    private let repository: GamificationRepositoryProtocol

    private(set) var progress: UserProgress
    private(set) var badges: [Badge]

    init(repository: GamificationRepositoryProtocol = GamificationRepository()) {
        self.repository = repository
        self.progress = repository.loadProgress()
        self.badges = repository.loadBadges()
    }

    func addXP(amount: Int) {
        progress.totalXP += amount
        let newLevel = UserProgress.calculateLevel(xp: progress.totalXP)

        if newLevel > progress.currentLevel {
            // Level Up Logic could trigger an event here
            print("Level Up! \(progress.currentLevel) -> \(newLevel)")
        }

        progress.currentLevel = newLevel
        save()
        checkBadges()
    }

    func updateStreak() {
        let calendar = Calendar.current
        let now = Date()

        guard let lastDate = progress.lastActivityDate else {
            // First time activity
            progress.currentStreak = 1
            progress.longestStreak = 1
            progress.lastActivityDate = now
            save()
            checkBadges()
            return
        }

        if calendar.isDateInToday(lastDate) {
            // Already active today, do nothing
            return
        }

        if calendar.isDateInYesterday(lastDate) {
            // Active yesterday, increment streak
            progress.currentStreak += 1
            if progress.currentStreak > progress.longestStreak {
                progress.longestStreak = progress.currentStreak
            }
        } else {
            // Thread broken, reset streak
            progress.currentStreak = 1
        }

        progress.lastActivityDate = now
        save()
        checkBadges()
    }

    func checkBadges() {
        var badgesChanged = false

        for i in 0..<badges.count {
            if !badges[i].isUnlocked {
                if shouldUnlock(badge: badges[i].type) {
                    badges[i].isUnlocked = true
                    badges[i].unlockedDate = Date()
                    badgesChanged = true
                    print("Badge Unlocked: \(badges[i].type.rawValue)")
                }
            }
        }

        if badgesChanged {
            repository.saveBadges(badges)
        }
    }

    private func save() {
        repository.saveProgress(progress)
    }

    private func shouldUnlock(badge: BadgeType) -> Bool {
        switch badge {
        case .firstStep:
            return true  // Unlocked on first check (usually after first action)
        case .streak7:
            return progress.currentStreak >= 7
        case .streak30:
            return progress.currentStreak >= 30
        case .xp100:
            return progress.totalXP >= 100
        case .xp1000:
            return progress.totalXP >= 1000
        case .xp5000:
            return progress.totalXP >= 5000
        case .quizMaster:
            return false  // This needs external trigger
        }
    }
}

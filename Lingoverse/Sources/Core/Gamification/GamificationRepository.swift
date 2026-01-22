//
//  GamificationRepository.swift
//  Lingoverse
//
//  Created by Antigravity on 23.01.2026.
//

import Foundation

protocol GamificationRepositoryProtocol {
    func saveProgress(_ progress: UserProgress)
    func loadProgress() -> UserProgress

    func saveBadges(_ badges: [Badge])
    func loadBadges() -> [Badge]

    func resetProgress()  // For testing/debug
}

final class GamificationRepository: GamificationRepositoryProtocol {
    private let userDefaults: UserDefaults
    private let progressKey = "gamification_user_progress"
    private let badgesKey = "gamification_badges"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func saveProgress(_ progress: UserProgress) {
        do {
            let data = try JSONEncoder().encode(progress)
            userDefaults.set(data, forKey: progressKey)
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }

    func loadProgress() -> UserProgress {
        guard let data = userDefaults.data(forKey: progressKey) else {
            return .initial
        }

        do {
            return try JSONDecoder().decode(UserProgress.self, from: data)
        } catch {
            print("Failed to load user progress: \(error)")
            return .initial
        }
    }

    func saveBadges(_ badges: [Badge]) {
        do {
            let data = try JSONEncoder().encode(badges)
            userDefaults.set(data, forKey: badgesKey)
        } catch {
            print("Failed to save badges: \(error)")
        }
    }

    func loadBadges() -> [Badge] {
        guard let data = userDefaults.data(forKey: badgesKey) else {
            return Badge.allLocked()
        }

        do {
            let badges = try JSONDecoder().decode([Badge].self, from: data)
            // Handle case where new badges are added to the App but weren't in saved data
            // by merging saved state with all potential badges
            let savedMap = Dictionary(uniqueKeysWithValues: badges.map { ($0.type, $0) })
            return Badge.allLocked().map { defaultBadge in
                savedMap[defaultBadge.type] ?? defaultBadge
            }
        } catch {
            print("Failed to load badges: \(error)")
            return Badge.allLocked()
        }
    }

    func resetProgress() {
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.removeObject(forKey: badgesKey)
    }
}

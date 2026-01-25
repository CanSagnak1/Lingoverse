//
//  GamificationModels.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 23.01.2026.
//

import Foundation

// MARK: - Badge Type
enum BadgeType: String, Codable, CaseIterable {
    case firstStep = "first_step"  // First interaction
    case streak7 = "streak_7"  // 7 Day Streak
    case streak30 = "streak_30"  // 30 Day Streak
    case xp100 = "xp_100"  // Reach 100 XP
    case xp1000 = "xp_1000"  // Reach 1000 XP
    case xp5000 = "xp_5000"  // Reach 5000 XP
    case quizMaster = "quiz_master"  // Perfect score in a quiz

    var iconName: String {
        switch self {
        case .firstStep: return "figure.step.training"
        case .streak7: return "flame.fill"
        case .streak30: return "flame.circle.fill"
        case .xp100: return "star.fill"
        case .xp1000: return "star.circle.fill"
        case .xp5000: return "crown.fill"
        case .quizMaster: return "checkmark.seal.fill"
        }
    }
}

// MARK: - Badge Model
struct Badge: Codable, Identifiable {
    var id: String { type.rawValue }
    let type: BadgeType
    var isUnlocked: Bool
    var unlockedDate: Date?

    static func allLocked() -> [Badge] {
        return BadgeType.allCases.map { Badge(type: $0, isUnlocked: false, unlockedDate: nil) }
    }
}

// MARK: - User Progress Model
struct UserProgress: Codable {
    var totalXP: Int
    var currentLevel: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?

    // Level is calculated: Level = floor(sqrt(XP / 100)) + 1
    // Example: 0-99 XP = Lvl 1, 100-399 XP = Lvl 2, 400 XP = Lvl 3...
    static func calculateLevel(xp: Int) -> Int {
        return Int(sqrt(Double(xp) / 100.0)) + 1
    }

    static var initial: UserProgress {
        return UserProgress(
            totalXP: 0,
            currentLevel: 1,
            currentStreak: 0,
            longestStreak: 0,
            lastActivityDate: nil
        )
    }
}

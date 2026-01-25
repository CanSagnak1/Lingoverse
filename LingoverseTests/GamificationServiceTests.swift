//
//  GamificationServiceTests.swift
//  LingoverseTests
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import XCTest

@testable import Lingoverse

final class GamificationServiceTests: XCTestCase {

    var sut: GamificationService!
    var mockRepository: MockGamificationRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockGamificationRepository()
        sut = GamificationService(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - addXP Tests

    func testAddXP_ShouldIncreaseTotal() {
        let initialXP = sut.progress.totalXP
        sut.addXP(amount: 50)

        XCTAssertEqual(sut.progress.totalXP, initialXP + 50, "XP should increase by 50")
        XCTAssertTrue(mockRepository.saveProgressCalled, "Should save progress")
    }

    func testAddXP_ShouldTriggerLevelUp() {
        mockRepository.mockProgress.totalXP = 90
        sut = GamificationService(repository: mockRepository)

        sut.addXP(amount: 20)  // Now at 110 XP

        XCTAssertGreaterThan(
            sut.progress.currentLevel, 1, "Should level up when crossing threshold")
    }

    func testAddXP_ShouldCheckBadges() {
        sut.addXP(amount: 100)

        // First step badge should be unlocked
        let firstStepBadge = sut.badges.first { $0.type == .firstStep }
        XCTAssertTrue(firstStepBadge?.isUnlocked == true, "First step badge should be unlocked")
    }

    // MARK: - updateStreak Tests

    func testUpdateStreak_FirstTime_ShouldSetStreakToOne() {
        mockRepository.mockProgress.lastActivityDate = nil
        mockRepository.mockProgress.currentStreak = 0
        sut = GamificationService(repository: mockRepository)

        sut.updateStreak()

        XCTAssertEqual(sut.progress.currentStreak, 1, "First activity should set streak to 1")
    }

    func testUpdateStreak_SameDayActivity_ShouldNotChange() {
        mockRepository.mockProgress.lastActivityDate = Date()
        mockRepository.mockProgress.currentStreak = 5
        sut = GamificationService(repository: mockRepository)

        sut.updateStreak()

        XCTAssertEqual(sut.progress.currentStreak, 5, "Same day activity should not change streak")
    }

    func testUpdateStreak_YesterdayActivity_ShouldIncrement() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockRepository.mockProgress.lastActivityDate = yesterday
        mockRepository.mockProgress.currentStreak = 3
        sut = GamificationService(repository: mockRepository)

        sut.updateStreak()

        XCTAssertEqual(sut.progress.currentStreak, 4, "Yesterday activity should increment streak")
    }

    func testUpdateStreak_OldActivity_ShouldResetToOne() {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        mockRepository.mockProgress.lastActivityDate = threeDaysAgo
        mockRepository.mockProgress.currentStreak = 10
        sut = GamificationService(repository: mockRepository)

        sut.updateStreak()

        XCTAssertEqual(sut.progress.currentStreak, 1, "Old activity should reset streak to 1")
    }

    func testUpdateStreak_ShouldUpdateLongestStreak() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockRepository.mockProgress.lastActivityDate = yesterday
        mockRepository.mockProgress.currentStreak = 5
        mockRepository.mockProgress.longestStreak = 5
        sut = GamificationService(repository: mockRepository)

        sut.updateStreak()

        XCTAssertEqual(
            sut.progress.longestStreak, 6, "Should update longest streak when current exceeds it")
    }

    // MARK: - checkBadges Tests

    func testCheckBadges_XP100_ShouldUnlockApprentice() {
        mockRepository.mockProgress.totalXP = 100
        sut = GamificationService(repository: mockRepository)

        sut.checkBadges()

        let apprenticeBadge = sut.badges.first { $0.type == .xp100 }
        XCTAssertTrue(apprenticeBadge?.isUnlocked == true, "100 XP should unlock Apprentice badge")
    }

    func testCheckBadges_Streak7_ShouldUnlockWeekWarrior() {
        mockRepository.mockProgress.currentStreak = 7
        sut = GamificationService(repository: mockRepository)

        sut.checkBadges()

        let streak7Badge = sut.badges.first { $0.type == .streak7 }
        XCTAssertTrue(
            streak7Badge?.isUnlocked == true, "7 day streak should unlock Week Warrior badge")
    }

    func testCheckBadges_Streak30_ShouldUnlockMonthlyLegend() {
        mockRepository.mockProgress.currentStreak = 30
        sut = GamificationService(repository: mockRepository)

        sut.checkBadges()

        let streak30Badge = sut.badges.first { $0.type == .streak30 }
        XCTAssertTrue(
            streak30Badge?.isUnlocked == true, "30 day streak should unlock Monthly Legend badge")
    }

    func testCheckBadges_XP1000_ShouldUnlockMaster() {
        mockRepository.mockProgress.totalXP = 1000
        sut = GamificationService(repository: mockRepository)

        sut.checkBadges()

        let masterBadge = sut.badges.first { $0.type == .xp1000 }
        XCTAssertTrue(masterBadge?.isUnlocked == true, "1000 XP should unlock Master badge")
    }
}

// MARK: - Mock Repository

class MockGamificationRepository: GamificationRepositoryProtocol {
    var saveProgressCalled = false
    var saveBadgesCalled = false

    var mockProgress = UserProgress(
        totalXP: 0,
        currentLevel: 1,
        currentStreak: 0,
        longestStreak: 0,
        lastActivityDate: nil
    )

    var mockBadges: [Badge] = BadgeType.allCases.map { Badge(type: $0) }

    func loadProgress() -> UserProgress {
        return mockProgress
    }

    func saveProgress(_ progress: UserProgress) {
        saveProgressCalled = true
        mockProgress = progress
    }

    func loadBadges() -> [Badge] {
        return mockBadges
    }

    func saveBadges(_ badges: [Badge]) {
        saveBadgesCalled = true
        mockBadges = badges
    }
}

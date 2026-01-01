//
//  LearnPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol LearnViewOutput: AnyObject {
    func viewWillAppear()
    func didTapFlashcard()
    func didTapQuiz()
    func didTapStats()
}

final class LearnPresenter: LearnViewOutput {

    private weak var view: LearnViewInput?
    private let router: LearnRouterProtocol
    private let favoritesRepo: FavoritesRepository
    private let progressManager: LearnProgressManager

    private var favoriteWords: [String] = []

    init(
        view: LearnViewInput,
        router: LearnRouterProtocol,
        favoritesRepo: FavoritesRepository = FavoritesRepository(),
        progressManager: LearnProgressManager = .shared
    ) {
        self.view = view
        self.router = router
        self.favoritesRepo = favoritesRepo
        self.progressManager = progressManager
    }

    func viewWillAppear() {
        favoriteWords = favoritesRepo.fetchFavorites()

        if favoriteWords.isEmpty {
            view?.render(.empty(message: "Add words to favorites to start learning"))
        } else {
            view?.render(.ready(wordCount: favoriteWords.count))
        }
    }

    func didTapFlashcard() {
        guard !favoriteWords.isEmpty else { return }
        guard let vc = view as? UIViewController else { return }
        router.routeToFlashcard(from: vc, words: favoriteWords)
    }

    func didTapQuiz() {
        guard favoriteWords.count >= 4 else {
            guard let vc = view as? UIViewController else { return }
            HapticManager.shared.warning()
            let alert = UIAlertController(
                title: "Not Enough Words",
                message: "You need at least 4 favorite words to take a quiz.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(alert, animated: true)
            return
        }
        guard let vc = view as? UIViewController else { return }
        router.routeToQuiz(from: vc, words: favoriteWords)
    }

    func didTapStats() {
        guard let vc = view as? UIViewController else { return }
        router.routeToStats(from: vc)
    }
}

// MARK: - LearnProgressManager

final class LearnProgressManager {

    static let shared = LearnProgressManager()

    private let userDefaults: UserDefaults
    private let correctAnswersKey = "learn_correct_answers"
    private let totalQuestionsKey = "learn_total_questions"
    private let flashcardSessionsKey = "learn_flashcard_sessions"
    private let quizSessionsKey = "learn_quiz_sessions"
    private let streakDaysKey = "learn_streak_days"
    private let lastPracticeDateKey = "learn_last_practice_date"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var correctAnswers: Int {
        get { userDefaults.integer(forKey: correctAnswersKey) }
        set { userDefaults.set(newValue, forKey: correctAnswersKey) }
    }

    var totalQuestions: Int {
        get { userDefaults.integer(forKey: totalQuestionsKey) }
        set { userDefaults.set(newValue, forKey: totalQuestionsKey) }
    }

    var flashcardSessions: Int {
        get { userDefaults.integer(forKey: flashcardSessionsKey) }
        set { userDefaults.set(newValue, forKey: flashcardSessionsKey) }
    }

    var quizSessions: Int {
        get { userDefaults.integer(forKey: quizSessionsKey) }
        set { userDefaults.set(newValue, forKey: quizSessionsKey) }
    }

    var streakDays: Int {
        get { userDefaults.integer(forKey: streakDaysKey) }
        set { userDefaults.set(newValue, forKey: streakDaysKey) }
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }

    func recordFlashcardSession() {
        flashcardSessions += 1
        updateStreak()
    }

    func recordQuizAnswer(isCorrect: Bool) {
        totalQuestions += 1
        if isCorrect {
            correctAnswers += 1
        }
    }

    func recordQuizSession() {
        quizSessions += 1
        updateStreak()
    }

    private func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = userDefaults.object(forKey: lastPracticeDateKey) as? Date {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDiff =
                Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysDiff == 1 {
                streakDays += 1
            } else if daysDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        userDefaults.set(today, forKey: lastPracticeDateKey)
    }

    func resetProgress() {
        correctAnswers = 0
        totalQuestions = 0
        flashcardSessions = 0
        quizSessions = 0
        streakDays = 0
        userDefaults.removeObject(forKey: lastPracticeDateKey)
    }
}

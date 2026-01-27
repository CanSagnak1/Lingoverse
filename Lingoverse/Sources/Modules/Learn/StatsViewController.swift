//
//  StatsViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//  Redesigned by Antigravity on 25.01.2026.
//

import UIKit

final class StatsViewController: UIViewController {

    // MARK: - Managers

    private let learnProgress = LearnProgressManager.shared
    private let miniGameProgress = MiniGameProgressManager.shared
    private let gamificationService = GamificationService()

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStats()
    }

    // MARK: - Setup

    private func setupUI() {
        title = Strings.statsTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])

        buildUI()
    }

    private func refreshStats() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buildUI()
    }

    private func buildUI() {
        // 1. Overview Hero Card
        contentStack.addArrangedSubview(createOverviewHeroCard())

        // 2. Quick Stats Row
        contentStack.addArrangedSubview(createQuickStatsRow())

        // 3. Learning Section
        contentStack.addArrangedSubview(
            createSectionHeader(
                title: Strings.statsSectionLearning, subtitle: Strings.statsSectionLearningSubtitle)
        )
        contentStack.addArrangedSubview(createLearningSection())

        // 4. Mini Games Section
        contentStack.addArrangedSubview(
            createSectionHeader(
                title: Strings.statsSectionMinigames,
                subtitle: Strings.statsSectionMinigamesSubtitle))
        contentStack.addArrangedSubview(createMiniGamesSection())

        // 5. Achievements Section
        contentStack.addArrangedSubview(
            createSectionHeader(
                title: Strings.statsSectionAchievements,
                subtitle: Strings.statsSectionAchievementsSubtitle))
        contentStack.addArrangedSubview(createAchievementsSection())

        // 6. Reset Button
        contentStack.addArrangedSubview(createResetButton())
    }

    // MARK: - Overview Hero Card

    private func createOverviewHeroCard() -> UIView {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false

        // Gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            DSColor.accent.cgColor,
            DSColor.accent.withAlphaComponent(0.7).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 24

        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.layer.addSublayer(gradientLayer)
        gradientView.layer.cornerRadius = 24
        gradientView.clipsToBounds = true

        // Stats
        let totalXP = gamificationService.progress.totalXP
        let level = gamificationService.progress.currentLevel
        let streak = learnProgress.streakDays
        let totalSessions =
            learnProgress.flashcardSessions + learnProgress.quizSessions
            + miniGameProgress.totalMiniGameSessions

        // XP Label
        let xpLabel = UILabel()
        xpLabel.translatesAutoresizingMaskIntoConstraints = false
        xpLabel.text = "\(totalXP)"
        xpLabel.font = .systemFont(ofSize: 56, weight: .bold)
        xpLabel.textColor = .white

        let xpTitleLabel = UILabel()
        xpTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        xpTitleLabel.text = Strings.statsTotalXP
        xpTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        xpTitleLabel.textColor = .white.withAlphaComponent(0.8)

        // Level Badge
        let levelBadge = createHeroBadge(value: Strings.profileLevel(level), icon: "star.fill")

        // Streak Badge
        let streakBadge = createHeroBadge(
            value: Strings.profileStreakDays(streak), icon: "flame.fill")

        // Sessions Badge
        let sessionsBadge = createHeroBadge(value: "\(totalSessions)", icon: "play.circle.fill")

        let badgesStack = UIStackView(arrangedSubviews: [levelBadge, streakBadge, sessionsBadge])
        badgesStack.translatesAutoresizingMaskIntoConstraints = false
        badgesStack.axis = NSLayoutConstraint.Axis.horizontal
        badgesStack.spacing = 12
        badgesStack.distribution = UIStackView.Distribution.fillEqually

        card.addSubview(gradientView)
        gradientView.addSubview(xpLabel)
        gradientView.addSubview(xpTitleLabel)
        gradientView.addSubview(badgesStack)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 200),

            gradientView.topAnchor.constraint(equalTo: card.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            xpLabel.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 24),
            xpLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 24),

            xpTitleLabel.topAnchor.constraint(equalTo: xpLabel.bottomAnchor, constant: 4),
            xpTitleLabel.leadingAnchor.constraint(
                equalTo: gradientView.leadingAnchor, constant: 24),

            badgesStack.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16),
            badgesStack.trailingAnchor.constraint(
                equalTo: gradientView.trailingAnchor, constant: -16),
            badgesStack.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -16),
            badgesStack.heightAnchor.constraint(equalToConstant: 52),
        ])

        // Layout gradient after constraints
        DispatchQueue.main.async {
            gradientLayer.frame = gradientView.bounds
        }

        return card
    }

    private func createHeroBadge(value: String, icon: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white.withAlphaComponent(0.2)
        container.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = value
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white

        container.addSubview(iconView)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    // MARK: - Quick Stats Row

    private func createQuickStatsRow() -> UIView {
        let accuracy = learnProgress.accuracy
        let totalQuestions = learnProgress.totalQuestions
        let correctAnswers = learnProgress.correctAnswers

        let accuracyCard = createQuickStatCard(
            value: String(format: "%.0f%%", accuracy),
            title: Strings.statsQuickAccuracy,
            color: accuracy >= 70 ? .systemGreen : .systemOrange
        )

        let questionsCard = createQuickStatCard(
            value: "\(totalQuestions)",
            title: Strings.statsQuickQuestions,
            color: .systemBlue
        )

        let correctCard = createQuickStatCard(
            value: "\(correctAnswers)",
            title: Strings.statsQuickCorrect,
            color: .systemGreen
        )

        let stack = UIStackView(arrangedSubviews: [accuracyCard, questionsCard, correctCard])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually

        return stack
    }

    private func createQuickStatCard(value: String, title: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = color.withAlphaComponent(0.1)
        card.layer.cornerRadius = 16

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = DSColor.textSecondary
        titleLabel.textAlignment = .center

        card.addSubview(valueLabel)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),

            valueLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
        ])

        return card
    }

    // MARK: - Section Header

    private func createSectionHeader(title: String, subtitle: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = DSColor.textPrimary

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = DSColor.textSecondary

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        ])

        return container
    }

    // MARK: - Learning Section

    private func createLearningSection() -> UIView {
        let container = UIView()
        container.backgroundColor = DSColor.surface
        container.layer.cornerRadius = 20

        let flashcardRow = createStatRow(
            icon: "rectangle.stack.fill",
            iconColor: .systemBlue,
            title: Strings.statsRowFlashcardSessions,
            value: "\(learnProgress.flashcardSessions)"
        )

        let quizRow = createStatRow(
            icon: "questionmark.circle.fill",
            iconColor: .systemPurple,
            title: Strings.statsRowQuizSessions,
            value: "\(learnProgress.quizSessions)"
        )

        let streakRow = createStatRow(
            icon: "flame.fill",
            iconColor: .systemOrange,
            title: Strings.statsRowDailyStreak,
            value: Strings.profileStreakDays(learnProgress.streakDays)
        )

        let stack = UIStackView(arrangedSubviews: [
            flashcardRow, createDivider(), quizRow, createDivider(), streakRow,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])

        return container
    }

    // MARK: - Mini Games Section

    private func createMiniGamesSection() -> UIView {
        let container = UIView()
        container.backgroundColor = DSColor.surface
        container.layer.cornerRadius = 20

        var rows: [UIView] = []

        // Word Hunt
        if miniGameProgress.wordhuntSessions > 0 {
            rows.append(
                createGameStatRow(
                    emoji: "🎯",
                    title: Strings.wordhuntTitle,
                    sessions: miniGameProgress.wordhuntSessions,
                    bestLabel: Strings.statsGameBestScore,
                    bestValue: Strings.statsGamePoints("\(miniGameProgress.wordhuntBestScore)")
                ))
        }

        // Matching
        if miniGameProgress.matchingSessions > 0 {
            rows.append(
                createGameStatRow(
                    emoji: "🔗",
                    title: Strings.matchingTitle,
                    sessions: miniGameProgress.matchingSessions,
                    bestLabel: Strings.statsGameFewestMoves,
                    bestValue: "\(miniGameProgress.matchingBestMoves)"
                ))
        }

        // Word Chain
        if miniGameProgress.wordchainSessions > 0 {
            rows.append(
                createGameStatRow(
                    emoji: "⛓️",
                    title: Strings.wordchainTitle,
                    sessions: miniGameProgress.wordchainSessions,
                    bestLabel: Strings.statsGameLongestChain,
                    bestValue: "\(miniGameProgress.wordchainBestChain)"
                ))
        }

        // Hangman
        if miniGameProgress.hangmanSessions > 0 {
            rows.append(
                createGameStatRow(
                    emoji: "🎭",
                    title: Strings.hangmanTitle,
                    sessions: miniGameProgress.hangmanSessions,
                    bestLabel: Strings.statsGameWinRate,
                    bestValue: String(format: "%.0f%%", miniGameProgress.hangmanWinRate)
                ))
        }

        // Speed Fire
        if miniGameProgress.speedfireSessions > 0 {
            rows.append(
                createGameStatRow(
                    emoji: "⚡",
                    title: Strings.speedfireTitle,
                    sessions: miniGameProgress.speedfireSessions,
                    bestLabel: Strings.statsGameBestCombo,
                    bestValue: "\(miniGameProgress.speedfireBestCombo)x"
                ))
        }

        // Empty state
        if rows.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.text = Strings.statsEmptyMinigames
            emptyLabel.font = .systemFont(ofSize: 14)  // Assuming font size is consistent
            emptyLabel.textColor = DSColor.textSecondary
            emptyLabel.textAlignment = .center
            emptyLabel.numberOfLines = 0

            container.addSubview(emptyLabel)

            NSLayoutConstraint.activate([
                emptyLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
                emptyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                emptyLabel.trailingAnchor.constraint(
                    equalTo: container.trailingAnchor, constant: -16),
                emptyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            ])

            return container
        }

        // Add dividers between rows
        var stackItems: [UIView] = []
        for (index, row) in rows.enumerated() {
            stackItems.append(row)
            if index < rows.count - 1 {
                stackItems.append(createDivider())
            }
        }

        let stack = UIStackView(arrangedSubviews: stackItems)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 0

        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])

        return container
    }

    private func createGameStatRow(
        emoji: String, title: String, sessions: Int, bestLabel: String, bestValue: String
    ) -> UIView {
        let container = UIView()

        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 28)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = DSColor.textPrimary

        let sessionsLabel = UILabel()
        sessionsLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionsLabel.text = Strings.statsSessions(sessions)
        sessionsLabel.font = .systemFont(ofSize: 13)
        sessionsLabel.textColor = DSColor.textSecondary

        let bestStack = UIStackView()
        bestStack.translatesAutoresizingMaskIntoConstraints = false
        bestStack.axis = .vertical
        bestStack.alignment = .trailing
        bestStack.spacing = 2

        let bestValueLabel = UILabel()
        bestValueLabel.text = bestValue
        bestValueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        bestValueLabel.textColor = DSColor.accent

        let bestTitleLabel = UILabel()
        bestTitleLabel.text = bestLabel
        bestTitleLabel.font = .systemFont(ofSize: 11)
        bestTitleLabel.textColor = DSColor.textSecondary

        bestStack.addArrangedSubview(bestValueLabel)
        bestStack.addArrangedSubview(bestTitleLabel)

        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        container.addSubview(sessionsLabel)
        container.addSubview(bestStack)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 72),

            emojiLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),

            sessionsLabel.leadingAnchor.constraint(
                equalTo: emojiLabel.trailingAnchor, constant: 12),
            sessionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),

            bestStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            bestStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    // MARK: - Achievements Section

    private func createAchievementsSection() -> UIView {
        let container = UIView()
        container.backgroundColor = DSColor.surface
        container.layer.cornerRadius = 20

        var achievements: [(emoji: String, title: String, value: String)] = []

        // Best quiz accuracy
        if learnProgress.totalQuestions >= 10 {
            achievements.append(
                (
                    emoji: "🎯",
                    title: Strings.achievementQuizMaster,
                    value: Strings.achievementAccuracy(learnProgress.accuracy)
                ))
        }

        // Longest streak
        if learnProgress.streakDays >= 3 {
            achievements.append(
                (
                    emoji: "🔥",
                    title: Strings.achievementStreakRecord,
                    value: Strings.profileStreakDays(learnProgress.streakDays)
                ))
        }

        // Total mini game XP
        if miniGameProgress.totalMiniGameXP > 0 {
            achievements.append(
                (
                    emoji: "🎮",
                    title: Strings.achievementGameXP,
                    value: "\(miniGameProgress.totalMiniGameXP) XP"
                ))
        }

        // Most sessions
        if let mostPlayed = miniGameProgress.mostPlayedGame,
            miniGameProgress.totalMiniGameSessions > 0
        {
            achievements.append(
                (
                    emoji: "⭐",
                    title: Strings.achievementFavoriteGame,
                    value: mostPlayed
                ))
        }

        // Speed Fire best combo
        if miniGameProgress.speedfireBestCombo >= 3 {
            achievements.append(
                (
                    emoji: "⚡",
                    title: Strings.achievementComboMaster,
                    value: "\(miniGameProgress.speedfireBestCombo)x"
                ))
        }

        if achievements.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.text = Strings.statsEmptyAchievements
            emptyLabel.font = .systemFont(ofSize: 14)  // Assuming font size is consistent
            emptyLabel.textColor = DSColor.textSecondary
            emptyLabel.textAlignment = .center  // Alignment should be center

            container.addSubview(emptyLabel)

            NSLayoutConstraint.activate([
                emptyLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
                emptyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                emptyLabel.trailingAnchor.constraint(
                    equalTo: container.trailingAnchor, constant: -16),
                emptyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            ])

            return container
        }

        var cards: [UIView] = []
        for achievement in achievements {
            cards.append(
                createAchievementCard(
                    emoji: achievement.emoji,
                    title: achievement.title,
                    value: achievement.value
                ))
        }

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false

        let stack = UIStackView(arrangedSubviews: cards)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12

        scrollView.addSubview(stack)
        container.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            scrollView.heightAnchor.constraint(equalToConstant: 90),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])

        return container
    }

    private func createAchievementCard(emoji: String, title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        card.layer.cornerRadius = 14

        let emojiLabel = UILabel()
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.text = emoji
        emojiLabel.font = .systemFont(ofSize: 24)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = DSColor.textSecondary

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = DSColor.accent

        card.addSubview(emojiLabel)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 120),

            emojiLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
        ])

        return card
    }

    // MARK: - Helper Views

    private func createStatRow(icon: String, iconColor: UIColor, title: String, value: String)
        -> UIView
    {
        let container = UIView()

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.15)
        iconContainer.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = DSColor.textPrimary

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = DSColor.textPrimary

        container.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 56),

            iconContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        return container
    }

    private func createDivider() -> UIView {
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = DSColor.textSecondary.withAlphaComponent(0.1)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    private func createResetButton() -> UIView {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("🗑️ " + Strings.statsResetProgress, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemRed, for: .normal)
        button.backgroundColor = .systemRed.withAlphaComponent(0.1)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)

        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        return button
    }

    // MARK: - Actions

    @objc private func didTapReset() {
        HapticManager.shared.warning()

        let alert = UIAlertController(
            title: Strings.statsResetConfirmTitle,
            message: Strings.statsResetConfirmMessage,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Strings.cancelButton, style: .cancel))
        alert.addAction(
            UIAlertAction(title: Strings.statsReset, style: .destructive) { [weak self] _ in
                self?.learnProgress.resetProgress()
                self?.miniGameProgress.resetProgress()
                HapticManager.shared.success()
                self?.navigationController?.popViewController(animated: true)
            })

        present(alert, animated: true)
    }
}

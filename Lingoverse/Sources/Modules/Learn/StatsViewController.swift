//
//  StatsViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

final class StatsViewController: UIViewController {

    private let progressManager = LearnProgressManager.shared

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24
        return stack
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Progress"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    // Stats Cards
    private lazy var statsGrid: UIStackView = {
        let row1 = UIStackView(arrangedSubviews: [
            createStatCard(
                title: "Quiz Accuracy", value: String(format: "%.0f%%", progressManager.accuracy),
                icon: "target", color: .systemGreen),
            createStatCard(
                title: "Streak Days", value: "\(progressManager.streakDays)", icon: "flame.fill",
                color: .systemOrange),
        ])
        row1.axis = .horizontal
        row1.spacing = 16
        row1.distribution = .fillEqually

        let row2 = UIStackView(arrangedSubviews: [
            createStatCard(
                title: "Flashcard Sessions", value: "\(progressManager.flashcardSessions)",
                icon: "rectangle.stack.fill", color: .systemBlue),
            createStatCard(
                title: "Quiz Sessions", value: "\(progressManager.quizSessions)",
                icon: "questionmark.circle.fill", color: .systemPurple),
        ])
        row2.axis = .horizontal
        row2.spacing = 16
        row2.distribution = .fillEqually

        let row3 = UIStackView(arrangedSubviews: [
            createStatCard(
                title: "Correct Answers", value: "\(progressManager.correctAnswers)",
                icon: "checkmark.circle.fill", color: .systemGreen),
            createStatCard(
                title: "Total Questions", value: "\(progressManager.totalQuestions)",
                icon: "list.number", color: .systemGray),
        ])
        row3.axis = .horizontal
        row3.spacing = 16
        row3.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [row1, row2, row3])
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private lazy var motivationCard: UIView = {
        let card = UIView()
        card.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        card.layer.cornerRadius = 16

        let iconView = UIImageView(image: UIImage(systemName: "lightbulb.fill"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = DSColor.accent
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = getMotivationalMessage()
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textPrimary
        label.numberOfLines = 0

        card.addSubview(iconView)
        card.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }()

    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Progress", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Statistics"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        contentStack.addArrangedSubview(headerLabel)
        contentStack.addArrangedSubview(statsGrid)
        contentStack.addArrangedSubview(motivationCard)
        contentStack.addArrangedSubview(resetButton)

        contentStack.setCustomSpacing(32, after: headerLabel)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    private func createStatCard(title: String, value: String, icon: String, color: UIColor)
        -> UIView
    {
        let card = UIView()
        card.backgroundColor = DSColor.surface
        card.layer.cornerRadius = 16

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 28, weight: .bold)
        valueLabel.textColor = DSColor.textPrimary

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = DSColor.textSecondary

        card.addSubview(iconView)
        card.addSubview(valueLabel)
        card.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 120),

            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            valueLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -4),

            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    private func getMotivationalMessage() -> String {
        let accuracy = progressManager.accuracy
        let streak = progressManager.streakDays

        if streak >= 7 {
            return
                "🔥 Amazing! You've been practicing for \(streak) days straight. Keep up the great work!"
        } else if accuracy >= 80 {
            return "⭐ Excellent accuracy! You're mastering these words quickly."
        } else if progressManager.totalQuestions >= 50 {
            return
                "📚 You've answered \(progressManager.totalQuestions) questions! Practice makes perfect."
        } else if progressManager.flashcardSessions >= 5 {
            return "📖 Great job reviewing flashcards! Try the quiz to test your knowledge."
        } else {
            return "💡 Start with flashcards to learn new words, then test yourself with quizzes!"
        }
    }

    // MARK: - Actions

    @objc private func didTapReset() {
        HapticManager.shared.warning()

        let alert = UIAlertController(
            title: "Reset Progress",
            message: "This will reset all your learning statistics. This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
                self?.progressManager.resetProgress()
                HapticManager.shared.success()
                self?.navigationController?.popViewController(animated: true)
            })

        present(alert, animated: true)
    }
}

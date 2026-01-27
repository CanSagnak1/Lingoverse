//
//  LearnViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol LearnViewInput: AnyObject {
    func render(_ state: LearnState)
}

enum LearnState {
    case empty(message: String)
    case ready(wordCount: Int)
}

final class LearnViewController: UIViewController, LearnViewInput {

    var presenter: LearnViewOutput!

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var flashcardButton: LearnModeCard = {
        let button = LearnModeCard(
            title: Strings.learnFlashcards,
            subtitle: Strings.learnFlashcardsSubtitle,
            iconName: "rectangle.stack.fill",
            color: .systemBlue
        )
        button.addTarget(self, action: #selector(didTapFlashcard), for: .touchUpInside)
        return button
    }()

    private lazy var quizButton: LearnModeCard = {
        let button = LearnModeCard(
            title: Strings.learnQuiz,
            subtitle: Strings.learnQuizSubtitle,
            iconName: "questionmark.circle.fill",
            color: .systemGreen
        )
        button.addTarget(self, action: #selector(didTapQuiz), for: .touchUpInside)
        return button
    }()

    private lazy var statsButton: LearnModeCard = {
        let button = LearnModeCard(
            title: Strings.learnStatistics,
            subtitle: Strings.learnStatisticsSubtitle,
            iconName: "chart.bar.fill",
            color: .systemOrange
        )
        button.addTarget(self, action: #selector(didTapStats), for: .touchUpInside)
        return button
    }()

    private lazy var miniGamesButton: LearnModeCard = {
        let button = LearnModeCard(
            title: Strings.minigamesTitle,
            subtitle: Strings.minigamesSubtitle,
            iconName: "gamecontroller.fill",
            color: .systemPurple
        )
        button.addTarget(self, action: #selector(didTapMiniGames), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            flashcardButton, quizButton, miniGamesButton, statsButton,
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let iconView = UIImageView(image: UIImage(systemName: "star.fill"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = DSColor.accent.withAlphaComponent(0.5)
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.learnEmptyState
        label.font = .systemFont(ofSize: 17)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0

        view.addSubview(iconView)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: view.topAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        animateCardsEntrance()
    }

    private func animateCardsEntrance() {
        let cards = [flashcardButton, quizButton, miniGamesButton, statsButton]

        // Prepare for animation (start slightly lower and transparent)
        cards.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 30)
        }

        // Staggered animation
        for (index, card) in cards.enumerated() {
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.1,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut,
                animations: {
                    card.alpha = 1
                    card.transform = .identity
                }
            )
        }
    }

    private func setupUI() {
        title = Strings.learnTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always

        view.addSubview(headerView)
        headerView.addSubview(subtitleLabel)

        view.addSubview(buttonsStack)
        view.addSubview(emptyStateView)

        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            buttonsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    func render(_ state: LearnState) {
        switch state {
        case .empty(let message):
            subtitleLabel.text = message
            buttonsStack.isHidden = true
            emptyStateView.isHidden = false

        case .ready(let wordCount):
            subtitleLabel.text = Strings.learnWordsToPractice(wordCount)
            buttonsStack.isHidden = false
            emptyStateView.isHidden = true
        }
    }

    @objc private func didTapFlashcard() {
        HapticManager.shared.buttonPressed()
        presenter.didTapFlashcard()
    }

    @objc private func didTapQuiz() {
        HapticManager.shared.buttonPressed()
        presenter.didTapQuiz()
    }

    @objc private func didTapStats() {
        HapticManager.shared.buttonPressed()
        presenter.didTapStats()
    }

    @objc private func didTapMiniGames() {
        HapticManager.shared.buttonPressed()
        presenter.didTapMiniGames()
    }
}

final class LearnModeCard: UIControl {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 24
        view.isUserInteractionEnabled = false

        // Premium Card styling
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColor.textSecondary.withAlphaComponent(0.05).cgColor

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 16
        view.layer.shadowOpacity = 0.08
        return view
    }()

    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 18
        return view
    }()

    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)  // Bolder
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = DSColor.textSecondary
        return label
    }()

    private lazy var arrowView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.textSecondary.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(title: String, subtitle: String, iconName: String, color: UIColor) {
        super.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconView.image = UIImage(systemName: iconName)

        // Icon container styling
        iconContainer.backgroundColor = color.withAlphaComponent(0.15)
        iconView.tintColor = color

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(arrowView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 100),  // Taller card

            iconContainer.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 20),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),  // Larger icon
            iconContainer.heightAnchor.constraint(equalToConstant: 56),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -8),

            arrowView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -24),
            arrowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 12),
            arrowView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
                self.transform =
                    self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }
}

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

    // MARK: - UI Components

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Learn"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private lazy var flashcardButton: LearnModeButton = {
        let button = LearnModeButton(
            title: "Flashcards",
            subtitle: "Flip cards to learn definitions",
            iconName: "rectangle.stack.fill",
            color: .systemBlue
        )
        button.addTarget(self, action: #selector(didTapFlashcard), for: .touchUpInside)
        return button
    }()

    private lazy var quizButton: LearnModeButton = {
        let button = LearnModeButton(
            title: "Quiz",
            subtitle: "Test your knowledge",
            iconName: "questionmark.circle.fill",
            color: .systemGreen
        )
        button.addTarget(self, action: #selector(didTapQuiz), for: .touchUpInside)
        return button
    }()

    private lazy var statsButton: LearnModeButton = {
        let button = LearnModeButton(
            title: "Statistics",
            subtitle: "Track your progress",
            iconName: "chart.bar.fill",
            color: .systemOrange
        )
        button.addTarget(self, action: #selector(didTapStats), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [flashcardButton, quizButton, statsButton])
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
        label.text = "Add words to favorites to start learning!"
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        view.addSubview(buttonsStack)
        view.addSubview(emptyStateView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            buttonsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - LearnViewInput

    func render(_ state: LearnState) {
        switch state {
        case .empty(let message):
            subtitleLabel.text = message
            buttonsStack.isHidden = true
            emptyStateView.isHidden = false

        case .ready(let wordCount):
            subtitleLabel.text = "You have \(wordCount) words to practice"
            buttonsStack.isHidden = false
            emptyStateView.isHidden = true
        }
    }

    // MARK: - Actions

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
}

// MARK: - LearnModeButton

final class LearnModeButton: UIControl {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = DSColor.textSecondary
        return label
    }()

    private lazy var arrowView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(title: String, subtitle: String, iconName: String, color: UIColor) {
        super.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = color

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(arrowView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 80),

            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -8),

            arrowView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -20),
            arrowView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 12),
            arrowView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
                self.transform =
                    self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
}

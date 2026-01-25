//
//  GameResultView.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class GameResultView: UIView {

    // MARK: - Callbacks

    var onPlayAgain: (() -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - UI Components

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
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
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var xpContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.gamePlayAgain, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = DSColor.accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didTapPlayAgain), for: .touchUpInside)
        return button
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Strings.doneButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(DSColor.accent, for: .normal)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(xpContainer)
        xpContainer.addSubview(xpLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(playAgainButton)
        containerView.addSubview(doneButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.topAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: 60),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -32),

            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            xpContainer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
            xpContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            xpContainer.heightAnchor.constraint(equalToConstant: 40),

            xpLabel.leadingAnchor.constraint(equalTo: xpContainer.leadingAnchor, constant: 20),
            xpLabel.trailingAnchor.constraint(equalTo: xpContainer.trailingAnchor, constant: -20),
            xpLabel.centerYAnchor.constraint(equalTo: xpContainer.centerYAnchor),

            messageLabel.topAnchor.constraint(equalTo: xpContainer.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -32),

            playAgainButton.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            playAgainButton.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 32),
            playAgainButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -32),
            playAgainButton.heightAnchor.constraint(equalToConstant: 56),

            doneButton.bottomAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            doneButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Public Methods

    func configure(score: Int, xpEarned: Int, gameName: String) {
        scoreLabel.text = "\(score)"
        xpLabel.text = "+\(xpEarned) XP"

        let percentage = min(Double(score) / 100.0, 1.0) * 100

        if percentage >= 80 {
            iconView.image = UIImage(systemName: "trophy.fill")
            iconView.tintColor = .systemYellow
            titleLabel.text = Strings.gameExcellent
            messageLabel.text = Strings.gameExcellentMessage
        } else if percentage >= 50 {
            iconView.image = UIImage(systemName: "hand.thumbsup.fill")
            iconView.tintColor = DSColor.accent
            titleLabel.text = Strings.gameGreatJob
            messageLabel.text = Strings.gameGreatJobMessage
        } else {
            iconView.image = UIImage(systemName: "book.fill")
            iconView.tintColor = .systemOrange
            titleLabel.text = Strings.gameKeepTrying
            messageLabel.text = Strings.gameKeepTryingMessage
        }

        animateEntrance()
    }

    // MARK: - Private Methods

    private func animateEntrance() {
        iconView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.alpha = 0
        scoreLabel.alpha = 0
        xpContainer.alpha = 0
        messageLabel.alpha = 0
        playAgainButton.alpha = 0
        doneButton.alpha = 0

        UIView.animate(
            withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.iconView.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: 0.2) {
            self.titleLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.scoreLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.3, delay: 0.4) {
            self.xpContainer.alpha = 1
            self.messageLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.3, delay: 0.5) {
            self.playAgainButton.alpha = 1
            self.doneButton.alpha = 1
        }
    }

    @objc private func didTapPlayAgain() {
        HapticManager.shared.buttonPressed()
        onPlayAgain?()
    }

    @objc private func didTapDone() {
        HapticManager.shared.buttonPressed()
        onDismiss?()
    }
}

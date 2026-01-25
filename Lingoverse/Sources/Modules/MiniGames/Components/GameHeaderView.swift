//
//  GameHeaderView.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class GameHeaderView: UIView {

    // MARK: - Callbacks

    var onClose: (() -> Void)?

    // MARK: - UI Components

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var timerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var timerIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "timer"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.text = "00:00"
        return label
    }()

    private lazy var scoreContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var scoreIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.accent
        label.text = "0"
        return label
    }()

    // MARK: - Properties

    private var timer: Timer?
    private var remainingSeconds: Int = 0
    private var onTimeUp: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    // MARK: - Setup

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(closeButton)
        addSubview(timerContainer)
        timerContainer.addSubview(timerIcon)
        timerContainer.addSubview(timerLabel)
        addSubview(scoreContainer)
        scoreContainer.addSubview(scoreIcon)
        scoreContainer.addSubview(scoreLabel)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            timerContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerContainer.heightAnchor.constraint(equalToConstant: 36),

            timerIcon.leadingAnchor.constraint(equalTo: timerContainer.leadingAnchor, constant: 12),
            timerIcon.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor),
            timerIcon.widthAnchor.constraint(equalToConstant: 18),
            timerIcon.heightAnchor.constraint(equalToConstant: 18),

            timerLabel.leadingAnchor.constraint(equalTo: timerIcon.trailingAnchor, constant: 6),
            timerLabel.trailingAnchor.constraint(
                equalTo: timerContainer.trailingAnchor, constant: -12),
            timerLabel.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor),

            scoreContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            scoreContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            scoreContainer.heightAnchor.constraint(equalToConstant: 36),

            scoreIcon.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 12),
            scoreIcon.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),
            scoreIcon.widthAnchor.constraint(equalToConstant: 18),
            scoreIcon.heightAnchor.constraint(equalToConstant: 18),

            scoreLabel.leadingAnchor.constraint(equalTo: scoreIcon.trailingAnchor, constant: 6),
            scoreLabel.trailingAnchor.constraint(
                equalTo: scoreContainer.trailingAnchor, constant: -12),
            scoreLabel.centerYAnchor.constraint(equalTo: scoreContainer.centerYAnchor),

            heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Public Methods

    func configure(initialTime: Int, onTimeUp: @escaping () -> Void) {
        self.remainingSeconds = initialTime
        self.onTimeUp = onTimeUp
        updateTimerDisplay()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateScore(_ score: Int) {
        scoreLabel.text = "\(score)"

        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.scoreContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        ) { _ in
            UIView.animate(withDuration: 0.15) {
                self.scoreContainer.transform = .identity
            }
        }
    }

    func hideTimer() {
        timerContainer.isHidden = true
    }

    func hideScore() {
        scoreContainer.isHidden = true
    }

    // MARK: - Private Methods

    private func tick() {
        remainingSeconds -= 1
        updateTimerDisplay()

        if remainingSeconds <= 10 {
            timerLabel.textColor = .systemRed
            pulseTimer()
        }

        if remainingSeconds <= 0 {
            stopTimer()
            onTimeUp?()
        }
    }

    private func updateTimerDisplay() {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func pulseTimer() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.timerContainer.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.timerContainer.transform = .identity
            }
        }
    }

    @objc private func didTapClose() {
        HapticManager.shared.buttonPressed()
        onClose?()
    }
}

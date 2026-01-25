//
//  WordChainViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class WordChainViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol
    private var wordPool: Set<String>
    private var chain: [String] = []
    private var currentLetter: Character = "A"
    private var score = 0
    private var timePerTurn = 15
    private var remainingTime = 15

    private var timer: Timer?

    // MARK: - UI Components

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .right
        return label
    }()

    private lazy var chainLengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var chainScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private lazy var chainStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private lazy var promptCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var letterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 72, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 24, weight: .semibold)
        tf.textColor = DSColor.textPrimary
        tf.textAlignment = .center
        tf.placeholder = "Type a word..."
        tf.backgroundColor = DSColor.surface
        tf.layer.cornerRadius = 14
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.delegate = self
        return tf
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = DSColor.accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return button
    }()

    private lazy var hintButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("💡 \(Strings.wordchainHint)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(DSColor.accent, for: .normal)
        button.addTarget(self, action: #selector(didTapHint), for: .touchUpInside)
        return button
    }()

    private lazy var resultView: GameResultView = {
        let view = GameResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onDismiss = { [weak self] in self?.dismiss(animated: true) }
        view.onPlayAgain = { [weak self] in self?.restartGame() }
        return view
    }()

    // MARK: - Initialization

    init(words: [String], gamificationService: GamificationServiceProtocol = GamificationService())
    {
        self.words = words
        self.wordPool = Set(words.map { $0.lowercased() })
        self.gamificationService = gamificationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startGame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textField.becomeFirstResponder()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(scoreLabel)
        view.addSubview(chainLengthLabel)
        view.addSubview(chainScrollView)
        chainScrollView.addSubview(chainStack)
        view.addSubview(promptCard)
        promptCard.addSubview(promptLabel)
        promptCard.addSubview(letterLabel)
        promptCard.addSubview(timerLabel)
        view.addSubview(textField)
        view.addSubview(submitButton)
        view.addSubview(hintButton)
        view.addSubview(resultView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            scoreLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            chainLengthLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 16),
            chainLengthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            chainScrollView.topAnchor.constraint(
                equalTo: chainLengthLabel.bottomAnchor, constant: 12),
            chainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chainScrollView.heightAnchor.constraint(equalToConstant: 44),

            chainStack.topAnchor.constraint(equalTo: chainScrollView.topAnchor),
            chainStack.leadingAnchor.constraint(equalTo: chainScrollView.leadingAnchor),
            chainStack.trailingAnchor.constraint(equalTo: chainScrollView.trailingAnchor),
            chainStack.bottomAnchor.constraint(equalTo: chainScrollView.bottomAnchor),
            chainStack.heightAnchor.constraint(equalTo: chainScrollView.heightAnchor),

            promptCard.topAnchor.constraint(equalTo: chainScrollView.bottomAnchor, constant: 24),
            promptCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptCard.heightAnchor.constraint(equalToConstant: 180),

            promptLabel.topAnchor.constraint(equalTo: promptCard.topAnchor, constant: 20),
            promptLabel.centerXAnchor.constraint(equalTo: promptCard.centerXAnchor),

            letterLabel.centerXAnchor.constraint(equalTo: promptCard.centerXAnchor),
            letterLabel.centerYAnchor.constraint(equalTo: promptCard.centerYAnchor),

            timerLabel.bottomAnchor.constraint(equalTo: promptCard.bottomAnchor, constant: -20),
            timerLabel.centerXAnchor.constraint(equalTo: promptCard.centerXAnchor),

            textField.topAnchor.constraint(equalTo: promptCard.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 56),

            submitButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 56),

            hintButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 12),
            hintButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func startGame() {
        // Pick a starting word
        if let startWord = words.randomElement() {
            chain.append(startWord.lowercased())
            currentLetter = startWord.uppercased().last ?? "A"
            wordPool.remove(startWord.lowercased())
        }

        updateUI()
        startTurnTimer()
    }

    private func startTurnTimer() {
        remainingTime = timePerTurn
        updateTimerDisplay()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }

    private func tickTimer() {
        remainingTime -= 1
        updateTimerDisplay()

        if remainingTime <= 5 {
            timerLabel.textColor = .systemRed
            pulseTimer()
        }

        if remainingTime <= 0 {
            endGame()
        }
    }

    private func updateTimerDisplay() {
        timerLabel.text = "⏱ \(remainingTime)s"
        if remainingTime > 5 {
            timerLabel.textColor = DSColor.textPrimary
        }
    }

    private func pulseTimer() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.timerLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.timerLabel.transform = .identity
            }
        }
    }

    private func updateUI() {
        scoreLabel.text = Strings.gameScore(score)
        chainLengthLabel.text = Strings.wordchainChainLength(chain.count)
        promptLabel.text = Strings.wordchainLastLetter(String(currentLetter))
        letterLabel.text = String(currentLetter)

        // Update chain display
        chainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, word) in chain.suffix(5).enumerated() {
            let label = createChainWordLabel(word)
            chainStack.addArrangedSubview(label)

            if index < chain.suffix(5).count - 1 {
                let arrow = UILabel()
                arrow.text = "→"
                arrow.textColor = DSColor.textSecondary
                arrow.font = .systemFont(ofSize: 16)
                chainStack.addArrangedSubview(arrow)
            }
        }

        // Scroll to end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let rightOffset = CGPoint(
                x: max(
                    0, self.chainScrollView.contentSize.width - self.chainScrollView.bounds.width),
                y: 0
            )
            self.chainScrollView.setContentOffset(rightOffset, animated: true)
        }
    }

    private func createChainWordLabel(_ word: String) -> UILabel {
        let label = PaddedLabel()
        label.text = word.capitalized
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textPrimary
        label.backgroundColor = DSColor.surface
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        timer?.invalidate()
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    @objc private func didTapSubmit() {
        guard let input = textField.text?.lowercased().trimmingCharacters(in: .whitespaces),
            !input.isEmpty
        else { return }

        if validateWord(input) {
            // Correct!
            chain.append(input)
            currentLetter = input.uppercased().last ?? "A"
            wordPool.remove(input)

            let bonus = wordPool.contains(input) ? 15 : 10
            score += bonus

            HapticManager.shared.success()
            textField.text = ""

            updateUI()
            startTurnTimer()
        } else {
            // Wrong
            HapticManager.shared.error()
            shakeTextField()
        }
    }

    private func validateWord(_ word: String) -> Bool {
        // Must start with current letter
        guard let firstChar = word.uppercased().first, firstChar == currentLetter else {
            return false
        }

        // Must not be already used
        guard !chain.contains(word) else {
            return false
        }

        // Must be at least 2 characters
        guard word.count >= 2 else {
            return false
        }

        return true
    }

    @objc private func didTapHint() {
        // Show a word from pool that starts with current letter
        let matching = wordPool.filter { $0.uppercased().first == currentLetter }
        if let hint = matching.randomElement() {
            let firstTwo = String(hint.prefix(2))
            textField.text = firstTwo
            HapticManager.shared.lightTap()
        }
    }

    private func shakeTextField() {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.values = [-10, 10, -8, 8, -5, 5, 0]
        shake.duration = 0.4
        textField.layer.add(shake, forKey: "shake")
    }

    private func endGame() {
        timer?.invalidate()
        textField.resignFirstResponder()

        let xpEarned = score / 2
        if xpEarned > 0 {
            gamificationService.addXP(amount: xpEarned)
            gamificationService.updateStreak()
        }

        // Record stats
        MiniGameProgressManager.shared.recordWordchainSession(chainLength: chain.count)
        MiniGameProgressManager.shared.addMiniGameXP(xpEarned)

        resultView.configure(score: score, xpEarned: xpEarned, gameName: Strings.wordchainTitle)
        resultView.isHidden = false
        HapticManager.shared.success()
    }

    private func restartGame() {
        resultView.isHidden = true
        score = 0
        chain.removeAll()
        wordPool = Set(words.map { $0.lowercased() })
        textField.text = ""
        startGame()
        textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension WordChainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSubmit()
        return true
    }
}

// MARK: - Padded Label

private final class PaddedLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + 16, height: size.height + 8)
    }
}

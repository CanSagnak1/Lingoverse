//
//  HangmanViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class HangmanViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol
    private let client = WordKitClientLive()

    private var currentWord = ""
    private var currentHint = ""
    private var guessedLetters: Set<Character> = []
    private var wrongGuesses = 0
    private let maxWrong = 6
    private var score = 0
    private var wordsCompleted = 0

    // MARK: - UI Components

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var livesStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var hangmanView: HangmanFigureView = {
        let view = HangmanFigureView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var keyboardStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = DSColor.accent
        return indicator
    }()

    private lazy var resultView: GameResultView = {
        let view = GameResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onDismiss = { [weak self] in self?.dismiss(animated: true) }
        view.onPlayAgain = { [weak self] in self?.restartGame() }
        return view
    }()

    private var letterButtons: [UIButton] = []

    // MARK: - Initialization

    init(words: [String], gamificationService: GamificationServiceProtocol = GamificationService())
    {
        self.words = words
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
        setupKeyboard()
        loadNewWord()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(livesStack)
        view.addSubview(hangmanView)
        view.addSubview(wordLabel)
        view.addSubview(hintLabel)
        view.addSubview(keyboardStack)
        view.addSubview(loadingIndicator)
        view.addSubview(resultView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            livesStack.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            livesStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            livesStack.heightAnchor.constraint(equalToConstant: 24),

            hangmanView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            hangmanView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hangmanView.widthAnchor.constraint(equalToConstant: 150),
            hangmanView.heightAnchor.constraint(equalToConstant: 180),

            wordLabel.topAnchor.constraint(equalTo: hangmanView.bottomAnchor, constant: 24),
            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            hintLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 12),
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            keyboardStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            keyboardStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            keyboardStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            keyboardStack.heightAnchor.constraint(equalToConstant: 160),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        updateLivesDisplay()
    }

    private func setupKeyboard() {
        let rows = [
            "QWERTYUIOP",
            "ASDFGHJKL",
            "ZXCVBNM",
        ]

        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            for char in row {
                let button = createLetterButton(char)
                letterButtons.append(button)
                rowStack.addArrangedSubview(button)
            }

            keyboardStack.addArrangedSubview(rowStack)
        }
    }

    private func createLetterButton(_ letter: Character) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(String(letter), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = DSColor.surface
        button.setTitleColor(DSColor.textPrimary, for: .normal)
        button.layer.cornerRadius = 8
        button.tag = Int(letter.asciiValue ?? 0)
        button.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
        return button
    }

    private func loadNewWord() {
        loadingIndicator.startAnimating()
        keyboardStack.isHidden = true

        guard let word = words.randomElement() else {
            endGame()
            return
        }

        Task {
            var hint = "Guess the word!"

            do {
                let results = try await client.search(
                    query: word, sourceLang: "en", targetLang: "en", page: nil)
                if let firstWord = results.first,
                    let firstMeaning = firstWord.meanings.first,
                    let firstDef = firstMeaning.definitions.first
                {
                    hint = String(firstDef.definition.prefix(60))
                }
            } catch {
                // Use default hint
            }

            await MainActor.run {
                self.currentWord = word.uppercased()
                self.currentHint = hint
                self.guessedLetters.removeAll()
                self.wrongGuesses = 0

                resetKeyboard()
                updateUI()
                hangmanView.reset()
                updateLivesDisplay()

                loadingIndicator.stopAnimating()
                keyboardStack.isHidden = false
            }
        }
    }

    private func resetKeyboard() {
        for button in letterButtons {
            button.isEnabled = true
            button.backgroundColor = DSColor.surface
            button.setTitleColor(DSColor.textPrimary, for: .normal)
        }
    }

    private func updateUI() {
        var displayWord = ""
        for char in currentWord {
            if char == " " {
                displayWord += "  "
            } else if guessedLetters.contains(char) {
                displayWord += "\(char) "
            } else {
                displayWord += "_ "
            }
        }
        wordLabel.text = displayWord.trimmingCharacters(in: .whitespaces)
        hintLabel.text = Strings.hangmanHint(currentHint)
    }

    private func updateLivesDisplay() {
        livesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for i in 0..<maxWrong {
            let heart = UIImageView()
            heart.contentMode = .scaleAspectFit
            if i < (maxWrong - wrongGuesses) {
                heart.image = UIImage(systemName: "heart.fill")
                heart.tintColor = .systemRed
            } else {
                heart.image = UIImage(systemName: "heart")
                heart.tintColor = DSColor.textSecondary
            }
            livesStack.addArrangedSubview(heart)
        }
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    @objc private func letterTapped(_ sender: UIButton) {
        guard let asciiValue = UInt8(exactly: sender.tag),
            let letter = Character(UnicodeScalar(asciiValue)) as Character?
        else { return }

        sender.isEnabled = false
        guessedLetters.insert(letter)

        if currentWord.contains(letter) {
            // Correct!
            sender.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            sender.setTitleColor(.systemGreen, for: .normal)
            HapticManager.shared.success()

            updateUI()

            // Check if won
            if isWordComplete() {
                wordWon()
            }
        } else {
            // Wrong!
            sender.backgroundColor = UIColor.systemRed.withAlphaComponent(0.3)
            sender.setTitleColor(.systemRed, for: .normal)
            wrongGuesses += 1
            hangmanView.showStep(wrongGuesses)
            updateLivesDisplay()
            HapticManager.shared.error()

            if wrongGuesses >= maxWrong {
                wordLost()
            }
        }
    }

    private func isWordComplete() -> Bool {
        for char in currentWord where char != " " {
            if !guessedLetters.contains(char) {
                return false
            }
        }
        return true
    }

    private func wordWon() {
        score += 50
        wordsCompleted += 1

        // Record win
        MiniGameProgressManager.shared.recordHangmanSession(won: true)

        // Show success briefly then load new word
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.wordsCompleted >= 3 {
                self.endGame()
            } else {
                self.loadNewWord()
            }
        }
    }

    private func wordLost() {
        // Record loss
        MiniGameProgressManager.shared.recordHangmanSession(won: false)

        // Reveal word
        for char in currentWord {
            guessedLetters.insert(char)
        }
        updateUI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.endGame()
        }
    }

    private func endGame() {
        let xpEarned = score / 2
        if xpEarned > 0 {
            gamificationService.addXP(amount: xpEarned)
            gamificationService.updateStreak()
        }

        // Record XP
        MiniGameProgressManager.shared.addMiniGameXP(xpEarned)

        resultView.configure(score: score, xpEarned: xpEarned, gameName: Strings.hangmanTitle)
        resultView.isHidden = false
        HapticManager.shared.success()
    }

    private func restartGame() {
        resultView.isHidden = true
        score = 0
        wordsCompleted = 0
        loadNewWord()
    }
}

// MARK: - Hangman Figure View

private final class HangmanFigureView: UIView {

    private var currentStep = 0

    private lazy var gallowsLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.textSecondary.cgColor
        layer.lineWidth = 4
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        return layer
    }()

    private lazy var headLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.fillColor = UIColor.clear.cgColor
        layer.isHidden = true
        return layer
    }()

    private lazy var bodyLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()

    private lazy var leftArmLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()

    private lazy var rightArmLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()

    private lazy var leftLegLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()

    private lazy var rightLegLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = DSColor.accent.cgColor
        layer.lineWidth = 3
        layer.lineCap = .round
        layer.isHidden = true
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupLayers() {
        layer.addSublayer(gallowsLayer)
        layer.addSublayer(headLayer)
        layer.addSublayer(bodyLayer)
        layer.addSublayer(leftArmLayer)
        layer.addSublayer(rightArmLayer)
        layer.addSublayer(leftLegLayer)
        layer.addSublayer(rightLegLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawGallows()
        drawFigure()
    }

    private func drawGallows() {
        let path = UIBezierPath()
        // Base
        path.move(to: CGPoint(x: 20, y: bounds.height - 10))
        path.addLine(to: CGPoint(x: 80, y: bounds.height - 10))
        // Pole
        path.move(to: CGPoint(x: 50, y: bounds.height - 10))
        path.addLine(to: CGPoint(x: 50, y: 20))
        // Top
        path.addLine(to: CGPoint(x: 100, y: 20))
        // Rope
        path.addLine(to: CGPoint(x: 100, y: 40))

        gallowsLayer.path = path.cgPath
    }

    private func drawFigure() {
        let centerX: CGFloat = 100

        // Head
        let headPath = UIBezierPath(
            arcCenter: CGPoint(x: centerX, y: 55),
            radius: 15, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        headLayer.path = headPath.cgPath

        // Body
        let bodyPath = UIBezierPath()
        bodyPath.move(to: CGPoint(x: centerX, y: 70))
        bodyPath.addLine(to: CGPoint(x: centerX, y: 110))
        bodyLayer.path = bodyPath.cgPath

        // Left Arm
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x: centerX, y: 80))
        leftArmPath.addLine(to: CGPoint(x: centerX - 25, y: 100))
        leftArmLayer.path = leftArmPath.cgPath

        // Right Arm
        let rightArmPath = UIBezierPath()
        rightArmPath.move(to: CGPoint(x: centerX, y: 80))
        rightArmPath.addLine(to: CGPoint(x: centerX + 25, y: 100))
        rightArmLayer.path = rightArmPath.cgPath

        // Left Leg
        let leftLegPath = UIBezierPath()
        leftLegPath.move(to: CGPoint(x: centerX, y: 110))
        leftLegPath.addLine(to: CGPoint(x: centerX - 20, y: 145))
        leftLegLayer.path = leftLegPath.cgPath

        // Right Leg
        let rightLegPath = UIBezierPath()
        rightLegPath.move(to: CGPoint(x: centerX, y: 110))
        rightLegPath.addLine(to: CGPoint(x: centerX + 20, y: 145))
        rightLegLayer.path = rightLegPath.cgPath
    }

    func showStep(_ step: Int) {
        currentStep = step

        let layers = [
            headLayer, bodyLayer, leftArmLayer, rightArmLayer, leftLegLayer, rightLegLayer,
        ]

        for (index, layer) in layers.enumerated() {
            layer.isHidden = index >= step
        }
    }

    func reset() {
        currentStep = 0
        [headLayer, bodyLayer, leftArmLayer, rightArmLayer, leftLegLayer, rightLegLayer].forEach {
            $0.isHidden = true
        }
    }
}

//
//  SpeedFireViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class SpeedFireViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol
    private let client = WordKitClientLive()

    private var questions: [SpeedQuestion] = []
    private var currentIndex = 0
    private var score = 0
    private var combo = 0
    private var maxCombo = 0
    private var correctCount = 0
    private var remainingTime = 60

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

    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .right
        return label
    }()

    private lazy var comboContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemOrange.withAlphaComponent(0.15)
        view.layer.cornerRadius = 16
        view.isHidden = true
        return view
    }()

    private lazy var comboLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()

    private lazy var questionCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.speedfireIsThisCorrect
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var trueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✓ \(Strings.speedfireTrue)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        // Game Show Button Shadow
        button.layer.shadowColor = UIColor.systemGreen.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.addTarget(self, action: #selector(didTapTrue), for: .touchUpInside)
        return button
    }()

    private lazy var falseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✗ \(Strings.speedfireFalse)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        // Game Show Button Shadow
        button.layer.shadowColor = UIColor.systemRed.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.4
        button.addTarget(self, action: #selector(didTapFalse), for: .touchUpInside)
        return button
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

    // MARK: - Initialization

    init(words: [String], gamificationService: GamificationServiceProtocol = GamificationService())
    {
        self.words = words
        self.gamificationService = gamificationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(timerLabel)
        view.addSubview(scoreLabel)
        view.addSubview(comboContainer)
        comboContainer.addSubview(comboLabel)
        view.addSubview(questionCard)
        questionCard.addSubview(promptLabel)
        questionCard.addSubview(wordLabel)
        questionCard.addSubview(definitionLabel)
        view.addSubview(buttonsStack)
        buttonsStack.addArrangedSubview(falseButton)
        buttonsStack.addArrangedSubview(trueButton)
        view.addSubview(loadingIndicator)
        view.addSubview(resultView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            timerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scoreLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            comboContainer.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            comboContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            comboContainer.heightAnchor.constraint(equalToConstant: 32),

            comboLabel.leadingAnchor.constraint(
                equalTo: comboContainer.leadingAnchor, constant: 16),
            comboLabel.trailingAnchor.constraint(
                equalTo: comboContainer.trailingAnchor, constant: -16),
            comboLabel.centerYAnchor.constraint(equalTo: comboContainer.centerYAnchor),

            questionCard.topAnchor.constraint(equalTo: comboContainer.bottomAnchor, constant: 24),
            questionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionCard.heightAnchor.constraint(equalToConstant: 220),

            promptLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 24),
            promptLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(
                equalTo: questionCard.trailingAnchor, constant: -20),

            wordLabel.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 16),
            wordLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(
                equalTo: questionCard.trailingAnchor, constant: -20),

            definitionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 16),
            definitionLabel.leadingAnchor.constraint(
                equalTo: questionCard.leadingAnchor, constant: 20),
            definitionLabel.trailingAnchor.constraint(
                equalTo: questionCard.trailingAnchor, constant: -20),

            buttonsStack.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 32),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStack.heightAnchor.constraint(equalToConstant: 70),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        updateUI()
    }

    private func loadQuestions() {
        loadingIndicator.startAnimating()
        questionCard.isHidden = true
        buttonsStack.isHidden = true

        Task {
            var loadedQuestions: [SpeedQuestion] = []

            for word in words.shuffled().prefix(20) {
                do {
                    let results = try await client.search(
                        query: word, sourceLang: "en", targetLang: "en", page: nil)
                    if let firstWord = results.first,
                        let firstMeaning = firstWord.meanings.first,
                        let firstDef = firstMeaning.definitions.first
                    {

                        let correctDef = String(firstDef.definition.prefix(80))

                        // Create correct question
                        loadedQuestions.append(
                            SpeedQuestion(
                                word: word.capitalized, definition: correctDef, isCorrect: true)
                        )

                        // Maybe create a wrong question (mix definitions)
                        if let otherWord = words.filter({ $0 != word }).randomElement(),
                            loadedQuestions.count < 15
                        {
                            loadedQuestions.append(
                                SpeedQuestion(
                                    word: otherWord.capitalized, definition: correctDef,
                                    isCorrect: false)
                            )
                        }
                    }
                } catch {
                    // Skip
                }
            }

            await MainActor.run {
                self.questions = loadedQuestions.shuffled()
                self.loadingIndicator.stopAnimating()
                self.questionCard.isHidden = false
                self.buttonsStack.isHidden = false
                self.showCurrentQuestion()
                self.startTimer()
            }
        }
    }

    private func showCurrentQuestion() {
        guard currentIndex < questions.count else {
            endGame()
            return
        }

        let question = questions[currentIndex]
        wordLabel.text = "\"\(question.word)\""
        definitionLabel.text = question.definition

        // Animate in
        questionCard.alpha = 0
        questionCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2) {
            self.questionCard.alpha = 1
            self.questionCard.transform = .identity
        }
    }

    private func startTimer() {
        remainingTime = 60
        updateTimerDisplay()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tickTimer()
        }
    }

    private func tickTimer() {
        remainingTime -= 1
        updateTimerDisplay()

        if remainingTime <= 10 {
            timerLabel.textColor = .systemRed
        }

        if remainingTime <= 0 {
            endGame()
        }
    }

    private func updateTimerDisplay() {
        timerLabel.text = "⏱ \(remainingTime)s"
    }

    private func updateUI() {
        scoreLabel.text = Strings.gameScore(score)

        if combo >= 2 {
            comboContainer.isHidden = false
            comboLabel.text = "🔥 \(Strings.speedfireCombo(combo))"

            UIView.animate(
                withDuration: 0.15,
                animations: {
                    self.comboContainer.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            ) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.comboContainer.transform = .identity
                }
            }
        } else {
            comboContainer.isHidden = true
        }
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        timer?.invalidate()
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    @objc private func didTapTrue() {
        answer(true)
    }

    @objc private func didTapFalse() {
        answer(false)
    }

    private func answer(_ userAnswer: Bool) {
        guard currentIndex < questions.count else { return }

        let question = questions[currentIndex]
        let isCorrect = (userAnswer == question.isCorrect)

        if isCorrect {
            combo += 1
            maxCombo = max(maxCombo, combo)
            correctCount += 1
            let points = 10 * min(combo, 5)  // Max 5x multiplier
            score += points
            HapticManager.shared.success()

            flashCard(color: .systemGreen)
        } else {
            combo = 0
            HapticManager.shared.error()

            flashCard(color: .systemRed)
        }

        updateUI()

        currentIndex += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showCurrentQuestion()
        }
    }

    private func flashCard(color: UIColor) {
        let originalBg = DSColor.surface

        // Instant visual feedback
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.questionCard.backgroundColor = color.withAlphaComponent(0.3)
                self.questionCard.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }
        ) { _ in
            UIView.animate(withDuration: 0.2) {
                self.questionCard.backgroundColor = originalBg
                self.questionCard.transform = .identity
            }
        }
    }

    private func endGame() {
        timer?.invalidate()

        let xpEarned = score / 2
        if xpEarned > 0 {
            gamificationService.addXP(amount: xpEarned)
            gamificationService.updateStreak()
        }

        // Record stats
        MiniGameProgressManager.shared.recordSpeedfireSession(
            score: score, maxCombo: maxCombo, correct: correctCount)
        MiniGameProgressManager.shared.addMiniGameXP(xpEarned)

        resultView.configure(score: score, xpEarned: xpEarned, gameName: Strings.speedfireTitle)
        resultView.isHidden = false
        HapticManager.shared.success()
    }

    private func restartGame() {
        resultView.isHidden = true
        score = 0
        combo = 0
        correctCount = 0
        currentIndex = 0
        timerLabel.textColor = DSColor.textPrimary
        updateUI()
        questions.shuffle()
        showCurrentQuestion()
        startTimer()
    }
}

// MARK: - Models

private struct SpeedQuestion {
    let word: String
    let definition: String
    let isCorrect: Bool
}

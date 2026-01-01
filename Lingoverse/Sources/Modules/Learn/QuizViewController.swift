//
//  QuizViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

final class QuizViewController: UIViewController {

    private let words: [String]
    private var currentIndex = 0
    private var score = 0
    private var questions: [QuizQuestion] = []
    private var cachedDefinitions: [String: String] = [:]

    private let client = WordKitClientLive()

    // MARK: - UI Components

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .default)
        pv.translatesAutoresizingMaskIntoConstraints = false
        pv.progressTintColor = DSColor.accent
        pv.trackTintColor = DSColor.surface
        pv.layer.cornerRadius = 4
        pv.clipsToBounds = true
        return pv
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = DSColor.accent
        label.textAlignment = .right
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

    private lazy var questionTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "What does this word mean?"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
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

    private lazy var answersStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private var answerButtons: [QuizAnswerButton] = []

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = DSColor.accent
        return indicator
    }()

    private lazy var resultView: QuizResultView = {
        let view = QuizResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onDismiss = { [weak self] in
            self?.dismiss(animated: true)
        }
        view.onPlayAgain = { [weak self] in
            self?.restartQuiz()
        }
        return view
    }()

    // MARK: - Init

    init(words: [String]) {
        self.words = Array(words.shuffled().prefix(10))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateQuestions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(progressView)
        view.addSubview(scoreLabel)
        view.addSubview(questionCard)
        questionCard.addSubview(questionTypeLabel)
        questionCard.addSubview(wordLabel)
        questionCard.addSubview(loadingIndicator)
        view.addSubview(answersStack)
        view.addSubview(resultView)

        // Create 4 answer buttons
        for i in 0..<4 {
            let button = QuizAnswerButton()
            button.tag = i
            button.addTarget(self, action: #selector(didTapAnswer(_:)), for: .touchUpInside)
            answerButtons.append(button)
            answersStack.addArrangedSubview(button)
        }

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            scoreLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            progressView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            questionCard.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 32),
            questionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionCard.heightAnchor.constraint(equalToConstant: 180),

            questionTypeLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 24),
            questionTypeLabel.leadingAnchor.constraint(
                equalTo: questionCard.leadingAnchor, constant: 20),
            questionTypeLabel.trailingAnchor.constraint(
                equalTo: questionCard.trailingAnchor, constant: -20),

            wordLabel.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: questionCard.centerYAnchor, constant: 10),
            wordLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            wordLabel.trailingAnchor.constraint(
                equalTo: questionCard.trailingAnchor, constant: -20),

            loadingIndicator.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: questionCard.centerYAnchor),

            answersStack.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 32),
            answersStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answersStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            answersStack.bottomAnchor.constraint(
                lessThanOrEqualTo: safeArea.bottomAnchor, constant: -20),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        updateUI()
    }

    // MARK: - Question Generation

    private func generateQuestions() {
        loadingIndicator.startAnimating()
        wordLabel.isHidden = true
        answersStack.isHidden = true

        Task {
            // Load definitions for all words
            for word in words {
                do {
                    let results = try await client.search(
                        query: word, sourceLang: "en", targetLang: "en", page: nil)
                    if let firstWord = results.first,
                        let firstMeaning = firstWord.meanings.first,
                        let firstDef = firstMeaning.definitions.first
                    {
                        cachedDefinitions[word] = firstDef.definition
                    }
                } catch {
                    cachedDefinitions[word] = "Definition not available"
                }
            }

            await MainActor.run {
                createQuestions()
                loadingIndicator.stopAnimating()
                wordLabel.isHidden = false
                answersStack.isHidden = false
                showCurrentQuestion()
            }
        }
    }

    private func createQuestions() {
        let wordsWithDefs = cachedDefinitions.filter { $0.value != "Definition not available" }
        let validWords = Array(wordsWithDefs.keys)

        guard validWords.count >= 4 else {
            showError("Not enough words with definitions")
            return
        }

        for word in validWords.prefix(10) {
            let correctAnswer = cachedDefinitions[word] ?? ""
            var wrongAnswers = wordsWithDefs.filter { $0.key != word }.values.shuffled().prefix(3)

            var allAnswers = [correctAnswer] + Array(wrongAnswers)
            allAnswers.shuffle()

            let correctIndex = allAnswers.firstIndex(of: correctAnswer) ?? 0

            questions.append(
                QuizQuestion(
                    word: word,
                    answers: allAnswers,
                    correctIndex: correctIndex
                ))
        }
    }

    private func showCurrentQuestion() {
        guard currentIndex < questions.count else {
            showResults()
            return
        }

        let question = questions[currentIndex]
        wordLabel.text = question.word.capitalized

        for (index, button) in answerButtons.enumerated() {
            if index < question.answers.count {
                button.configure(text: question.answers[index], index: index)
                button.reset()
                button.isHidden = false
            } else {
                button.isHidden = true
            }
        }

        updateUI()
    }

    private func updateUI() {
        let progress = Float(currentIndex) / Float(max(questions.count, 1))
        progressView.setProgress(progress, animated: true)
        scoreLabel.text = "Score: \(score)"
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true)
            })
        present(alert, animated: true)
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    @objc private func didTapAnswer(_ sender: QuizAnswerButton) {
        guard currentIndex < questions.count else { return }

        let question = questions[currentIndex]
        let isCorrect = sender.tag == question.correctIndex

        // Record answer
        LearnProgressManager.shared.recordQuizAnswer(isCorrect: isCorrect)

        if isCorrect {
            score += 1
            HapticManager.shared.success()
            sender.showCorrect()
        } else {
            HapticManager.shared.error()
            sender.showWrong()
            answerButtons[question.correctIndex].showCorrect()
        }

        // Disable all buttons
        answerButtons.forEach { $0.isUserInteractionEnabled = false }

        // Move to next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.currentIndex += 1
            self.answerButtons.forEach { $0.isUserInteractionEnabled = true }
            self.showCurrentQuestion()
        }
    }

    private func showResults() {
        LearnProgressManager.shared.recordQuizSession()

        HapticManager.shared.success()
        resultView.configure(score: score, total: questions.count)
        resultView.isHidden = false

        UIView.animate(withDuration: 0.3) {
            self.resultView.alpha = 1
        }
    }

    private func restartQuiz() {
        currentIndex = 0
        score = 0
        questions.shuffle()
        resultView.isHidden = true
        showCurrentQuestion()
    }
}

// MARK: - QuizQuestion

struct QuizQuestion {
    let word: String
    let answers: [String]
    let correctIndex: Int
}

// MARK: - QuizAnswerButton

final class QuizAnswerButton: UIControl {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = DSColor.accent
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textPrimary
        label.numberOfLines = 3
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(indexLabel)
        containerView.addSubview(textLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            indexLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            indexLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: 24),
            indexLabel.heightAnchor.constraint(equalToConstant: 24),

            textLabel.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -12),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
        ])
    }

    func configure(text: String, index: Int) {
        textLabel.text = text
        indexLabel.text = ["A", "B", "C", "D"][index]
    }

    func reset() {
        containerView.backgroundColor = DSColor.surface
        containerView.layer.borderColor = UIColor.clear.cgColor
        indexLabel.backgroundColor = DSColor.accent
    }

    func showCorrect() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            self.containerView.layer.borderColor = UIColor.systemGreen.cgColor
            self.indexLabel.backgroundColor = .systemGreen
        }
    }

    func showWrong() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.15)
            self.containerView.layer.borderColor = UIColor.systemRed.cgColor
            self.indexLabel.backgroundColor = .systemRed
        }

        // Shake animation
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.values = [-10, 10, -8, 8, -5, 5, 0]
        shake.duration = 0.4
        containerView.layer.add(shake, forKey: "shake")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.containerView.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

// MARK: - QuizResultView

final class QuizResultView: UIView {

    var onDismiss: (() -> Void)?
    var onPlayAgain: (() -> Void)?

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
        iv.tintColor = DSColor.accent
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 48, weight: .bold)
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
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = DSColor.accent
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapPlayAgain), for: .touchUpInside)
        return button
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(DSColor.accent, for: .normal)
        button.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(scoreLabel)
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
            iconView.widthAnchor.constraint(equalToConstant: 80),
            iconView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -32),

            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scoreLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            messageLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16),
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

    func configure(score: Int, total: Int) {
        let percentage = Double(score) / Double(total) * 100

        scoreLabel.text = "\(score)/\(total)"

        if percentage >= 80 {
            iconView.image = UIImage(systemName: "star.fill")
            titleLabel.text = "Excellent!"
            messageLabel.text = "You're a vocabulary master!"
            iconView.tintColor = .systemYellow
        } else if percentage >= 60 {
            iconView.image = UIImage(systemName: "hand.thumbsup.fill")
            titleLabel.text = "Good Job!"
            messageLabel.text = "Keep practicing to improve!"
            iconView.tintColor = DSColor.accent
        } else {
            iconView.image = UIImage(systemName: "book.fill")
            titleLabel.text = "Keep Learning!"
            messageLabel.text = "Review your flashcards and try again."
            iconView.tintColor = .systemOrange
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

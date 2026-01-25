//
//  WordHuntViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class WordHuntViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol
    private var targetWords: [String] = []
    private var foundWords: Set<String> = []
    private var gridLetters: [[Character]] = []
    private var selectedIndices: [(row: Int, col: Int)] = []
    private var score = 0

    private let gridSize = 6
    private let gameTime = 90

    // MARK: - UI Components

    private lazy var headerView: GameHeaderView = {
        let view = GameHeaderView()
        view.onClose = { [weak self] in self?.confirmClose() }
        return view
    }()

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.wordhuntInstruction
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var gridContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var gridStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var currentWordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        label.text = ""
        return label
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

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.uturn.backward.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClear), for: .touchUpInside)
        return button
    }()

    private lazy var foundWordsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var resultView: GameResultView = {
        let view = GameResultView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.onDismiss = { [weak self] in self?.dismiss(animated: true) }
        view.onPlayAgain = { [weak self] in self?.restartGame() }
        return view
    }()

    private var letterButtons: [[LetterCell]] = []

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
        setupGame()
        headerView.configure(initialTime: gameTime) { [weak self] in
            self?.endGame()
        }
        headerView.startTimer()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(headerView)
        view.addSubview(instructionLabel)
        view.addSubview(gridContainer)
        gridContainer.addSubview(gridStack)
        view.addSubview(currentWordLabel)
        view.addSubview(clearButton)
        view.addSubview(submitButton)
        view.addSubview(foundWordsLabel)
        view.addSubview(resultView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            instructionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            gridContainer.topAnchor.constraint(
                equalTo: instructionLabel.bottomAnchor, constant: 20),
            gridContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridContainer.heightAnchor.constraint(equalTo: gridContainer.widthAnchor),

            gridStack.topAnchor.constraint(equalTo: gridContainer.topAnchor, constant: 8),
            gridStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor, constant: 8),
            gridStack.trailingAnchor.constraint(
                equalTo: gridContainer.trailingAnchor, constant: -8),
            gridStack.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor, constant: -8),

            currentWordLabel.topAnchor.constraint(
                equalTo: gridContainer.bottomAnchor, constant: 20),
            currentWordLabel.leadingAnchor.constraint(
                equalTo: clearButton.trailingAnchor, constant: 8),
            currentWordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            clearButton.centerYAnchor.constraint(equalTo: currentWordLabel.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearButton.widthAnchor.constraint(equalToConstant: 40),
            clearButton.heightAnchor.constraint(equalToConstant: 40),

            submitButton.topAnchor.constraint(equalTo: currentWordLabel.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 56),

            foundWordsLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 16),
            foundWordsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foundWordsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        createGrid()
    }

    private func createGrid() {
        for row in 0..<gridSize {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually

            var rowButtons: [LetterCell] = []

            for col in 0..<gridSize {
                let cell = LetterCell()
                cell.tag = row * gridSize + col
                cell.addTarget(self, action: #selector(letterTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(cell)
                rowButtons.append(cell)
            }

            letterButtons.append(rowButtons)
            gridStack.addArrangedSubview(rowStack)
        }
    }

    private func setupGame() {
        // Select target words (5-8 words)
        targetWords = Array(words.shuffled().prefix(min(8, words.count)))

        // Create grid with target words
        gridLetters = Array(
            repeating: Array(repeating: Character(" "), count: gridSize), count: gridSize)

        // Place words in grid
        placeWordsInGrid()

        // Fill remaining cells with random letters
        fillEmptyCells()

        // Update UI
        updateGrid()
        updateFoundWordsLabel()
    }

    private func placeWordsInGrid() {
        for word in targetWords {
            let uppercased = word.uppercased()
            var placed = false

            for _ in 0..<50 {  // Try 50 times to place each word
                let horizontal = Bool.random()
                let row = Int.random(in: 0..<gridSize)
                let col = Int.random(in: 0..<gridSize)

                if canPlace(word: uppercased, at: (row, col), horizontal: horizontal) {
                    place(word: uppercased, at: (row, col), horizontal: horizontal)
                    placed = true
                    break
                }
            }

            if !placed {
                // If can't place, skip this word
                targetWords.removeAll { $0 == word }
            }
        }
    }

    private func canPlace(word: String, at position: (row: Int, col: Int), horizontal: Bool) -> Bool
    {
        let chars = Array(word)

        for (index, char) in chars.enumerated() {
            let row = horizontal ? position.row : position.row + index
            let col = horizontal ? position.col + index : position.col

            guard row < gridSize && col < gridSize else { return false }

            let existing = gridLetters[row][col]
            if existing != Character(" ") && existing != char {
                return false
            }
        }

        return true
    }

    private func place(word: String, at position: (row: Int, col: Int), horizontal: Bool) {
        let chars = Array(word)

        for (index, char) in chars.enumerated() {
            let row = horizontal ? position.row : position.row + index
            let col = horizontal ? position.col + index : position.col
            gridLetters[row][col] = char
        }
    }

    private func fillEmptyCells() {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                if gridLetters[row][col] == Character(" ") {
                    gridLetters[row][col] = alphabet.randomElement()!
                }
            }
        }
    }

    private func updateGrid() {
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                letterButtons[row][col].configure(letter: gridLetters[row][col])
            }
        }
    }

    // MARK: - Actions

    @objc private func letterTapped(_ sender: LetterCell) {
        let row = sender.tag / gridSize
        let col = sender.tag % gridSize

        // Check if already selected
        if let index = selectedIndices.firstIndex(where: { $0.row == row && $0.col == col }) {
            // Deselect all after this one
            for i in stride(from: selectedIndices.count - 1, through: index, by: -1) {
                let pos = selectedIndices[i]
                letterButtons[pos.row][pos.col].setSelected(false)
                selectedIndices.remove(at: i)
            }
        } else {
            // Select this cell
            selectedIndices.append((row, col))
            letterButtons[row][col].setSelected(true)
        }

        updateCurrentWord()
        HapticManager.shared.selectionChanged()
    }

    @objc private func didTapSubmit() {
        let word = currentWordLabel.text?.lowercased() ?? ""

        if targetWords.contains(word) && !foundWords.contains(word) {
            // Correct!
            foundWords.insert(word)
            score += 20
            headerView.updateScore(score)
            HapticManager.shared.success()

            // Animate found
            animateCorrect()

            // Check if all found
            if foundWords.count == targetWords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.endGame()
                }
            }
        } else {
            // Wrong
            HapticManager.shared.error()
            animateWrong()
        }

        clearSelection()
        updateFoundWordsLabel()
    }

    @objc private func didTapClear() {
        clearSelection()
        HapticManager.shared.lightTap()
    }

    private func clearSelection() {
        for pos in selectedIndices {
            letterButtons[pos.row][pos.col].setSelected(false)
        }
        selectedIndices.removeAll()
        updateCurrentWord()
    }

    private func updateCurrentWord() {
        var word = ""
        for pos in selectedIndices {
            word += String(gridLetters[pos.row][pos.col])
        }
        currentWordLabel.text = word
    }

    private func updateFoundWordsLabel() {
        let foundList = foundWords.joined(separator: ", ")
        foundWordsLabel.text = foundList.isEmpty ? "" : "✓ \(foundList)"
    }

    private func animateCorrect() {
        for pos in selectedIndices {
            let cell = letterButtons[pos.row][pos.col]
            UIView.animate(withDuration: 0.2) {
                cell.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            }
        }
    }

    private func animateWrong() {
        submitButton.backgroundColor = .systemRed
        UIView.animate(withDuration: 0.2, delay: 0.3) {
            self.submitButton.backgroundColor = DSColor.accent
        }
    }

    private func confirmClose() {
        headerView.stopTimer()
        let alert = UIAlertController(
            title: nil,
            message: "Are you sure you want to quit?",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: Strings.cancelButton, style: .cancel) { _ in
                self.headerView.startTimer()
            })
        alert.addAction(
            UIAlertAction(title: "Quit", style: .destructive) { _ in
                self.dismiss(animated: true)
            })
        present(alert, animated: true)
    }

    private func endGame() {
        headerView.stopTimer()
        let xpEarned = score / 2
        if xpEarned > 0 {
            gamificationService.addXP(amount: xpEarned)
            gamificationService.updateStreak()
        }

        // Record stats
        MiniGameProgressManager.shared.recordWordhuntSession(
            score: score, wordsFound: foundWords.count)
        MiniGameProgressManager.shared.addMiniGameXP(xpEarned)

        resultView.configure(score: score, xpEarned: xpEarned, gameName: Strings.wordhuntTitle)
        resultView.isHidden = false
        HapticManager.shared.success()
    }

    private func restartGame() {
        resultView.isHidden = true
        score = 0
        foundWords.removeAll()
        selectedIndices.removeAll()
        headerView.updateScore(0)
        setupGame()
        headerView.configure(initialTime: gameTime) { [weak self] in
            self?.endGame()
        }
        headerView.startTimer()
    }
}

// MARK: - Letter Cell

private final class LetterCell: UIControl {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
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
        backgroundColor = DSColor.surface
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor

        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func configure(letter: Character) {
        label.text = String(letter)
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.backgroundColor =
                selected ? DSColor.accent.withAlphaComponent(0.2) : DSColor.surface
            self.layer.borderColor = selected ? DSColor.accent.cgColor : UIColor.clear.cgColor
            self.transform = selected ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }
}

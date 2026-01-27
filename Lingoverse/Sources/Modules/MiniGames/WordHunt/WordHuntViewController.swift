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
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var currentWordContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 2
        view.layer.borderColor = DSColor.accent.withAlphaComponent(0.3).cgColor
        return view
    }()

    private lazy var gridContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 24
        // Premium Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.1
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
        // Placeholder-like appearance initially
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

    private lazy var foundWordsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return sv
    }()

    private lazy var foundWordsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
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
        fatalError(Common.fatalError)
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

        // Current Word Area
        view.addSubview(currentWordContainer)
        currentWordContainer.addSubview(currentWordLabel)

        view.addSubview(clearButton)
        view.addSubview(submitButton)

        // Found Words Area
        view.addSubview(foundWordsScrollView)
        foundWordsScrollView.addSubview(foundWordsStack)

        view.addSubview(resultView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            instructionLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            gridContainer.topAnchor.constraint(
                equalTo: instructionLabel.bottomAnchor, constant: 20),
            gridContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            gridContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            gridContainer.heightAnchor.constraint(equalTo: gridContainer.widthAnchor),

            gridStack.topAnchor.constraint(equalTo: gridContainer.topAnchor, constant: 12),
            gridStack.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor, constant: 12),
            gridStack.trailingAnchor.constraint(
                equalTo: gridContainer.trailingAnchor, constant: -12),
            gridStack.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor, constant: -12),

            // Current Word Input Field Style
            currentWordContainer.topAnchor.constraint(
                equalTo: gridContainer.bottomAnchor, constant: 24),
            currentWordContainer.leadingAnchor.constraint(
                equalTo: clearButton.trailingAnchor, constant: 12),
            currentWordContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            currentWordContainer.heightAnchor.constraint(equalToConstant: 60),

            currentWordLabel.centerXAnchor.constraint(equalTo: currentWordContainer.centerXAnchor),
            currentWordLabel.centerYAnchor.constraint(equalTo: currentWordContainer.centerYAnchor),

            clearButton.centerYAnchor.constraint(equalTo: currentWordContainer.centerYAnchor),
            clearButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clearButton.widthAnchor.constraint(equalToConstant: 44),
            clearButton.heightAnchor.constraint(equalToConstant: 44),

            submitButton.topAnchor.constraint(
                equalTo: currentWordContainer.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 56),

            // Found Words Scroll
            foundWordsScrollView.topAnchor.constraint(
                equalTo: submitButton.bottomAnchor, constant: 20),
            foundWordsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            foundWordsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            foundWordsScrollView.heightAnchor.constraint(equalToConstant: 40),
            foundWordsScrollView.bottomAnchor.constraint(
                lessThanOrEqualTo: safeArea.bottomAnchor, constant: -20),

            foundWordsStack.leadingAnchor.constraint(
                equalTo: foundWordsScrollView.contentLayoutGuide.leadingAnchor),
            foundWordsStack.trailingAnchor.constraint(
                equalTo: foundWordsScrollView.contentLayoutGuide.trailingAnchor),
            foundWordsStack.topAnchor.constraint(
                equalTo: foundWordsScrollView.contentLayoutGuide.topAnchor),
            foundWordsStack.bottomAnchor.constraint(
                equalTo: foundWordsScrollView.contentLayoutGuide.bottomAnchor),
            foundWordsStack.heightAnchor.constraint(equalTo: foundWordsScrollView.heightAnchor),

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
        // No initial found words
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

            // Add Chip
            addFoundWordChip(word)

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

    private func addFoundWordChip(_ word: String) {
        let chipContainer = UIView()
        chipContainer.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        chipContainer.layer.cornerRadius = 16
        chipContainer.layer.borderWidth = 1
        chipContainer.layer.borderColor = DSColor.accent.withAlphaComponent(0.2).cgColor
        chipContainer.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = word.uppercased()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = DSColor.accent
        label.translatesAutoresizingMaskIntoConstraints = false

        chipContainer.addSubview(label)

        NSLayoutConstraint.activate([
            chipContainer.heightAnchor.constraint(equalToConstant: 32),
            label.leadingAnchor.constraint(equalTo: chipContainer.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: chipContainer.trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: chipContainer.centerYAnchor),
        ])

        // Initial state for animation
        chipContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        chipContainer.alpha = 0

        foundWordsStack.insertArrangedSubview(chipContainer, at: 0)

        UIView.animate(
            withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5
        ) {
            chipContainer.transform = .identity
            chipContainer.alpha = 1
            self.foundWordsScrollView.layoutIfNeeded()
        }

        // Scroll to start
        foundWordsScrollView.setContentOffset(.zero, animated: true)
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
        // Shake Grid
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0]
        gridContainer.layer.add(animation, forKey: "shake")

        submitButton.backgroundColor = .systemRed
        currentWordContainer.layer.borderColor = UIColor.systemRed.cgColor

        UIView.animate(withDuration: 0.2, delay: 0.3) {
            self.submitButton.backgroundColor = DSColor.accent
            self.currentWordContainer.layer.borderColor =
                DSColor.accent.withAlphaComponent(0.3).cgColor
            self.currentWordLabel.text = ""
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
        foundWordsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
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
        label.font = .systemFont(ofSize: 24, weight: .bold)  // Larger font
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var bgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = false
        // Shadow for premium feel
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.08
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    private func setupUI() {
        // Transparent container
        backgroundColor = .clear

        addSubview(bgView)
        addSubview(label)

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),

            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func configure(letter: Character) {
        label.text = String(letter)
    }

    func setSelected(_ selected: Bool) {
        let targetColor = selected ? DSColor.accent : DSColor.surface
        let targetTextColor = selected ? UIColor.white : DSColor.textPrimary
        let targetScale: CGFloat = selected ? 1.05 : 1.0

        UIView.animate(
            withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5
        ) {
            self.bgView.backgroundColor = targetColor
            self.label.textColor = targetTextColor
            self.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)

            // Remove shadow when selected to look "pressed" or "glowing" depending on design
            // Here we just keep it clean
            if selected {
                self.bgView.layer.shadowOpacity = 0
            } else {
                self.bgView.layer.shadowOpacity = 0.08
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform =
                    self.isHighlighted ? CGAffineTransform(scaleX: 0.92, y: 0.92) : .identity
            }
        }
    }
}

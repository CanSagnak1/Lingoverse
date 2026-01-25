//
//  MatchingGameViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class MatchingGameViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol
    private let client = WordKitClientLive()

    private var cards: [MatchingCard] = []
    private var flippedIndices: [Int] = []
    private var matchedPairs: Set<String> = []
    private var moves = 0
    private var totalPairs = 0
    private var isProcessing = false

    // MARK: - UI Components

    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = DSColor.textSecondary
        button.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        return button
    }()

    private lazy var statsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()

    private lazy var movesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var pairsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = DSColor.accent
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.register(MatchingCardCell.self, forCellWithReuseIdentifier: MatchingCardCell.identifier)
        return cv
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
        fatalError(Cammon.fatalError)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDefinitions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(headerLabel)
        view.addSubview(statsStack)
        statsStack.addArrangedSubview(movesLabel)
        statsStack.addArrangedSubview(pairsLabel)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(resultView)

        headerLabel.text = Strings.matchingSubtitle

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            headerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            statsStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 20),
            statsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            resultView.topAnchor.constraint(equalTo: view.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        updateStats()
    }

    private func loadDefinitions() {
        loadingIndicator.startAnimating()
        collectionView.isHidden = true

        let selectedWords = Array(words.shuffled().prefix(6))

        Task {
            var wordDefinitions: [(word: String, definition: String)] = []

            for word in selectedWords {
                do {
                    let results = try await client.search(
                        query: word, sourceLang: "en", targetLang: "en", page: nil)
                    if let firstWord = results.first,
                        let firstMeaning = firstWord.meanings.first,
                        let firstDef = firstMeaning.definitions.first
                    {
                        let shortDef = String(firstDef.definition.prefix(50))
                        wordDefinitions.append((word: word, definition: shortDef))
                    }
                } catch {
                    // Skip words without definitions
                }
            }

            await MainActor.run {
                createCards(from: wordDefinitions)
                loadingIndicator.stopAnimating()
                collectionView.isHidden = false
            }
        }
    }

    private func createCards(from pairs: [(word: String, definition: String)]) {
        cards.removeAll()
        totalPairs = pairs.count

        for pair in pairs {
            cards.append(MatchingCard(id: pair.word, content: pair.word.capitalized, type: .word))
            cards.append(MatchingCard(id: pair.word, content: pair.definition, type: .definition))
        }

        cards.shuffle()
        collectionView.reloadData()
        updateStats()
    }

    private func updateStats() {
        movesLabel.text = Strings.matchingMoves(moves)
        pairsLabel.text = Strings.matchingPairs(matchedPairs.count, totalPairs)
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    private func cardTapped(at index: Int) {
        guard !isProcessing else { return }
        guard !cards[index].isMatched && !cards[index].isFlipped else { return }

        cards[index].isFlipped = true
        flippedIndices.append(index)

        collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        HapticManager.shared.selectionChanged()

        if flippedIndices.count == 2 {
            isProcessing = true
            moves += 1
            updateStats()
            checkMatch()
        }
    }

    private func checkMatch() {
        let index1 = flippedIndices[0]
        let index2 = flippedIndices[1]

        let card1 = cards[index1]
        let card2 = cards[index2]

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if card1.id == card2.id && card1.type != card2.type {
                // Match!
                self.cards[index1].isMatched = true
                self.cards[index2].isMatched = true
                self.matchedPairs.insert(card1.id)
                HapticManager.shared.success()

                if self.matchedPairs.count == self.totalPairs {
                    self.endGame()
                }
            } else {
                // No match
                self.cards[index1].isFlipped = false
                self.cards[index2].isFlipped = false
                HapticManager.shared.error()
            }

            self.flippedIndices.removeAll()
            self.collectionView.reloadData()
            self.updateStats()
            self.isProcessing = false
        }
    }

    private func endGame() {
        let baseScore = 100
        let movesPenalty = max(0, moves - totalPairs) * 5
        let score = max(0, baseScore - movesPenalty)
        let xpEarned = score / 2

        if xpEarned > 0 {
            gamificationService.addXP(amount: xpEarned)
            gamificationService.updateStreak()
        }

        // Record stats
        MiniGameProgressManager.shared.recordMatchingSession(
            moves: moves, pairs: matchedPairs.count)
        MiniGameProgressManager.shared.addMiniGameXP(xpEarned)

        resultView.configure(score: score, xpEarned: xpEarned, gameName: Strings.matchingTitle)
        resultView.isHidden = false
        HapticManager.shared.success()
    }

    private func restartGame() {
        resultView.isHidden = true
        moves = 0
        matchedPairs.removeAll()
        flippedIndices.removeAll()
        isProcessing = false
        loadDefinitions()
    }
}

// MARK: - UICollectionViewDataSource

extension MatchingGameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return cards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MatchingCardCell.identifier,
                for: indexPath
            ) as? MatchingCardCell
        else {
            return UICollectionViewCell()
        }

        let card = cards[indexPath.item]
        cell.configure(with: card)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MatchingGameViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cardTapped(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MatchingGameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 10
        let columns: CGFloat = 3
        let totalSpacing = spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width * 1.2)
    }
}

// MARK: - Models

private struct MatchingCard {
    let id: String
    let content: String
    let type: CardType
    var isFlipped: Bool = false
    var isMatched: Bool = false

    enum CardType {
        case word
        case definition
    }
}

// MARK: - Card Cell

private final class MatchingCardCell: UICollectionViewCell {
    static let identifier = "MatchingCardCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    private lazy var questionMark: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "?"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = DSColor.accent
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
        contentView.addSubview(containerView)
        containerView.addSubview(contentLabel)
        containerView.addSubview(questionMark)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 8),
            contentLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -8),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            questionMark.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            questionMark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
    }

    func configure(with card: MatchingCard) {
        if card.isMatched {
            containerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = UIColor.systemGreen.cgColor
            contentLabel.text = card.content
            contentLabel.isHidden = false
            questionMark.isHidden = true
        } else if card.isFlipped {
            containerView.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = DSColor.accent.cgColor
            contentLabel.text = card.content
            contentLabel.isHidden = false
            questionMark.isHidden = true
        } else {
            containerView.backgroundColor = DSColor.surface
            containerView.layer.borderWidth = 0
            contentLabel.isHidden = true
            questionMark.isHidden = false
        }
    }
}

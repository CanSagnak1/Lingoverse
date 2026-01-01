//
//  FlashcardViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

final class FlashcardViewController: UIViewController {

    private let words: [String]
    private var currentIndex = 0
    private var isShowingFront = true
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

    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cardView: FlashcardView = {
        let card = FlashcardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        card.addGestureRecognizer(tap)
        return card
    }()

    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tap card to flip"
        label.font = .systemFont(ofSize: 13)
        label.textColor = DSColor.textSecondary.withAlphaComponent(0.6)
        label.textAlignment = .center
        return label
    }()

    private lazy var navigationStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [prevButton, nextButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.left.circle.fill"), for: .normal)
        button.setTitle(" Previous", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.tintColor = DSColor.accent
        button.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "arrow.right.circle.fill"), for: .normal)
        button.setTitle("Next ", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.tintColor = DSColor.accent
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = DSColor.accent
        return indicator
    }()

    // MARK: - Init

    init(words: [String]) {
        self.words = words.shuffled()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        loadCurrentCard()
        LearnProgressManager.shared.recordFlashcardSession()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(closeButton)
        view.addSubview(progressLabel)
        view.addSubview(cardContainer)
        cardContainer.addSubview(cardView)
        cardContainer.addSubview(loadingIndicator)
        view.addSubview(hintLabel)
        view.addSubview(navigationStack)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),

            progressLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardContainer.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 40),
            cardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardContainer.heightAnchor.constraint(
                equalTo: cardContainer.widthAnchor, multiplier: 1.3),

            cardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),

            hintLabel.topAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: 16),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            navigationStack.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32),
            navigationStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            navigationStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            navigationStack.heightAnchor.constraint(equalToConstant: 50),
        ])

        updateProgress()
    }

    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    // MARK: - Card Loading

    private func loadCurrentCard() {
        guard currentIndex < words.count else { return }

        let word = words[currentIndex]
        isShowingFront = true
        cardView.showFront(word: word)

        if let cached = cachedDefinitions[word] {
            cardView.setDefinition(cached)
        } else {
            loadDefinition(for: word)
        }

        updateProgress()
        updateNavigationButtons()
    }

    private func loadDefinition(for word: String) {
        loadingIndicator.startAnimating()

        Task {
            do {
                let results = try await client.search(
                    query: word, sourceLang: "en", targetLang: "en", page: nil)
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    if let firstWord = results.first,
                        let firstMeaning = firstWord.meanings.first,
                        let firstDef = firstMeaning.definitions.first
                    {
                        let definition = firstDef.definition
                        cachedDefinitions[word] = definition
                        cardView.setDefinition(definition)
                    } else {
                        cardView.setDefinition("Definition not found")
                    }
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    cardView.setDefinition("Failed to load definition")
                }
            }
        }
    }

    private func updateProgress() {
        progressLabel.text = "\(currentIndex + 1) / \(words.count)"
    }

    private func updateNavigationButtons() {
        prevButton.isEnabled = currentIndex > 0
        prevButton.alpha = currentIndex > 0 ? 1.0 : 0.4

        nextButton.isEnabled = currentIndex < words.count - 1
        nextButton.alpha = currentIndex < words.count - 1 ? 1.0 : 0.4
    }

    // MARK: - Actions

    @objc private func didTapClose() {
        HapticManager.shared.buttonPressed()
        dismiss(animated: true)
    }

    @objc private func didTapCard() {
        HapticManager.shared.lightTap()
        flipCard()
    }

    @objc private func didTapPrev() {
        guard currentIndex > 0 else { return }
        HapticManager.shared.selectionChanged()
        animateCardTransition(direction: .right) {
            self.currentIndex -= 1
            self.loadCurrentCard()
        }
    }

    @objc private func didTapNext() {
        guard currentIndex < words.count - 1 else { return }
        HapticManager.shared.selectionChanged()
        animateCardTransition(direction: .left) {
            self.currentIndex += 1
            self.loadCurrentCard()
        }
    }

    @objc private func didSwipeLeft() {
        didTapNext()
    }

    @objc private func didSwipeRight() {
        didTapPrev()
    }

    private func flipCard() {
        isShowingFront.toggle()

        let transitionOptions: UIView.AnimationOptions = [
            .transitionFlipFromRight, .showHideTransitionViews,
        ]

        UIView.transition(
            with: cardView, duration: 0.4, options: transitionOptions,
            animations: {
                if self.isShowingFront {
                    self.cardView.showFront(word: self.words[self.currentIndex])
                } else {
                    self.cardView.showBack()
                }
            })
    }

    private func animateCardTransition(
        direction: UISwipeGestureRecognizer.Direction, completion: @escaping () -> Void
    ) {
        let offset: CGFloat = direction == .left ? -view.bounds.width : view.bounds.width

        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.cardView.transform = CGAffineTransform(translationX: offset, y: 0)
                self.cardView.alpha = 0
            }
        ) { _ in
            self.cardView.transform = CGAffineTransform(translationX: -offset, y: 0)
            completion()
            UIView.animate(withDuration: 0.2) {
                self.cardView.transform = .identity
                self.cardView.alpha = 1
            }
        }
    }
}

// MARK: - FlashcardView

final class FlashcardView: UIView {

    private var currentDefinition: String = ""

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
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
        backgroundColor = DSColor.surface
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.1

        addSubview(typeLabel)
        addSubview(contentLabel)

        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            typeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            contentLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }

    func showFront(word: String) {
        typeLabel.text = "WORD"
        contentLabel.text = word.capitalized
        contentLabel.font = .systemFont(ofSize: 42, weight: .bold)
        contentLabel.textColor = DSColor.textPrimary
        backgroundColor = DSColor.surface
    }

    func showBack() {
        typeLabel.text = "DEFINITION"
        contentLabel.text = currentDefinition
        contentLabel.font = .systemFont(ofSize: 20, weight: .regular)
        contentLabel.textColor = DSColor.textPrimary
        backgroundColor = DSColor.accent.withAlphaComponent(0.1)
    }

    func setDefinition(_ definition: String) {
        currentDefinition = definition
    }
}

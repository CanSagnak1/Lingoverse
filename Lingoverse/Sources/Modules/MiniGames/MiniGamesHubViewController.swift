//
//  MiniGamesHubViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 25.01.2026.
//

import UIKit

final class MiniGamesHubViewController: UIViewController {

    // MARK: - Properties

    private let words: [String]
    private let gamificationService: GamificationServiceProtocol

    // MARK: - Game Models

    struct GameItem {
        let title: String
        let subtitle: String
        let iconName: String
        let color: UIColor
        let minWords: Int
        let action: () -> Void
    }

    private var games: [GameItem] = []

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        let itemWidth = width - 40  // Full width with padding
        layout.itemSize = CGSize(width: itemWidth, height: 110)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(MiniGameCell.self, forCellWithReuseIdentifier: MiniGameCell.identifier)
        cv.register(
            MiniGamesHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MiniGamesHeaderView.identifier
        )
        return cv
    }()

    // MARK: - Initialization

    init(words: [String], gamificationService: GamificationServiceProtocol = GamificationService())
    {
        self.words = words
        self.gamificationService = gamificationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGames()
        setupUI()
    }

    // MARK: - Setup

    private func setupGames() {
        games = [
            GameItem(
                title: Strings.wordhuntTitle,
                subtitle: Strings.wordhuntSubtitle,
                iconName: "magnifyingglass",
                color: .systemBlue,
                minWords: 5,
                action: { [weak self] in self?.openWordHunt() }
            ),
            GameItem(
                title: Strings.matchingTitle,
                subtitle: Strings.matchingSubtitle,
                iconName: "square.grid.2x2.fill",
                color: .systemGreen,
                minWords: 6,
                action: { [weak self] in self?.openMatching() }
            ),
            GameItem(
                title: Strings.wordchainTitle,
                subtitle: Strings.wordchainSubtitle,
                iconName: "link",
                color: .systemPurple,
                minWords: 4,
                action: { [weak self] in self?.openWordChain() }
            ),
            GameItem(
                title: Strings.hangmanTitle,
                subtitle: Strings.hangmanSubtitle,
                iconName: "person.fill.questionmark",
                color: .systemOrange,
                minWords: 1,
                action: { [weak self] in self?.openHangman() }
            ),
            GameItem(
                title: Strings.speedfireTitle,
                subtitle: Strings.speedfireSubtitle,
                iconName: "bolt.fill",
                color: .systemRed,
                minWords: 8,
                action: { [weak self] in self?.openSpeedFire() }
            ),
        ]
    }

    private func setupUI() {
        title = Strings.minigamesTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Navigation

    private func openWordHunt() {
        let vc = WordHuntViewController(words: words, gamificationService: gamificationService)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func openMatching() {
        let vc = MatchingGameViewController(words: words, gamificationService: gamificationService)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func openWordChain() {
        let vc = WordChainViewController(words: words, gamificationService: gamificationService)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func openHangman() {
        let vc = HangmanViewController(words: words, gamificationService: gamificationService)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func openSpeedFire() {
        let vc = SpeedFireViewController(words: words, gamificationService: gamificationService)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension MiniGamesHubViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return games.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MiniGameCell.identifier, for: indexPath) as? MiniGameCell
        else {
            return UICollectionViewCell()
        }

        let game = games[indexPath.item]
        cell.configure(game: game, currentWordCount: words.count)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: MiniGamesHeaderView.identifier, for: indexPath)
                as? MiniGamesHeaderView
        else {
            return UICollectionReusableView()
        }
        header.configure(wordCount: words.count)
        return header
    }

    func collectionView(
        _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 220)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let game = games[indexPath.item]
        if words.count >= game.minWords {
            HapticManager.shared.buttonPressed()

            // Re-animate cell
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(
                    withDuration: 0.1,
                    animations: {
                        cell.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                    }
                ) { _ in
                    UIView.animate(withDuration: 0.1) {
                        cell.transform = .identity
                    } completion: { _ in
                        game.action()
                    }
                }
            } else {
                game.action()
            }
        } else {
            HapticManager.shared.error()
            // Shake animation
            if let cell = collectionView.cellForItem(at: indexPath) {
                let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.duration = 0.6
                animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0]
                cell.layer.add(animation, forKey: "shake")
            }
        }
    }
}

// MARK: - Mini Game Cell

final class MiniGameCell: UICollectionViewCell {
    static let identifier = "MiniGameCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        view.layer.shadowOpacity = 0.08
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.cornerRadius = 24
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .white.withAlphaComponent(0.2)
        return view
    }()

    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = DSColor.textSecondary
        return label
    }()

    private lazy var statusBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()

    private lazy var statusStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        return stack
    }()

    private lazy var lockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = DSColor.textSecondary
        return label
    }()

    private lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        button.tintColor = DSColor.accent
        button.isUserInteractionEnabled = false  // Tap handled by cell
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient frame but only for the left side accent
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 6, height: bounds.height)
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.layer.addSublayer(gradientLayer)

        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(playButton)

        containerView.addSubview(statusBadge)
        statusBadge.addSubview(statusStack)
        statusStack.addArrangedSubview(lockIcon)
        statusStack.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconContainer.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 20),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 56),
            iconContainer.heightAnchor.constraint(equalToConstant: 56),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -12),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: playButton.leadingAnchor, constant: -8),

            playButton.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -20),
            playButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 36),
            playButton.heightAnchor.constraint(equalToConstant: 36),

            statusBadge.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -16),
            statusBadge.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statusBadge.heightAnchor.constraint(equalToConstant: 28),
            // Add leading constraint to prevent overlap with title/subtitle
            statusBadge.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),

            statusStack.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 14),
            statusStack.trailingAnchor.constraint(
                equalTo: statusBadge.trailingAnchor, constant: -14),
            statusStack.centerYAnchor.constraint(equalTo: statusBadge.centerYAnchor),

            lockIcon.widthAnchor.constraint(equalToConstant: 16),
            lockIcon.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    func configure(game: MiniGamesHubViewController.GameItem, currentWordCount: Int) {
        titleLabel.text = game.title
        subtitleLabel.text = game.subtitle

        iconView.image = UIImage(systemName: game.iconName)

        // Dynamic colors based on game color
        gradientLayer.colors = [
            game.color.cgColor,
            game.color.withAlphaComponent(0.6).cgColor,
        ]

        let isEnabled = currentWordCount >= game.minWords

        if isEnabled {
            containerView.alpha = 1.0
            iconContainer.backgroundColor = game.color.withAlphaComponent(0.15)
            iconView.tintColor = game.color

            playButton.isHidden = false
            statusBadge.isHidden = true

            titleLabel.textColor = DSColor.textPrimary
            subtitleLabel.textColor = DSColor.textSecondary

        } else {
            containerView.alpha = 0.8
            iconContainer.backgroundColor = DSColor.textSecondary.withAlphaComponent(0.1)
            iconView.tintColor = DSColor.textSecondary

            playButton.isHidden = true
            statusBadge.isHidden = false
            statusBadge.backgroundColor = DSColor.textSecondary.withAlphaComponent(0.1)

            // Show needed words count
            let needed = game.minWords - currentWordCount
            lockIcon.image = UIImage(systemName: "plus.circle.fill")
            statusLabel.text = Strings.minigamesNeedMore(needed)
            statusLabel.textColor = DSColor.textSecondary

            titleLabel.textColor = DSColor.textSecondary
            subtitleLabel.textColor = DSColor.textSecondary.withAlphaComponent(0.8)
        }
    }
}

// MARK: - Header View

final class MiniGamesHeaderView: UICollectionReusableView {
    static let identifier = "MiniGamesHeaderView"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 24
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.minigamesHeaderTitle
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.minigamesHeaderSubtitle
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var statsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 14
        return view
    }()

    private lazy var statsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    private lazy var statsIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "book.closed.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var wordCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(statsContainer)
        statsContainer.addSubview(statsStack)
        statsStack.addArrangedSubview(statsIcon)
        statsStack.addArrangedSubview(wordCountLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: containerView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: containerView.trailingAnchor, constant: -24),

            statsContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            statsContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            statsContainer.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -24),
            statsContainer.heightAnchor.constraint(equalToConstant: 40),

            statsStack.leadingAnchor.constraint(
                equalTo: statsContainer.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(
                equalTo: statsContainer.trailingAnchor, constant: -20),
            statsStack.centerYAnchor.constraint(equalTo: statsContainer.centerYAnchor),

            statsIcon.widthAnchor.constraint(equalToConstant: 18),
            statsIcon.heightAnchor.constraint(equalToConstant: 18),
        ])
    }

    func configure(wordCount: Int) {
        wordCountLabel.text = Strings.minigamesLearnedWords(wordCount)
    }
}

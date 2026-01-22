//
//  ProfileViewController.swift
//  Lingoverse
//
//  Created by Antigravity on 23.01.2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let gamificationService: GamificationServiceProtocol

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Header Section
    private lazy var levelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.accent.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        return view
    }()

    private lazy var levelLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    // MARK: - Streak Section
    private lazy var streakCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColor.border.cgColor
        return view
    }()

    private lazy var streakIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var streakLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var streakSubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = DSColor.textSecondary
        return label
    }()

    // MARK: - Badges Section
    private lazy var badgesTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var badgesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.scrollDirection = .vertical

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        return cv
    }()

    private var badges: [Badge] = []

    init(gamificationService: GamificationServiceProtocol = GamificationService()) {
        self.gamificationService = gamificationService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func reloadData() {
        gamificationService.checkBadges()  // Ensure latest state
        let progress = gamificationService.progress
        badges = gamificationService.badges

        title = Strings.profileTitle
        levelLabel.text = Strings.profileLevel(progress.currentLevel)
        xpLabel.text = "\(progress.totalXP) XP"
        streakLabel.text = Strings.profileStreakDays(progress.currentStreak)
        streakSubLabel.text = Strings.profileStreakSubtitle
        badgesTitleLabel.text = Strings.profileBadges

        badgesCollectionView.reloadData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(levelContainer)
        levelContainer.addSubview(levelLabel)
        levelContainer.addSubview(xpLabel)

        contentView.addSubview(streakCard)
        streakCard.addSubview(streakIcon)
        streakCard.addSubview(streakLabel)
        streakCard.addSubview(streakSubLabel)

        contentView.addSubview(badgesTitleLabel)
        contentView.addSubview(badgesCollectionView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Level Section
            levelContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            levelContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            levelContainer.widthAnchor.constraint(equalToConstant: 200),
            levelContainer.heightAnchor.constraint(equalToConstant: 120),

            levelLabel.centerXAnchor.constraint(equalTo: levelContainer.centerXAnchor),
            levelLabel.centerYAnchor.constraint(
                equalTo: levelContainer.centerYAnchor, constant: -10),

            xpLabel.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 8),
            xpLabel.centerXAnchor.constraint(equalTo: levelContainer.centerXAnchor),

            // Streak Section
            streakCard.topAnchor.constraint(equalTo: levelContainer.bottomAnchor, constant: 24),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            streakCard.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            streakCard.heightAnchor.constraint(equalToConstant: 80),

            streakIcon.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 24),
            streakIcon.centerYAnchor.constraint(equalTo: streakCard.centerYAnchor),
            streakIcon.widthAnchor.constraint(equalToConstant: 32),
            streakIcon.heightAnchor.constraint(equalToConstant: 32),

            streakLabel.leadingAnchor.constraint(equalTo: streakIcon.trailingAnchor, constant: 16),
            streakLabel.centerYAnchor.constraint(equalTo: streakCard.centerYAnchor, constant: -10),

            streakSubLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 2),
            streakSubLabel.leadingAnchor.constraint(equalTo: streakLabel.leadingAnchor),

            // Badges Section
            badgesTitleLabel.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 32),
            badgesTitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),

            badgesCollectionView.topAnchor.constraint(
                equalTo: badgesTitleLabel.bottomAnchor, constant: 16),
            badgesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            badgesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            badgesCollectionView.heightAnchor.constraint(equalToConstant: 400),  // Fixed height for now
            badgesCollectionView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int
    {
        return badges.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BadgeCell.identifier, for: indexPath) as? BadgeCell
        else {
            return UICollectionViewCell()
        }

        let badge = badges[indexPath.item]
        cell.configure(with: badge)
        return cell
    }
}

// MARK: - Badge Cell
final class BadgeCell: UICollectionViewCell {
    static let identifier = "BadgeCell"

    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.textSecondary
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
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
        contentView.backgroundColor = DSColor.surface
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = DSColor.border.cgColor

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    func configure(with badge: Badge) {
        iconView.image = UIImage(systemName: badge.type.iconName)
        titleLabel.text = Strings.badgeTitle(badge.type.rawValue)

        if badge.isUnlocked {
            contentView.alpha = 1.0
            iconView.tintColor = DSColor.accent
            contentView.layer.borderColor = DSColor.accent.cgColor
        } else {
            contentView.alpha = 0.5
            iconView.tintColor = DSColor.textSecondary
            contentView.layer.borderColor = DSColor.border.cgColor
        }
    }
}

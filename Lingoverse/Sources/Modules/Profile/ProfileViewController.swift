//
//  ProfileViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 23.01.2026.
//  UI Redesigned on 25.01.2026.
//  VIPER Refactored on 26.01.2026.
//

import UIKit

protocol ProfileViewInput: AnyObject {
    func render(viewModel: ProfileViewModel)
}

final class ProfileViewController: UIViewController, ProfileViewInput {

    var presenter: ProfileViewOutput!

    private var badges: [Badge] = []

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceVertical = true
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Hero Header Section

    private lazy var heroContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()

    private lazy var heroGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            DSColor.accent.cgColor,
            DSColor.accent.withAlphaComponent(0.7).cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()

    private lazy var avatarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.layer.cornerRadius = 50
        return view
    }()

    private lazy var avatarEmoji: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🧠"
        label.font = .systemFont(ofSize: 48)
        label.textAlignment = .center
        return label
    }()

    private lazy var levelBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.15
        return view
    }()

    private lazy var levelBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = DSColor.accent
        label.textAlignment = .center
        return label
    }()

    private lazy var xpLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var xpSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Toplam Deneyim Puanı"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Stats Cards Row

    private lazy var statsRow: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var streakCard: ProfileStatCard = {
        let card = ProfileStatCard()
        card.configure(icon: "flame.fill", iconColor: .systemOrange)
        return card
    }()

    private lazy var levelCard: ProfileStatCard = {
        let card = ProfileStatCard()
        card.configure(icon: "star.fill", iconColor: .systemYellow)
        return card
    }()

    private lazy var badgesEarnedCard: ProfileStatCard = {
        let card = ProfileStatCard()
        card.configure(icon: "medal.fill", iconColor: .systemPurple)
        return card
    }()

    // MARK: - Badges Section

    private lazy var badgesSectionHeader: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var badgesTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var badgesSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        label.textColor = DSColor.textSecondary
        return label
    }()

    private lazy var badgesCollectionView: IntrinsicCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        let itemWidth: CGFloat = (width - 40 - 24) / 3  // 3 columns with 20 padding sides + 12 spacing
        layout.itemSize = CGSize(width: floor(itemWidth), height: 130)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.scrollDirection = .vertical

        let cv = IntrinsicCollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    init() {
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
        presenter?.viewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradientLayer.frame = heroContainer.bounds
        badgesCollectionView.invalidateIntrinsicContentSize()
    }

    // MARK: - ProfileViewInput

    func render(viewModel: ProfileViewModel) {
        title = Strings.profileTitle
        badges = viewModel.badges

        // Hero section
        xpLabel.text = "\(viewModel.totalXP) XP"
        levelBadgeLabel.text = "Lv.\(viewModel.currentLevel)"

        // Stats cards
        streakCard.setValue("\(viewModel.currentStreak)", subtitle: Strings.profileStreakSubtitle)
        levelCard.setValue("Lv.\(viewModel.currentLevel)", subtitle: "Seviye")
        badgesEarnedCard.setValue(
            "\(viewModel.unlockedBadgesCount)/\(viewModel.totalBadgesCount)",
            subtitle: Strings.profileBadges)

        // Badges section
        badgesTitleLabel.text = Strings.profileBadges
        badgesSubtitleLabel.text = "\(viewModel.unlockedBadgesCount) rozet kazandınız"

        badgesCollectionView.reloadData()
        badgesCollectionView.layoutIfNeeded()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Hero Container
        contentView.addSubview(heroContainer)
        heroContainer.layer.insertSublayer(heroGradientLayer, at: 0)
        heroContainer.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarEmoji)
        heroContainer.addSubview(levelBadge)
        levelBadge.addSubview(levelBadgeLabel)
        heroContainer.addSubview(xpLabel)
        heroContainer.addSubview(xpSubtitleLabel)

        // Stats Row
        statsRow.addArrangedSubview(streakCard)
        statsRow.addArrangedSubview(levelCard)
        statsRow.addArrangedSubview(badgesEarnedCard)
        contentView.addSubview(statsRow)

        // Badges Section Header
        badgesSectionHeader.addSubview(badgesTitleLabel)
        badgesSectionHeader.addSubview(badgesSubtitleLabel)
        contentView.addSubview(badgesSectionHeader)
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

            // Hero Container
            heroContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            heroContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            heroContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            heroContainer.heightAnchor.constraint(equalToConstant: 240),  // Increased height

            avatarContainer.topAnchor.constraint(equalTo: heroContainer.topAnchor, constant: 32),
            avatarContainer.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 100),
            avatarContainer.heightAnchor.constraint(equalToConstant: 100),

            avatarEmoji.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarEmoji.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            levelBadge.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 4),
            levelBadge.trailingAnchor.constraint(
                equalTo: avatarContainer.trailingAnchor, constant: 4),
            levelBadge.widthAnchor.constraint(equalToConstant: 48),
            levelBadge.heightAnchor.constraint(equalToConstant: 28),

            levelBadgeLabel.centerXAnchor.constraint(equalTo: levelBadge.centerXAnchor),
            levelBadgeLabel.centerYAnchor.constraint(equalTo: levelBadge.centerYAnchor),

            xpLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 20),
            xpLabel.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),

            xpSubtitleLabel.topAnchor.constraint(equalTo: xpLabel.bottomAnchor, constant: 8),
            xpSubtitleLabel.centerXAnchor.constraint(equalTo: heroContainer.centerXAnchor),

            // Stats Row
            statsRow.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: 24),
            statsRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statsRow.heightAnchor.constraint(equalToConstant: 100),  // Increased height

            // Badges Section Header
            badgesSectionHeader.topAnchor.constraint(equalTo: statsRow.bottomAnchor, constant: 32),
            badgesSectionHeader.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 20),
            badgesSectionHeader.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -20),
            badgesSectionHeader.heightAnchor.constraint(equalToConstant: 50),

            badgesTitleLabel.topAnchor.constraint(equalTo: badgesSectionHeader.topAnchor),
            badgesTitleLabel.leadingAnchor.constraint(equalTo: badgesSectionHeader.leadingAnchor),

            badgesSubtitleLabel.topAnchor.constraint(
                equalTo: badgesTitleLabel.bottomAnchor, constant: 4),
            badgesSubtitleLabel.leadingAnchor.constraint(
                equalTo: badgesSectionHeader.leadingAnchor),

            // Badges Collection
            badgesCollectionView.topAnchor.constraint(
                equalTo: badgesSectionHeader.bottomAnchor, constant: 12),
            badgesCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            badgesCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            // Removed fixed height constraint
            badgesCollectionView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -20),
        ])
    }
}

// MARK: - Intrinsic Collection View
final class IntrinsicCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return self.collectionViewLayout.collectionViewContentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.bounds.size.equalTo(self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
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

// MARK: - Profile Stat Card

private final class ProfileStatCard: UIView {

    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        return iv
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
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
        backgroundColor = DSColor.surface
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.06

        addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        addSubview(valueLabel)
        addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            valueLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    func configure(icon: String, iconColor: UIColor) {
        iconView.image = UIImage(systemName: icon)
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.15)
        iconView.tintColor = iconColor
    }

    func setValue(_ value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }
}

// MARK: - Badge Cell

final class BadgeCell: UICollectionViewCell {
    static let identifier = "BadgeCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        return view
    }()

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
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var checkmark: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            iconContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -8),

            checkmark.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            checkmark.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -8),
            checkmark.widthAnchor.constraint(equalToConstant: 20),
            checkmark.heightAnchor.constraint(equalToConstant: 20),
        ])
    }

    func configure(with badge: Badge) {
        iconView.image = UIImage(systemName: badge.type.iconName)
        titleLabel.text = Strings.badgeTitle(badge.type.rawValue)

        if badge.isUnlocked {
            containerView.alpha = 1.0
            iconContainer.backgroundColor = DSColor.accent.withAlphaComponent(0.15)
            iconView.tintColor = DSColor.accent
            containerView.layer.borderWidth = 2
            containerView.layer.borderColor = DSColor.accent.withAlphaComponent(0.3).cgColor
            checkmark.isHidden = false
        } else {
            containerView.alpha = 0.6
            iconContainer.backgroundColor = DSColor.textSecondary.withAlphaComponent(0.1)
            iconView.tintColor = DSColor.textSecondary
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = DSColor.border.cgColor
            checkmark.isHidden = true
        }
    }
}

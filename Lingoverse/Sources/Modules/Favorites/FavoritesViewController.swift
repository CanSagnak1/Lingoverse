//
//  FavoritesViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 5.11.2025.
//

import UIKit

protocol FavoritesViewInput: AnyObject {
    func render(_ state: FavoritesState)
    func dismissSearch()
}

final class FavoritesViewController: UIViewController, FavoritesViewInput {

    var presenter: FavoritesViewOutput!

    private var favoriteItems: [String] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)  // Grouped for cleaner header
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none  // No separators for cards
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.showsVerticalScrollIndicator = false
        // Add padding at bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return tableView
    }()

    private lazy var emptyView: DSListEmptyView = {
        let view = DSListEmptyView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.configure(
            title: Strings.favoritesTitle,
            description: Strings.hintNoFavorites,
            icon: "star.fill"
        )
        return view
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.backgroundColor = .clear
        spinner.color = DSColor.accent
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        animateTableEntrance()
    }

    private func animateTableEntrance() {
        tableView.reloadData()

        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height

        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            cell.alpha = 0

            UIView.animate(
                withDuration: 0.8,
                delay: 0.05 * Double(index),
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: .curveEaseOut,
                animations: {
                    cell.transform = .identity
                    cell.alpha = 1
                },
                completion: nil
            )
        }
    }

    private func setupUI() {
        title = Strings.favoritesTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always

        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(emptyView)

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            spinner.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),

            emptyView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            emptyView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            emptyView.leadingAnchor.constraint(
                greaterThanOrEqualTo: safeArea.leadingAnchor, constant: DSSpacing.x4),
            emptyView.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor, constant: -DSSpacing.x4),
        ])
    }

    func render(_ state: FavoritesState) {
        spinner.stopAnimating()
        emptyView.isHidden = true
        tableView.isHidden = false

        switch state {
        case .loading:
            spinner.startAnimating()
            tableView.isHidden = true

        case .content(let terms):
            favoriteItems = terms
            tableView.reloadData()

        case .empty:
            favoriteItems = []
            tableView.reloadData()
            emptyView.isHidden = false
            tableView.isHidden = true
        }
    }

    func dismissSearch() {
        presenter.searchDidDismiss()
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath)
                as? FavoriteCell
        else {
            return UITableViewCell()
        }
        cell.configure(with: favoriteItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        presenter.didSelectRow(indexPath.row)
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(style: .destructive, title: Strings.deleteActionTitle)
        { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            self.presenter.didDeleteFavorite(at: indexPath.row)
            completion(true)
        }

        deleteAction.backgroundColor = DSColor.accent
        deleteAction.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !favoriteItems.isEmpty else { return nil }

        let header = UIView()
        header.backgroundColor = .clear

        let countLabel = UILabel()
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .systemFont(ofSize: 13, weight: .medium)
        countLabel.textColor = DSColor.textSecondary

        countLabel.text = Strings.savedWordsCount(favoriteItems.count)

        header.addSubview(countLabel)

        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            countLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
        ])

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        favoriteItems.isEmpty ? 0 : 36
    }
}

private final class FavoriteCell: UITableViewCell {

    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = DSColor.surface
        view.layer.cornerRadius = 20

        // Premium Shadow
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.06

        // Subtle Border
        view.layer.borderWidth = 1
        view.layer.borderColor = DSColor.textSecondary.withAlphaComponent(0.05).cgColor

        return view
    }()

    private lazy var starContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DSColor.favoriteGreen.withAlphaComponent(0.12)
        container.layer.cornerRadius = 18  // Squircle
        return container
    }()

    private lazy var starIcon: UIImageView = {
        let iv = UIImageView(
            image: UIImage(systemName: "star.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.favoriteGreen
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.text = Strings.favoriteTapHint
        return label
    }()

    private lazy var chevronIcon: UIImageView = {
        let iv = UIImageView(
            image: UIImage(systemName: "chevron.right")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.textSecondary.withAlphaComponent(0.4)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear  // Transparent cell background for card spacing

        contentView.addSubview(cardContainer)
        cardContainer.addSubview(starContainer)
        starContainer.addSubview(starIcon)
        cardContainer.addSubview(wordLabel)
        cardContainer.addSubview(subtitleLabel)
        cardContainer.addSubview(chevronIcon)

        NSLayoutConstraint.activate([
            // Card Container (Floating)
            cardContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),

            // Icon
            starContainer.leadingAnchor.constraint(
                equalTo: cardContainer.leadingAnchor, constant: 16),
            starContainer.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            starContainer.widthAnchor.constraint(equalToConstant: 48),
            starContainer.heightAnchor.constraint(equalToConstant: 48),

            starIcon.centerXAnchor.constraint(equalTo: starContainer.centerXAnchor),
            starIcon.centerYAnchor.constraint(equalTo: starContainer.centerYAnchor),

            // Text
            wordLabel.leadingAnchor.constraint(equalTo: starContainer.trailingAnchor, constant: 16),
            wordLabel.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 18),
            wordLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: chevronIcon.leadingAnchor, constant: -8),

            subtitleLabel.leadingAnchor.constraint(equalTo: wordLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: chevronIcon.leadingAnchor, constant: -8),

            // Chevron
            chevronIcon.trailingAnchor.constraint(
                equalTo: cardContainer.trailingAnchor, constant: -20),
            chevronIcon.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 12),
        ])
    }

    func configure(with term: String) {
        wordLabel.text = term.capitalized
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut) {
            self.cardContainer.transform =
                highlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            self.cardContainer.backgroundColor =
                highlighted ? DSColor.surface.withAlphaComponent(0.9) : DSColor.surface
        }
    }
}

//
//  SearchViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

protocol SearchViewInput: AnyObject {
    func render(_ state: SearchState)
    func setSearchText(_ text: String)
    func dismissSearch()
}

final class SearchViewController: UIViewController, SearchViewInput {
    var presenter: SearchViewOutput!

    private var recentItems: [String] = []
    private var legacyButtonBottomConstraint: NSLayoutConstraint!

    private lazy var legacySearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Search", for: .normal)
        let bodyDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let semiboldDescriptor = bodyDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.semibold]
        ])

        button.titleLabel?.font = UIFont(descriptor: semiboldDescriptor, size: 0)

        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.filled()
            cfg.baseBackgroundColor = DSColor.accent
            cfg.baseForegroundColor = .white
            cfg.cornerStyle = .medium
            cfg.contentInsets = NSDirectionalEdgeInsets(
                top: 14, leading: 20, bottom: 14, trailing: 20)
            button.configuration = cfg
        } else {
            button.backgroundColor = DSColor.accent
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        }

        button.addTarget(self, action: #selector(didTapLegacySearchButton), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: CellIdentifier.recentCell)

        tableView.backgroundColor = .systemGroupedBackground

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchBar.placeholder = Strings.searchPlaceholder
        sc.searchBar.backgroundColor = nil
        sc.searchBar.barTintColor = nil
        sc.searchBar.searchTextField.tintColor = DSColor.accent
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.delegate = self
        sc.delegate = self
        sc.hidesNavigationBarDuringPresentation = false
        return sc
    }()

    private lazy var emptyView: DSListEmptyView = {
        let view = DSListEmptyView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private lazy var errorView: DSErrorView = {
        let view = DSErrorView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.onRetry = { [weak self] in
            self?.resetToIdleAndFocusSearch()
        }
        return view
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
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
        setupKeyboardObserversIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        runSwipeTutorialIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    deinit {
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(
            self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func setupUI() {
        title = Strings.title
        navigationItem.largeTitleDisplayMode = .always

        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(emptyView)
        view.addSubview(errorView)

        view.addSubview(legacySearchButton)
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

            errorView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            errorView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            errorView.leadingAnchor.constraint(
                greaterThanOrEqualTo: safeArea.leadingAnchor, constant: DSSpacing.x4),
            errorView.trailingAnchor.constraint(
                lessThanOrEqualTo: safeArea.trailingAnchor, constant: -DSSpacing.x4),
        ])

        setupLegacyButtonConstraints()

        if #available(iOS 15, *) {
            legacySearchButton.isHidden = true
        }
    }

    private func setupLegacyButtonConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        legacyButtonBottomConstraint = legacySearchButton.bottomAnchor.constraint(
            equalTo: safeArea.bottomAnchor, constant: -DSSpacing.x4)

        NSLayoutConstraint.activate([
            legacySearchButton.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor, constant: DSSpacing.x4),
            legacySearchButton.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor, constant: -DSSpacing.x4),
            legacyButtonBottomConstraint,
        ])
    }

    @objc private func didTapLegacySearchButton() {
        let query = searchController.searchBar.text ?? ""
        presenter.didTapSearchButton(query: query)
    }

    private func showOverlay(for state: SearchState) {
        spinner.stopAnimating()
        spinner.isHidden = true
        emptyView.isHidden = true
        errorView.isHidden = true

        switch state {
        case .idle:
            emptyView.configure(Strings.hintStart)
            emptyView.isHidden = false

        case .loading:
            spinner.isHidden = false
            spinner.startAnimating()

        case .recent(let terms) where terms.isEmpty:
            emptyView.configure(Strings.hintNoRecent)
            emptyView.isHidden = false

        case .recent:
            break

        case .empty(let message):
            let msg =
                message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? Strings.hintNoRecent : message
            emptyView.configure(msg)
            emptyView.isHidden = false

        case .error(let message):
            let msg =
                message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? Strings.errorGeneric : message
            errorView.configure(message: msg)
            errorView.isHidden = false
        }
    }

    private func resetToIdleAndFocusSearch() {
        DispatchQueue.main.async {
            self.searchController.searchBar.text = ""
            self.presenter.didChangeQueryClear(text: "")
            self.showOverlay(for: .idle)
            self.tableView.setContentOffset(.zero, animated: false)
            self.view.endEditing(true)

            if self.searchController.isActive == false {
                self.searchController.isActive = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let tf = self.searchController.searchBar.searchTextField
                tf.resignFirstResponder()
                tf.becomeFirstResponder()
            }
        }
    }

    func render(_ state: SearchState) {
        if case .recent(let terms) = state {
            recentItems = terms
        } else {
            recentItems = []
        }

        showOverlay(for: state)
        tableView.reloadData()
    }

    func setSearchText(_ text: String) {
        searchController.searchBar.text = text
        searchController.isActive = true
    }

    func dismissSearch() {
        if searchController.isActive {
            searchController.isActive = false
        } else {
            presenter.searchDidDismiss()
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        presenter.searchDidDismiss()
    }

    private func setupKeyboardObserversIfNeeded() {
        if #unavailable(iOS 26) {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification,
                object: nil)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification,
                object: nil)
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?
                .cgRectValue,
            let duration =
                (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
                .doubleValue
        else { return }

        let keyboardHeight = keyboardFrame.height
        let newConstant = -(keyboardHeight - view.safeAreaInsets.bottom + DSSpacing.x2)

        UIView.animate(withDuration: duration) {
            self.legacyButtonBottomConstraint.constant = newConstant
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let duration =
                (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?
                .doubleValue
        else { return }

        let originalConstant = -DSSpacing.x4

        UIView.animate(withDuration: duration) {
            self.legacyButtonBottomConstraint.constant = originalConstant
            self.view.layoutIfNeeded()
        }
    }
}

extension SearchViewController: UISearchBarDelegate, UISearchControllerDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        presenter.didTapSearchButton(query: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.didChangeQuery(text: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter.didChangeQueryClear(text: "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !recentItems.isEmpty else { return nil }

        let header = UITableViewHeaderFooterView(reuseIdentifier: CellIdentifier.header)
        var c: UIListContentConfiguration

        if #available(iOS 18.0, *) {
            c = UIListContentConfiguration.header()
        } else {
            c = UIListContentConfiguration.plainHeader()
        }

        c.text = Strings.headerRecent
        c.textProperties.font = DSTypo.body
        c.textProperties.color = DSColor.textSecondary
        header.contentConfiguration = c
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        recentItems.isEmpty ? 0 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recentItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellIdentifier.recentCell, for: indexPath) as? RecentSearchCell
        else {
            return UITableViewCell()
        }

        guard !recentItems.isEmpty, indexPath.row < recentItems.count else {
            return cell
        }

        cell.configure(with: recentItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < recentItems.count else { return }
        presenter.didSelectRow(indexPath.row)
    }

    func tableView(
        _ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard !self.recentItems.isEmpty, indexPath.row < self.recentItems.count else {
            return nil
        }
        let favoriteAction = UIContextualAction(style: .normal, title: Strings.favoriteActionTitle)
        { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            let termToFavorite = self.recentItems[indexPath.row]
            self.presenter.didTapFavoriteRecentSearch(term: termToFavorite)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            completion(true)
        }
        favoriteAction.backgroundColor = DSColor.favoriteGreen
        favoriteAction.image = UIImage(systemName: "star.fill")
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }

    func tableView(
        _ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        guard !self.recentItems.isEmpty, indexPath.row < self.recentItems.count else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: Strings.deleteActionTitle)
        { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }

            let termToDelete = self.recentItems[indexPath.row]
            self.recentItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.presenter.didDeleteRecentSearch(term: termToDelete)

            if self.recentItems.isEmpty {
                self.showOverlay(for: .recent(self.recentItems))
            }

            completion(true)
        }

        deleteAction.backgroundColor = DSColor.accent
        deleteAction.image = UIImage(systemName: "trash.fill")

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    private static var hasShownTutorial = false

    private func runSwipeTutorialIfNeeded() {
        guard !SearchViewController.hasShownTutorial,
            !recentItems.isEmpty
        else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) else {
                return
            }

            SearchViewController.hasShownTutorial = true

            self.performProfessionalSwipeTutorial(on: cell)
        }
    }

    private func performProfessionalSwipeTutorial(on cell: UITableViewCell) {
        let moveDistance: CGFloat = 85.0
        let cellHeight = cell.bounds.height
        let cellWidth = cell.bounds.width
        let iconSize: CGFloat = 28
        let labelHeight: CGFloat = 14

        let swipeDuration: TimeInterval = 0.55
        let holdDuration: TimeInterval = 0.8
        let returnDuration: TimeInterval = 0.45
        let betweenSwipeDelay: TimeInterval = 0.3
        let springDamping: CGFloat = 0.72
        let springVelocity: CGFloat = 0.3


        let favView = UIView()
        favView.backgroundColor = DSColor.favoriteGreen
        favView.frame = CGRect(x: 0, y: 0, width: moveDistance, height: cellHeight)
        favView.clipsToBounds = true

        let favGradient = CAGradientLayer()
        favGradient.colors = [
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor,
        ]
        favGradient.locations = [0.0, 0.5]
        favGradient.frame = favView.bounds
        favView.layer.insertSublayer(favGradient, at: 0)

        let favIconContainer = UIView()
        favIconContainer.frame = CGRect(
            x: (moveDistance - iconSize) / 2,
            y: (cellHeight - iconSize - labelHeight - 4) / 2,
            width: iconSize,
            height: iconSize
        )
        favView.addSubview(favIconContainer)

        let favIcon = UIImageView(
            image: UIImage(systemName: "star.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)))
        favIcon.tintColor = .white
        favIcon.contentMode = .scaleAspectFit
        favIcon.frame = favIconContainer.bounds
        favIcon.alpha = 0
        favIcon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        favIconContainer.addSubview(favIcon)

        let favLabel = UILabel()
        favLabel.text = "Favorite"
        favLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        favLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        favLabel.textAlignment = .center
        favLabel.frame = CGRect(
            x: 0,
            y: favIconContainer.frame.maxY + 4,
            width: moveDistance,
            height: labelHeight
        )
        favLabel.alpha = 0
        favView.addSubview(favLabel)


        let delView = UIView()
        delView.backgroundColor = DSColor.accent
        delView.frame = CGRect(
            x: cellWidth - moveDistance, y: 0, width: moveDistance, height: cellHeight)
        delView.clipsToBounds = true

        let delGradient = CAGradientLayer()
        delGradient.colors = [
            UIColor.white.withAlphaComponent(0.2).cgColor,
            UIColor.clear.cgColor,
        ]
        delGradient.locations = [0.0, 0.5]
        delGradient.frame = delView.bounds
        delView.layer.insertSublayer(delGradient, at: 0)

        let delIconContainer = UIView()
        delIconContainer.frame = CGRect(
            x: (moveDistance - iconSize) / 2,
            y: (cellHeight - iconSize - labelHeight - 4) / 2,
            width: iconSize,
            height: iconSize
        )
        delView.addSubview(delIconContainer)

        let delIcon = UIImageView(
            image: UIImage(systemName: "trash.fill")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)))
        delIcon.tintColor = .white
        delIcon.contentMode = .scaleAspectFit
        delIcon.frame = delIconContainer.bounds
        delIcon.alpha = 0
        delIcon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        delIconContainer.addSubview(delIcon)

        let delLabel = UILabel()
        delLabel.text = "Delete"
        delLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        delLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        delLabel.textAlignment = .center
        delLabel.frame = CGRect(
            x: 0,
            y: delIconContainer.frame.maxY + 4,
            width: moveDistance,
            height: labelHeight
        )
        delLabel.alpha = 0
        delView.addSubview(delLabel)


        cell.insertSubview(favView, belowSubview: cell.contentView)
        cell.insertSubview(delView, belowSubview: cell.contentView)

        cell.contentView.layer.shadowColor = UIColor.black.cgColor
        cell.contentView.layer.shadowOffset = .zero
        cell.contentView.layer.shadowRadius = 0
        cell.contentView.layer.shadowOpacity = 0


        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        UIView.animate(
            withDuration: swipeDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            cell.contentView.transform = CGAffineTransform(translationX: moveDistance, y: 0)
            cell.contentView.layer.shadowRadius = 8
            cell.contentView.layer.shadowOpacity = 0.15
        }

        UIView.animate(
            withDuration: 0.4,
            delay: swipeDuration * 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8
        ) {
            favIcon.alpha = 1
            favIcon.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: swipeDuration * 0.5) {
            favLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + swipeDuration) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        let step2Delay = swipeDuration + holdDuration

        UIView.animate(
            withDuration: returnDuration,
            delay: step2Delay,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut]
        ) {
            cell.contentView.transform = .identity
            cell.contentView.layer.shadowRadius = 0
            cell.contentView.layer.shadowOpacity = 0
        }

        UIView.animate(withDuration: 0.2, delay: step2Delay) {
            favIcon.alpha = 0
            favIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            favLabel.alpha = 0
        }

        let step3Delay = step2Delay + returnDuration + betweenSwipeDelay

        UIView.animate(
            withDuration: swipeDuration,
            delay: step3Delay,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [.curveEaseOut, .allowUserInteraction]
        ) {
            cell.contentView.transform = CGAffineTransform(translationX: -moveDistance, y: 0)
            cell.contentView.layer.shadowRadius = 8
            cell.contentView.layer.shadowOpacity = 0.15
        }

        UIView.animate(
            withDuration: 0.4,
            delay: step3Delay + swipeDuration * 0.3,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8
        ) {
            delIcon.alpha = 1
            delIcon.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: step3Delay + swipeDuration * 0.5) {
            delLabel.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + step3Delay + swipeDuration) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        let step4Delay = step3Delay + swipeDuration + holdDuration

        UIView.animate(
            withDuration: returnDuration,
            delay: step4Delay,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.2,
            options: [.curveEaseInOut]
        ) {
            cell.contentView.transform = .identity
            cell.contentView.layer.shadowRadius = 0
            cell.contentView.layer.shadowOpacity = 0
        }

        UIView.animate(withDuration: 0.2, delay: step4Delay) {
            delIcon.alpha = 0
            delIcon.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            delLabel.alpha = 0
        }

        let totalDuration = step4Delay + returnDuration + 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            UIView.animate(withDuration: 0.2) {
                favView.alpha = 0
                delView.alpha = 0
            } completion: { _ in
                favView.removeFromSuperview()
                delView.removeFromSuperview()
                cell.contentView.layer.shadowOpacity = 0

                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}

private final class RecentSearchCell: UITableViewCell {
    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.textSecondary.withAlphaComponent(0.5)
        var cfg = UIImage.SymbolConfiguration(weight: .semibold)
        iv.preferredSymbolConfiguration = cfg
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .none
        backgroundColor = nil
        backgroundConfiguration = nil

        contentView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -DSSpacing.x4),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    func configure(with term: String) {
        var cfg = defaultContentConfiguration()
        cfg.text = term
        cfg.textProperties.font = DSTypo.body
        cfg.textProperties.color = DSColor.textSecondary
        cfg.image = UIImage(systemName: "clock.arrow.circlepath")
        cfg.imageProperties.tintColor = DSColor.accent
        cfg.imageToTextPadding = DSSpacing.x2


        contentConfiguration = cfg
        backgroundConfiguration = nil
        contentView.backgroundColor = .secondarySystemGroupedBackground
    }
}

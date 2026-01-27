//
//  SearchViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Combine
import UIKit

protocol SearchViewInput: AnyObject {
    func render(_ state: SearchState)
    func setSearchText(_ text: String)
    func dismissSearch()
}

final class SearchViewController: UIViewController, SearchViewInput {
    var presenter: SearchViewOutput!

    private var cancellables = Set<AnyCancellable>()
    private var isRecording = false

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
        let tableView = UITableView(frame: .zero, style: .grouped)  // Grouped for headers
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: CellIdentifier.recentCell)

        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none  // No separators for cards

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
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

        // Setup Mic Button
        sc.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        sc.searchBar.showsBookmarkButton = true

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
        if isRecording {
            stopRecording()
        }
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        SpeechManager.shared.requestPermissions { [weak self] allowed in
            guard let self = self, allowed else {
                // Handle permission denied (show alert)
                return
            }

            do {
                try SpeechManager.shared.startRecording()
                self.isRecording = true
                self.searchController.searchBar.setImage(
                    UIImage(systemName: "stop.circle.fill"), for: .bookmark, state: .normal)
                self.searchController.searchBar.placeholder = "Listening..."

                SpeechManager.shared.recognizedTextPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] text in
                        self?.searchController.searchBar.text = text
                        self?.presenter.didChangeQuery(text: text)
                    }
                    .store(in: &self.cancellables)
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }

    private func stopRecording() {
        SpeechManager.shared.stopRecording()
        isRecording = false
        searchController.searchBar.setImage(
            UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        searchController.searchBar.placeholder = Strings.searchPlaceholder
        cancellables.removeAll()
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

        let cardHeight = cellHeight - 12
        let cardY: CGFloat = 6

        let favView = UIView()
        favView.backgroundColor = DSColor.favoriteGreen
        // Frame at "Revealed" position (x=16)
        favView.frame = CGRect(x: 16, y: cardY, width: moveDistance, height: cardHeight)

        // Start "Tucked" behind the card (Shifted Left)
        favView.transform = CGAffineTransform(translationX: -moveDistance, y: 0)

        favView.clipsToBounds = true
        favView.layer.cornerRadius = 20
        // Match card corners
        favView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner,
        ]

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
            y: (cardHeight - iconSize - labelHeight - 4) / 2,
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
        favLabel.text = Strings.favoriteActionTitle
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
        // Frame at "Revealed" position (Right side)
        delView.frame = CGRect(
            x: cellWidth - 16 - moveDistance, y: cardY, width: moveDistance, height: cardHeight)

        // Start "Tucked" behind the card (Shifted Right)
        delView.transform = CGAffineTransform(translationX: moveDistance, y: 0)
        delView.alpha = 0  // Initially hidden (Wait for second swipe)

        delView.clipsToBounds = true
        delView.layer.cornerRadius = 20
        delView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner,
        ]

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
            y: (cardHeight - iconSize - labelHeight - 4) / 2,
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
        delLabel.text = Strings.deleteActionTitle
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

        // Fix Z-Ordering: Insert into contentView at index 0 (Back)
        cell.contentView.insertSubview(favView, at: 0)
        cell.contentView.insertSubview(delView, at: 0)

        // Ensure card background is opaque (it is DSColor.surface, so it should cover)

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
            // Animate card container Right
            if let recentCell = cell as? RecentSearchCell {
                recentCell.cardContainer.transform = CGAffineTransform(
                    translationX: moveDistance, y: 0)
            } else {
                cell.contentView.transform = CGAffineTransform(translationX: moveDistance, y: 0)
            }
            // Animate FavView along with it (into view)
            favView.transform = .identity
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
            if let recentCell = cell as? RecentSearchCell {
                recentCell.cardContainer.transform = .identity
            } else {
                cell.contentView.transform = .identity
                cell.contentView.layer.shadowRadius = 0
                cell.contentView.layer.shadowOpacity = 0
            }
            // Animate FavView back out
            favView.transform = CGAffineTransform(translationX: -moveDistance, y: 0)
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
            if let recentCell = cell as? RecentSearchCell {
                recentCell.cardContainer.transform = CGAffineTransform(
                    translationX: -moveDistance, y: 0)
            } else {
                cell.contentView.transform = CGAffineTransform(translationX: -moveDistance, y: 0)
                cell.contentView.layer.shadowRadius = 8
                cell.contentView.layer.shadowOpacity = 0.15
            }
            // Switch active view visibility
            favView.alpha = 0
            delView.alpha = 1

            // Animate DelView along with it (into view)
            delView.transform = .identity
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
            if let recentCell = cell as? RecentSearchCell {
                recentCell.cardContainer.transform = .identity
            } else {
                cell.contentView.transform = .identity
                cell.contentView.layer.shadowRadius = 0
                cell.contentView.layer.shadowOpacity = 0
            }
            // Animate DelView back out
            delView.transform = CGAffineTransform(translationX: moveDistance, y: 0)
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

                // Reset card shadow
                if let recentCell = cell as? RecentSearchCell {
                    recentCell.cardContainer.layer.shadowOpacity = 0.06
                }

                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
}

private final class RecentSearchCell: UITableViewCell {

    // Exposed for animation
    lazy var cardContainer: UIView = {
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

    private lazy var iconContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DSColor.accent.withAlphaComponent(0.12)
        container.layer.cornerRadius = 18  // Squircle
        return container
    }()

    private lazy var iconView: UIImageView = {
        let iv = UIImageView(
            image: UIImage(systemName: "clock.arrow.circlepath")?
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = DSColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var wordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = DSTypo.body
        label.textColor = DSColor.textSecondary
        label.numberOfLines = 1
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.textSecondary.withAlphaComponent(0.4)
        var cfg = UIImage.SymbolConfiguration(weight: .bold)
        iv.preferredSymbolConfiguration = cfg
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
        accessoryType = .none
        backgroundColor = .clear

        contentView.addSubview(cardContainer)
        cardContainer.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        cardContainer.addSubview(wordLabel)
        cardContainer.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            // Card
            cardContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 72),

            // Icon
            iconContainer.leadingAnchor.constraint(
                equalTo: cardContainer.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),

            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            // Text
            wordLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            wordLabel.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            wordLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),

            // Chevron
            chevronImageView.trailingAnchor.constraint(
                equalTo: cardContainer.trailingAnchor, constant: -20),
            chevronImageView.centerYAnchor.constraint(equalTo: cardContainer.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    func configure(with term: String) {
        wordLabel.text = term
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

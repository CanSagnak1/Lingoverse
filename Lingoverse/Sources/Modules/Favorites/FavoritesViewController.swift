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
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: "FavoriteCell")
        tableView.backgroundColor = .systemGroupedBackground
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var emptyView: DSListEmptyView = {
        let view = DSListEmptyView()
        view.backgroundColor = .clear
        view.isHidden = true
        view.configure(Strings.hintNoFavorites)
        return view
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.backgroundColor = .clear
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
    }
    
    private func setupUI() {
        title = Strings.favoritesTitle
        view.backgroundColor = .systemBackground
        
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
            emptyView.leadingAnchor.constraint(greaterThanOrEqualTo: safeArea.leadingAnchor, constant: DSSpacing.x4),
            emptyView.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor, constant: -DSSpacing.x4)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        cell.configure(with: favoriteItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didSelectRow(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: Strings.deleteActionTitle) { [weak self] (action, view, completion) in
            guard let self = self else {
                completion(false)
                return
            }
            self.presenter.didDeleteFavorite(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.backgroundColor = DSColor.accent
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

private final class FavoriteCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        accessoryType = .disclosureIndicator
        backgroundColor = nil
        backgroundConfiguration = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }
    
    func configure(with term: String) {
        var cfg = defaultContentConfiguration()
        cfg.text = term.capitalized
        cfg.textProperties.font = DSTypo.body
        cfg.textProperties.color = DSColor.textPrimary
        cfg.image = UIImage(systemName: "star.fill")
        cfg.imageProperties.tintColor = DSColor.accent
        cfg.imageToTextPadding = DSSpacing.x2
        contentConfiguration = cfg
        backgroundConfiguration = nil
    }
}

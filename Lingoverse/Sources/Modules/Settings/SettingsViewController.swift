//
//  SettingsViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol SettingsViewInput: AnyObject {
    func reloadData()
}

final class SettingsViewController: UIViewController, SettingsViewInput {

    var presenter: SettingsViewOutput!

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupThemeObserver()
    }

    private func setupUI() {
        title = Strings.settingsTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: ThemeManager.themeDidChangeNotification,
            object: nil
        )
    }

    @objc private func themeDidChange() {
        tableView.reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func reloadData() {
        title = Strings.settingsTitle
        tableView.reloadData()
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {

    enum Section: Int, CaseIterable {
        case appearance
        case language
        case general
        case cache
        case legal
        case about
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .appearance: return 1
        case .language: return 1
        case .general: return 1
        case .cache: return 1
        case .legal: return LegalDocumentType.allCases.count
        case .about: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .appearance: return Strings.settingsAppearance
        case .language: return Strings.settingsLanguage
        case .general: return Strings.settingsGeneral
        case .cache: return Strings.settingsData
        case .legal: return Strings.settingsLegal
        case .about: return Strings.settingsAbout
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        cell.selectionStyle = .default
        cell.accessoryType = .none

        switch Section(rawValue: indexPath.section) {
        case .appearance:
            let currentTheme = ThemeManager.shared.currentTheme
            config.text = Strings.settingsTheme
            config.secondaryText = currentTheme.rawValue
            config.image = UIImage(systemName: currentTheme.iconName)
            config.imageProperties.tintColor = DSColor.accent
            cell.accessoryType = .disclosureIndicator

        case .language:
            let currentLanguage = LocalizationManager.shared.currentLanguage
            config.text = Strings.settingsLanguageRow
            config.secondaryText = currentLanguage.displayName
            config.image = UIImage(systemName: "globe")
            config.imageProperties.tintColor = DSColor.accent
            cell.accessoryType = .disclosureIndicator

        case .general:
            config.text = Strings.settingsShowOnboarding
            config.image = UIImage(systemName: "book.pages")
            config.imageProperties.tintColor = DSColor.accent
            cell.accessoryType = .disclosureIndicator

        case .cache:
            config.text = Strings.settingsClearCache
            config.textProperties.color = DSColor.accent
            config.image = UIImage(systemName: "trash")
            config.imageProperties.tintColor = DSColor.accent

        case .legal:
            let documentType = LegalDocumentType.allCases[indexPath.row]
            config.text = documentType.localizedTitle
            config.image = UIImage(systemName: documentType.iconName)
            config.imageProperties.tintColor = DSColor.textSecondary
            cell.accessoryType = .disclosureIndicator

        case .about:
            config.text = Strings.settingsVersion
            config.image = UIImage(systemName: "info.circle")
            config.imageProperties.tintColor = DSColor.textSecondary
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            {
                config.secondaryText = "\(version) (\(build))"
            }
            cell.selectionStyle = .none

        default:
            break
        }

        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticManager.shared.selectionChanged()

        switch Section(rawValue: indexPath.section) {
        case .appearance:
            presenter.didTapTheme()

        case .language:
            presenter.didTapLanguage()

        case .general:
            presenter.didTapShowOnboarding()

        case .cache:
            presenter.didTapClearCache()

        case .legal:
            let documentType = LegalDocumentType.allCases[indexPath.row]
            presenter.didTapLegalDocument(documentType)

        default:
            break
        }
    }
}

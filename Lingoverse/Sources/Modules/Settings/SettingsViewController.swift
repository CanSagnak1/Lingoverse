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
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 56, bottom: 0, right: 0)
        tableView.rowHeight = 56
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

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = DSColor.textSecondary

        switch Section(rawValue: section) {
        case .appearance: label.text = Strings.settingsAppearance.uppercased()
        case .language: label.text = Strings.settingsLanguage.uppercased()
        case .general: label.text = Strings.settingsGeneral.uppercased()
        case .cache: label.text = Strings.settingsData.uppercased()
        case .legal: label.text = Strings.settingsLegal.uppercased()
        case .about: label.text = Strings.settingsAbout.uppercased()
        default: return nil
        }

        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsCell.identifier, for: indexPath) as? SettingsCell
        else {
            return UITableViewCell()
        }

        switch Section(rawValue: indexPath.section) {
        case .appearance:
            let currentTheme = ThemeManager.shared.currentTheme
            cell.configure(
                icon: currentTheme.iconName,
                iconColor: DSColor.accent,
                iconBackground: DSColor.accent.withAlphaComponent(0.12),
                title: Strings.settingsTheme,
                subtitle: currentTheme.rawValue,
                showDisclosure: true,
                isDestructive: false
            )

        case .language:
            let currentLanguage = LocalizationManager.shared.currentLanguage
            cell.configure(
                icon: "globe",
                iconColor: .systemBlue,
                iconBackground: UIColor.systemBlue.withAlphaComponent(0.12),
                title: Strings.settingsLanguageRow,
                subtitle: currentLanguage.displayName,
                showDisclosure: true,
                isDestructive: false
            )

        case .general:
            cell.configure(
                icon: "book.pages",
                iconColor: .systemOrange,
                iconBackground: UIColor.systemOrange.withAlphaComponent(0.12),
                title: Strings.settingsShowOnboarding,
                subtitle: nil,
                showDisclosure: true,
                isDestructive: false
            )

        case .cache:
            cell.configure(
                icon: "trash",
                iconColor: DSColor.accent,
                iconBackground: DSColor.accent.withAlphaComponent(0.12),
                title: Strings.settingsClearCache,
                subtitle: nil,
                showDisclosure: false,
                isDestructive: true
            )

        case .legal:
            let documentType = LegalDocumentType.allCases[indexPath.row]
            let colors: [UIColor] = [.systemPurple, .systemTeal, .systemPink]
            let color = colors[indexPath.row % colors.count]
            cell.configure(
                icon: documentType.iconName,
                iconColor: color,
                iconBackground: color.withAlphaComponent(0.12),
                title: documentType.localizedTitle,
                subtitle: nil,
                showDisclosure: true,
                isDestructive: false
            )

        case .about:
            var versionText: String? = nil
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            {
                versionText = "\(version) (\(build))"
            }
            cell.configure(
                icon: "info.circle",
                iconColor: .systemGray,
                iconBackground: UIColor.systemGray.withAlphaComponent(0.12),
                title: Strings.settingsVersion,
                subtitle: versionText,
                showDisclosure: false,
                isDestructive: false
            )
            cell.selectionStyle = .none

        default:
            break
        }

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

// MARK: - Custom Settings Cell

private final class SettingsCell: UITableViewCell {

    static let identifier = "SettingsCell"

    private lazy var iconContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = DSColor.textPrimary
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .right
        return label
    }()

    private lazy var disclosureIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "chevron.right")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        iv.tintColor = DSColor.textSecondary.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError(Cammon.fatalError)
    }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        selectionStyle = .default

        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(disclosureIcon)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            disclosureIcon.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            disclosureIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureIcon.widthAnchor.constraint(equalToConstant: 12),

            subtitleLabel.trailingAnchor.constraint(
                equalTo: disclosureIcon.leadingAnchor, constant: -8),
            subtitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            subtitleLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
        ])
    }

    func configure(
        icon: String,
        iconColor: UIColor,
        iconBackground: UIColor,
        title: String,
        subtitle: String?,
        showDisclosure: Bool,
        isDestructive: Bool
    ) {
        iconContainer.backgroundColor = iconBackground
        iconImageView.image = UIImage(systemName: icon)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 15, weight: .medium))
        iconImageView.tintColor = iconColor

        titleLabel.text = title
        titleLabel.textColor = isDestructive ? DSColor.accent : DSColor.textPrimary

        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil

        disclosureIcon.isHidden = !showDisclosure

        selectionStyle = showDisclosure || isDestructive ? .default : .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.textColor = DSColor.textPrimary
        subtitleLabel.text = nil
        subtitleLabel.isHidden = true
        disclosureIcon.isHidden = false
        selectionStyle = .default
    }
}

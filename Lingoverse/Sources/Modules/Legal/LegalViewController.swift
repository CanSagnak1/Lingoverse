//
//  LegalViewController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

final class LegalViewController: UIViewController {

    private let documentType: LegalDocumentType

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var headerIconContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DSColor.accent.withAlphaComponent(0.12)
        container.layer.cornerRadius = 40
        return container
    }()

    private lazy var headerIcon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = DSColor.accent
        return iv
    }()

    private lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = DSColor.textPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var headerSubtitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = DSColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    init(documentType: LegalDocumentType) {
        self.documentType = documentType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError(Common.fatalError)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadContent()
    }

    private func setupUI() {
        title = documentType.localizedTitle
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }

    private func loadContent() {
        setupHeader()

        let sections = LegalContent.sections(for: documentType)
        for section in sections {
            let sectionView = createSectionView(section)
            contentStack.addArrangedSubview(sectionView)
        }

        if documentType == .acknowledgements {
            let footerLabel = UILabel()
            footerLabel.text = "© 2026 Lingoverse. All rights reserved."
            footerLabel.font = .systemFont(ofSize: 13, weight: .medium)
            footerLabel.textColor = DSColor.textSecondary
            footerLabel.textAlignment = .center
            contentStack.addArrangedSubview(footerLabel)
            contentStack.setCustomSpacing(32, after: contentStack.arrangedSubviews.last!)
        }
    }

    private func setupHeader() {
        headerView.addSubview(headerIconContainer)
        headerIconContainer.addSubview(headerIcon)
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerSubtitle)

        headerIcon.image = UIImage(systemName: documentType.iconName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 36, weight: .medium))
        headerTitle.text = documentType.localizedTitle
        headerSubtitle.text = LegalContent.lastUpdated(for: documentType)

        NSLayoutConstraint.activate([
            headerIconContainer.topAnchor.constraint(equalTo: headerView.topAnchor),
            headerIconContainer.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerIconContainer.widthAnchor.constraint(equalToConstant: 80),
            headerIconContainer.heightAnchor.constraint(equalToConstant: 80),

            headerIcon.centerXAnchor.constraint(equalTo: headerIconContainer.centerXAnchor),
            headerIcon.centerYAnchor.constraint(equalTo: headerIconContainer.centerYAnchor),

            headerTitle.topAnchor.constraint(
                equalTo: headerIconContainer.bottomAnchor, constant: 16),
            headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerTitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            headerSubtitle.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 6),
            headerSubtitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            headerSubtitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            headerSubtitle.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
        ])

        contentStack.addArrangedSubview(headerView)
        contentStack.setCustomSpacing(28, after: headerView)
    }

    private func createSectionView(_ section: LegalSection) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = DSColor.surface
        container.layer.cornerRadius = 16

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
        ])

        if let title = section.title {
            let titleStack = UIStackView()
            titleStack.axis = .horizontal
            titleStack.spacing = 10
            titleStack.alignment = .center

            if let icon = section.icon {
                let iconView = UIImageView()
                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconView.image = UIImage(systemName: icon)?
                    .withConfiguration(
                        UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
                iconView.tintColor = DSColor.accent
                iconView.contentMode = .scaleAspectFit
                NSLayoutConstraint.activate([
                    iconView.widthAnchor.constraint(equalToConstant: 24),
                    iconView.heightAnchor.constraint(equalToConstant: 24),
                ])
                titleStack.addArrangedSubview(iconView)
            }

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = DSColor.textPrimary
            titleLabel.numberOfLines = 0
            titleStack.addArrangedSubview(titleLabel)

            stack.addArrangedSubview(titleStack)
        }

        let contentLabel = UILabel()
        contentLabel.text = section.content
        contentLabel.font = .systemFont(ofSize: 15, weight: .regular)
        contentLabel.textColor = DSColor.textSecondary
        contentLabel.numberOfLines = 0

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5

        let attributedText = NSAttributedString(
            string: section.content,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: DSColor.textSecondary,
                .paragraphStyle: paragraphStyle,
            ]
        )
        contentLabel.attributedText = attributedText

        stack.addArrangedSubview(contentLabel)

        return container
    }
}

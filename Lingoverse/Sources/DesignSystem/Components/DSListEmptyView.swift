//
//  DSListEmptyView.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

public final class DSListEmptyView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let contentStack = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = .init(pointSize: 36, weight: .regular)
        iconView.tintColor = DSColor.textSecondary
        iconView.image = UIImage(systemName: "doc.text.magnifyingglass")
        iconView.isAccessibilityElement = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.textColor = DSColor.textPrimary
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .header
        titleLabel.isHidden = true

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = DSColor.textSecondary
        descriptionLabel.font = DSTypo.body
        descriptionLabel.numberOfLines = 0
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.accessibilityTraits = .staticText

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .fill
        contentStack.spacing = DSSpacing.x2
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(descriptionLabel)

        contentStack.setCustomSpacing(DSSpacing.x3, after: iconView)

        addSubview(contentStack)
        directionalLayoutMargins = .init(
            top: DSSpacing.x2, leading: DSSpacing.x4, bottom: DSSpacing.x2, trailing: DSSpacing.x4)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            contentStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(
                lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(
                lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            iconView.widthAnchor.constraint(lessThanOrEqualToConstant: 72),
            iconView.heightAnchor.constraint(lessThanOrEqualToConstant: 72),
        ])
    }

    public func configure(_ text: String) {
        descriptionLabel.text = text
        descriptionLabel.accessibilityLabel = text
        titleLabel.isHidden = true
    }

    public func configure(title: String, description: String) {
        titleLabel.text = title
        titleLabel.isHidden = false
        descriptionLabel.text = description
        descriptionLabel.accessibilityLabel = description
    }

    public func configure(title: String, description: String, icon: String) {
        titleLabel.text = title
        titleLabel.isHidden = false
        descriptionLabel.text = description
        descriptionLabel.accessibilityLabel = description
        iconView.image = UIImage(systemName: icon)
    }

    required init?(coder: NSCoder) { fatalError(Cammon.fatalError) }
}

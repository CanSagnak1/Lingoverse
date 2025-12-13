//
//  DSListEmptyView.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

public final class DSListEmptyView: UIView {
    private let iconView = UIImageView()
    private let label = UILabel()
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

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = DSColor.textSecondary
        label.font = DSTypo.body
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityTraits = .staticText

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .fill
        contentStack.spacing = DSSpacing.x3
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(label)

        addSubview(contentStack)
        directionalLayoutMargins = .init(top: DSSpacing.x2, leading: DSSpacing.x4, bottom: DSSpacing.x2, trailing: DSSpacing.x4)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            iconView.widthAnchor.constraint(lessThanOrEqualToConstant: 72),
            iconView.heightAnchor.constraint(lessThanOrEqualToConstant: 72)
        ])
    }

    public func configure(_ text: String) {
        label.text = text
        label.accessibilityLabel = text
    }

    required init?(coder: NSCoder) { fatalError(Cammon.fatalError) }
}

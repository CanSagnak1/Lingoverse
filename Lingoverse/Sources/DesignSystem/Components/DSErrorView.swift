//
//  DSErrorView.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

final class DSErrorView: UIView {
    var onRetry: (() -> Void)?

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let contentStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.preferredSymbolConfiguration = .init(pointSize: 40, weight: .regular)
        iconView.tintColor = DSColor.textSecondary
        iconView.isAccessibilityElement = false
        iconView.image = UIImage(systemName: "exclamationmark.triangle")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = DSTypo.body
        titleLabel.textColor = DSColor.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits = .staticText

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
        retryButton.setTitle(Strings.retryButtonLabel, for: .normal)
        retryButton.titleLabel?.font = DSTypo.body

        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.borderedProminent()
            cfg.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
            cfg.cornerStyle = .large
            retryButton.configuration = cfg
        } else {
            retryButton.contentEdgeInsets = .init(top: 8, left: 14, bottom: 8, right: 14)
            retryButton.layer.cornerRadius = 10
            retryButton.layer.masksToBounds = true
        }

        contentStack.axis = .vertical
        contentStack.alignment = .center
        contentStack.distribution = .fill
        contentStack.spacing = DSSpacing.x3
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(iconView)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(DSSpacing.x3, after: titleLabel)
        contentStack.addArrangedSubview(retryButton)

        addSubview(contentStack)
        directionalLayoutMargins = .init(top: DSSpacing.x2, leading: DSSpacing.x4, bottom: DSSpacing.x2, trailing: DSSpacing.x4)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
            contentStack.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),
            
            iconView.widthAnchor.constraint(lessThanOrEqualToConstant: 72),
            iconView.heightAnchor.constraint(lessThanOrEqualToConstant: 72),
            
            retryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])
    }

    func configure(message: String) {
        titleLabel.text = message
        titleLabel.accessibilityLabel = message
    }

    @objc private func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onRetry?()
    }

    required init?(coder: NSCoder) { fatalError(Cammon.fatalError) }
}

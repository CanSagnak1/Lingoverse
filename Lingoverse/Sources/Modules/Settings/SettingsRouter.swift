//
//  SettingsRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol SettingsRouterProtocol {
    func showThemePicker(from vc: UIViewController)
    func showOnboarding(from vc: UIViewController)
    func showLegalDocument(_ type: LegalDocumentType, from vc: UIViewController)
}

final class SettingsRouter: SettingsRouterProtocol {

    static func createModule() -> UIViewController {
        let view = SettingsViewController()
        let router = SettingsRouter()
        let presenter = SettingsPresenter(view: view, router: router)
        view.presenter = presenter
        return view
    }

    func showThemePicker(from vc: UIViewController) {
        let alert = UIAlertController(
            title: "Choose Theme",
            message: "Select your preferred appearance",
            preferredStyle: .actionSheet
        )

        for theme in AppTheme.allCases {
            let action = UIAlertAction(title: theme.rawValue, style: .default) { _ in
                HapticManager.shared.selectionChanged()
                ThemeManager.shared.currentTheme = theme
            }

            // Add checkmark to current theme
            if theme == ThemeManager.shared.currentTheme {
                action.setValue(true, forKey: "checked")
            }

            // Add icon
            if let image = UIImage(systemName: theme.iconName) {
                action.setValue(image, forKey: "image")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        vc.present(alert, animated: true)
    }

    func showOnboarding(from vc: UIViewController) {
        guard let window = vc.view.window else { return }

        let onboardingVC = OnboardingRouter.createModule(window: window)
        onboardingVC.modalPresentationStyle = .fullScreen
        onboardingVC.modalTransitionStyle = .crossDissolve

        vc.present(onboardingVC, animated: true)
    }

    func showLegalDocument(_ type: LegalDocumentType, from vc: UIViewController) {
        let legalVC = LegalViewController(documentType: type)
        vc.navigationController?.pushViewController(legalVC, animated: true)
    }
}

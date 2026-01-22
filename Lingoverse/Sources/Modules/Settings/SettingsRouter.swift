//
//  SettingsRouter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol SettingsRouterProtocol {
    func showThemePicker(from vc: UIViewController)
    func showLanguagePicker(from vc: UIViewController)
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

            if theme == ThemeManager.shared.currentTheme {
                action.setValue(true, forKey: "checked")
            }

            if let image = UIImage(systemName: theme.iconName) {
                action.setValue(image, forKey: "image")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: Strings.cancelButton, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        vc.present(alert, animated: true)
    }

    func showLanguagePicker(from vc: UIViewController) {
        let alert = UIAlertController(
            title: Strings.settingsSelectLanguage,
            message: nil,
            preferredStyle: .actionSheet
        )

        for language in AppLanguage.allCases {
            let action = UIAlertAction(title: language.displayName, style: .default) {
                [weak vc] _ in
                HapticManager.shared.selectionChanged()

                guard language != LocalizationManager.shared.currentLanguage else { return }

                LocalizationManager.shared.setLanguage(language)

                self.showRestartAlert(from: vc)
            }

            if language == LocalizationManager.shared.currentLanguage {
                action.setValue(true, forKey: "checked")
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: Strings.cancelButton, style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = vc.view
            popover.sourceRect = CGRect(
                x: vc.view.bounds.midX, y: vc.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        vc.present(alert, animated: true)
    }

    private func showRestartAlert(from vc: UIViewController?) {
        guard let vc = vc else { return }

        let alert = UIAlertController(
            title: Strings.settingsRestartRequired,
            message: Strings.settingsRestartMessage,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: Strings.settingsRestartNow, style: .default) { _ in
                // Get SceneDelegate and restart app smoothly
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate
                {
                    sceneDelegate.restartApplication()
                }
            })

        alert.addAction(
            UIAlertAction(title: Strings.cancelButton, style: .cancel) { _ in
                (vc as? SettingsViewInput)?.reloadData()
            })

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

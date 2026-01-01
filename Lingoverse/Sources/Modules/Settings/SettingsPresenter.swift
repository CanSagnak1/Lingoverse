//
//  SettingsPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

protocol SettingsViewOutput: AnyObject {
    func didTapTheme()
    func didTapShowOnboarding()
    func didTapClearCache()
    func didTapLegalDocument(_ type: LegalDocumentType)
}

final class SettingsPresenter: SettingsViewOutput {

    private weak var view: SettingsViewInput?
    private let router: SettingsRouterProtocol
    private let cacheManager: CacheManagerProtocol

    init(
        view: SettingsViewInput,
        router: SettingsRouterProtocol,
        cacheManager: CacheManagerProtocol = CacheManager.shared
    ) {
        self.view = view
        self.router = router
        self.cacheManager = cacheManager
    }

    func didTapTheme() {
        guard let vc = view as? UIViewController else { return }
        router.showThemePicker(from: vc)
    }

    func didTapShowOnboarding() {
        guard let vc = view as? UIViewController else { return }
        router.showOnboarding(from: vc)
    }

    func didTapClearCache() {
        Task {
            await cacheManager.clearCache()
            await MainActor.run {
                HapticManager.shared.success()
                guard let vc = view as? UIViewController else { return }
                let alert = UIAlertController(
                    title: nil,
                    message: "Cache cleared successfully",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                vc.present(alert, animated: true)
            }
        }
    }

    func didTapLegalDocument(_ type: LegalDocumentType) {
        guard let vc = view as? UIViewController else { return }
        router.showLegalDocument(type, from: vc)
    }
}

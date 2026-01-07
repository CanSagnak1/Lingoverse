//
//  MainTabBarController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureTabBarAppearance()
    }

    // MARK: - Setup

    private func setupTabs() {
        let searchTab = makeSearchTab()
        let learnTab = makeLearnTab()
        let favoritesTab = makeFavoritesTab()
        let settingsTab = makeSettingsTab()

        viewControllers = [searchTab, learnTab, favoritesTab, settingsTab]
    }

    private func makeSearchTab() -> UINavigationController {
        let vc = SearchRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: Strings.title,
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func makeLearnTab() -> UINavigationController {
        let vc = LearnRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: "Learn",
            image: UIImage(systemName: "brain.head.profile"),
            selectedImage: UIImage(systemName: "brain.head.profile.fill")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func makeFavoritesTab() -> UINavigationController {
        let vc = FavoritesRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: Strings.favoritesTitle,
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func makeSettingsTab() -> UINavigationController {
        let vc = SettingsRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()

        // Normal state
        itemAppearance.normal.iconColor = DSColor.textSecondary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: DSColor.textSecondary,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Selected state
        itemAppearance.selected.iconColor = DSColor.accent
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: DSColor.accent,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        tabBar.tintColor = DSColor.accent
    }
}

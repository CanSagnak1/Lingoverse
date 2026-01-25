//
//  MainTabBarController.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        configureTabBarAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTabTitles()
    }

    private func updateTabTitles() {
        guard let items = tabBar.items, items.count == 5 else { return }
        items[0].title = Strings.tabSearch
        items[1].title = Strings.tabLearn
        items[2].title = Strings.tabFavorites
        items[3].title = Strings.profileTitle
        items[4].title = Strings.tabSettings
    }

    private func setupTabs() {
        let searchTab = makeSearchTab()
        let learnTab = makeLearnTab()
        let favoritesTab = makeFavoritesTab()
        let profileTab = makeProfileTab()
        let settingsTab = makeSettingsTab()

        viewControllers = [searchTab, learnTab, favoritesTab, profileTab, settingsTab]
    }

    private func makeSearchTab() -> UINavigationController {
        let vc = SearchRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: Strings.tabSearch,
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
            title: Strings.tabLearn,
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
            title: Strings.tabFavorites,
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func makeProfileTab() -> UINavigationController {
        let vc = ProfileRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: Strings.profileTitle,
            image: UIImage(systemName: "person.crop.circle"),
            selectedImage: UIImage(systemName: "person.crop.circle.fill")
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }

    private func makeSettingsTab() -> UINavigationController {
        let vc = SettingsRouter.createModule()
        vc.tabBarItem = UITabBarItem(
            title: Strings.tabSettings,
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

        let itemAppearance = UITabBarItemAppearance()

        itemAppearance.normal.iconColor = DSColor.textSecondary
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: DSColor.textSecondary,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
        ]

        itemAppearance.selected.iconColor = DSColor.accent
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: DSColor.accent,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
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

//
//  SceneDelegate.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

enum ApplicationRoot {
    static func makeRoot() -> UIViewController {
        return MainTabBarController()
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let winScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: winScene)
        let splashVC = SplashRouter.createModule(window: window)

        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        self.window = window

        ThemeManager.shared.applyCurrentTheme()
    }

    /// Restarts the application by transitioning to splash screen
    func restartApplication() {
        guard let window = window else { return }

        let splashVC = SplashRouter.createModule(window: window)

        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: {
                window.rootViewController = splashVC
            },
            completion: nil
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

}

//
//  ThemeManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

/// Manages app-wide theme settings
final class ThemeManager {

    static let shared = ThemeManager()

    private let userDefaults: UserDefaults
    private let themeKey = "app_theme"

    /// Notification posted when theme changes
    static let themeDidChangeNotification = Notification.Name("ThemeDidChangeNotification")

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    /// Current theme setting
    var currentTheme: AppTheme {
        get {
            guard let rawValue = userDefaults.string(forKey: themeKey),
                let theme = AppTheme(rawValue: rawValue)
            else {
                return .system
            }
            return theme
        }
        set {
            userDefaults.set(newValue.rawValue, forKey: themeKey)
            applyTheme(newValue)
            NotificationCenter.default.post(name: Self.themeDidChangeNotification, object: newValue)
        }
    }

    /// Apply theme to all windows
    func applyTheme(_ theme: AppTheme) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            else { return }

            UIView.animate(withDuration: 0.3) {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = theme.userInterfaceStyle
                }
            }
        }
    }

    /// Apply saved theme on app launch
    func applyCurrentTheme() {
        applyTheme(currentTheme)
    }

    /// Cycle to next theme
    func cycleTheme() {
        let allThemes = AppTheme.allCases
        guard let currentIndex = allThemes.firstIndex(of: currentTheme) else { return }
        let nextIndex = (currentIndex + 1) % allThemes.count
        currentTheme = allThemes[nextIndex]
    }
}

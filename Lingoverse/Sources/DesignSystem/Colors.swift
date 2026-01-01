//
//  Colors.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import UIKit

public enum DSColor {

    // MARK: - Backgrounds

    public static var background: UIColor {
        return .systemBackground
    }

    public static var surface: UIColor {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.1)
            } else {
                return UIColor.black.withAlphaComponent(0.05)
            }
        }
    }

    public static var splashBackground: UIColor {
        return .black
    }

    public static var searchBarBackground: UIColor {
        return .clear
    }

    // MARK: - Accent Colors

    /// Primary accent - WCAG AA compliant (4.5:1 contrast ratio on dark bg)
    public static var accent: UIColor {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.90, green: 0.35, blue: 0.35, alpha: 1.0)  // Brighter for dark mode
            } else {
                return UIColor(red: 0.745, green: 0.196, blue: 0.196, alpha: 1.0)
            }
        }
    }

    /// Favorite green - WCAG AA compliant
    public static var favoriteGreen: UIColor {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 0.45, green: 0.65, blue: 0.30, alpha: 1.0)  // Brighter for dark mode
            } else {
                return UIColor(red: 0.333, green: 0.420, blue: 0.184, alpha: 1.0)
            }
        }
    }

    // MARK: - Text Colors

    public static var textPrimary: UIColor {
        return .label
    }

    public static var textSecondary: UIColor {
        return .secondaryLabel
    }

    // MARK: - Overlays & Effects

    public static var dimOverlay: UIColor {
        return UIColor.black.withAlphaComponent(0.22)
    }

    public static var footerShadow: UIColor {
        return .black
    }

    public static var searchBarTint: UIColor {
        return .label
    }

    public static var clear: UIColor {
        return .clear
    }
}

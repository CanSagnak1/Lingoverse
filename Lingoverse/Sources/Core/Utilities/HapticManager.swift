//
//  HapticManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

/// Centralized haptic feedback manager for consistent tactile experience
final class HapticManager {

    static let shared = HapticManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    /// Prepare all generators for faster response
    func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        softImpact.prepare()
        rigidImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }

    // MARK: - Impact Feedback

    /// Light tap - for subtle UI interactions
    func lightTap() {
        lightImpact.impactOccurred()
    }

    /// Medium tap - for button presses
    func mediumTap() {
        mediumImpact.impactOccurred()
    }

    /// Heavy tap - for significant actions
    func heavyTap() {
        heavyImpact.impactOccurred()
    }

    /// Soft tap - for gentle feedback
    func softTap() {
        softImpact.impactOccurred()
    }

    /// Rigid tap - for firm feedback
    func rigidTap() {
        rigidImpact.impactOccurred()
    }

    // MARK: - Selection Feedback

    /// Selection changed - for picker/scroll selection changes
    func selectionChanged() {
        selectionFeedback.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success - for successful operations
    func success() {
        notificationFeedback.notificationOccurred(.success)
    }

    /// Warning - for warnings
    func warning() {
        notificationFeedback.notificationOccurred(.warning)
    }

    /// Error - for errors
    func error() {
        notificationFeedback.notificationOccurred(.error)
    }

    // MARK: - Contextual Haptics

    /// Haptic for search result found
    func searchResultFound() {
        success()
    }

    /// Haptic for search failed
    func searchFailed() {
        error()
    }

    /// Haptic for adding to favorites
    func addedToFavorites() {
        mediumTap()
    }

    /// Haptic for removing from favorites
    func removedFromFavorites() {
        lightTap()
    }

    /// Haptic for button press
    func buttonPressed() {
        lightTap()
    }

    /// Haptic for swipe action
    func swipeAction() {
        mediumTap()
    }

    /// Haptic for page change in onboarding
    func pageChanged() {
        selectionChanged()
    }

    /// Haptic for audio playback start
    func audioPlaybackStarted() {
        softTap()
    }

    /// Haptic for share action
    func shareAction() {
        mediumTap()
    }
}

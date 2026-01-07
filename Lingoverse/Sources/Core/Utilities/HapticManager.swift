//
//  HapticManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import UIKit

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

    func prepareGenerators() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        softImpact.prepare()
        rigidImpact.prepare()
        selectionFeedback.prepare()
        notificationFeedback.prepare()
    }


    func lightTap() {
        lightImpact.impactOccurred()
    }

    func mediumTap() {
        mediumImpact.impactOccurred()
    }

    func heavyTap() {
        heavyImpact.impactOccurred()
    }

    func softTap() {
        softImpact.impactOccurred()
    }

    func rigidTap() {
        rigidImpact.impactOccurred()
    }


    func selectionChanged() {
        selectionFeedback.selectionChanged()
    }


    func success() {
        notificationFeedback.notificationOccurred(.success)
    }

    func warning() {
        notificationFeedback.notificationOccurred(.warning)
    }

    func error() {
        notificationFeedback.notificationOccurred(.error)
    }


    func searchResultFound() {
        success()
    }

    func searchFailed() {
        error()
    }

    func addedToFavorites() {
        mediumTap()
    }

    func removedFromFavorites() {
        lightTap()
    }

    func buttonPressed() {
        lightTap()
    }

    func swipeAction() {
        mediumTap()
    }

    func pageChanged() {
        selectionChanged()
    }

    func audioPlaybackStarted() {
        softTap()
    }

    func shareAction() {
        mediumTap()
    }
}

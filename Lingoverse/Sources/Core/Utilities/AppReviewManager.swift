//
//  AppReviewManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import StoreKit
import UIKit

final class AppReviewManager {

    static let shared = AppReviewManager()

    private let userDefaults: UserDefaults
    private let searchCountKey = "app_review_search_count"
    private let hasRequestedReviewKey = "has_requested_review"
    private let lastVersionPromptedKey = "last_version_prompted"

    private let searchThreshold = 5

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func recordSuccessfulSearch() {
        let currentCount = userDefaults.integer(forKey: searchCountKey)
        let newCount = currentCount + 1
        userDefaults.set(newCount, forKey: searchCountKey)

        checkAndRequestReview()
    }

    private func checkAndRequestReview() {
        let searchCount = userDefaults.integer(forKey: searchCountKey)

        guard searchCount >= searchThreshold else { return }

        let currentVersion =
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastVersionPrompted = userDefaults.string(forKey: lastVersionPromptedKey) ?? ""

        guard currentVersion != lastVersionPrompted else { return }

        requestReview()

        userDefaults.set(currentVersion, forKey: lastVersionPromptedKey)
        userDefaults.set(true, forKey: hasRequestedReviewKey)
    }

    private func requestReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }

    func resetSearchCount() {
        userDefaults.set(0, forKey: searchCountKey)
        userDefaults.removeObject(forKey: lastVersionPromptedKey)
    }

    var currentSearchCount: Int {
        userDefaults.integer(forKey: searchCountKey)
    }
}

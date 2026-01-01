//
//  OnboardingPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import Foundation

protocol OnboardingViewOutput: AnyObject {
    func viewDidLoad()
    func didTapNext()
    func didTapSkip()
    func didTapGetStarted()
}

final class OnboardingPresenter: OnboardingViewOutput {

    private weak var view: OnboardingViewInput?
    private let router: OnboardingRouterProtocol

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            iconName: "magnifyingglass.circle.fill",
            title: "Search Words",
            description:
                "Instantly search for any English word and get comprehensive definitions, phonetics, and examples."
        ),
        OnboardingPage(
            iconName: "speaker.wave.3.fill",
            title: "Listen to Pronunciation",
            description: "Hear the correct pronunciation of words with built-in audio playback."
        ),
        OnboardingPage(
            iconName: "star.fill",
            title: "Save Favorites",
            description:
                "Build your personal vocabulary by saving words to your favorites list for quick access."
        ),
        OnboardingPage(
            iconName: "clock.arrow.circlepath",
            title: "Recent Searches",
            description: "Never lose track of your searches. Access your recent lookups anytime."
        ),
        OnboardingPage(
            iconName: "bolt.fill",
            title: "Fast & Offline",
            description:
                "Lightning-fast searches with offline caching. Previously searched words work without internet."
        ),
    ]

    init(view: OnboardingViewInput, router: OnboardingRouterProtocol) {
        self.view = view
        self.router = router
    }

    func viewDidLoad() {
        view?.configure(with: pages)
    }

    func didTapNext() {
        // Handled in ViewController
    }

    func didTapSkip() {
        completeOnboarding()
    }

    func didTapGetStarted() {
        completeOnboarding()
    }

    private func completeOnboarding() {
        OnboardingManager.shared.setOnboardingCompleted()
        router.navigateToMain()
    }
}

// MARK: - OnboardingPage Entity

struct OnboardingPage {
    let iconName: String
    let title: String
    let description: String
}

// MARK: - OnboardingManager

final class OnboardingManager {

    static let shared = OnboardingManager()

    private let userDefaults: UserDefaults
    private let hasSeenOnboardingKey = "has_seen_onboarding"

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasSeenOnboarding: Bool {
        userDefaults.bool(forKey: hasSeenOnboardingKey)
    }

    func setOnboardingCompleted() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
    }

    func resetOnboarding() {
        userDefaults.set(false, forKey: hasSeenOnboardingKey)
    }
}

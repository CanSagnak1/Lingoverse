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

    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                iconName: "magnifyingglass.circle.fill",
                title: Strings.onboardingSearchTitle,
                description: Strings.onboardingSearchDesc
            ),
            OnboardingPage(
                iconName: "graduationcap.fill",
                title: Strings.onboardingLearnTitle,
                description: Strings.onboardingLearnDesc
            ),
            OnboardingPage(
                iconName: "speaker.wave.3.fill",
                title: Strings.onboardingPronunciationTitle,
                description: Strings.onboardingPronunciationDesc
            ),
            OnboardingPage(
                iconName: "star.fill",
                title: Strings.onboardingFavoritesTitle,
                description: Strings.onboardingFavoritesDesc
            ),
            OnboardingPage(
                iconName: "clock.arrow.circlepath",
                title: Strings.onboardingRecentTitle,
                description: Strings.onboardingRecentDesc
            ),
            OnboardingPage(
                iconName: "bolt.fill",
                title: Strings.onboardingOfflineTitle,
                description: Strings.onboardingOfflineDesc
            ),
        ]
    }

    init(view: OnboardingViewInput, router: OnboardingRouterProtocol) {
        self.view = view
        self.router = router
    }

    func viewDidLoad() {
        view?.configure(with: pages)
    }

    func didTapNext() {
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

struct OnboardingPage {
    let iconName: String
    let title: String
    let description: String
}

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

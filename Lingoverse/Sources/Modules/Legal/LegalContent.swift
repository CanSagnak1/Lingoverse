//
//  LegalContent.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import Foundation

enum LegalDocumentType: String, CaseIterable {
    case privacyPolicy = "Privacy Policy"
    case termsOfUse = "Terms of Use"
    case acknowledgements = "Acknowledgements"

    var iconName: String {
        switch self {
        case .privacyPolicy: return "hand.raised.fill"
        case .termsOfUse: return "doc.text.fill"
        case .acknowledgements: return "heart.fill"
        }
    }

    var localizedTitle: String {
        switch self {
        case .privacyPolicy: return Strings.legalPrivacyPolicy
        case .termsOfUse: return Strings.legalTermsOfUse
        case .acknowledgements: return Strings.legalAcknowledgements
        }
    }
}

struct LegalSection {
    let title: String?
    let icon: String?
    let content: String

    init(title: String? = nil, icon: String? = nil, content: String) {
        self.title = title
        self.icon = icon
        self.content = content
    }
}

enum LegalContent {

    static func lastUpdated(for type: LegalDocumentType) -> String {
        switch type {
        case .privacyPolicy, .termsOfUse:
            return "Last Updated: January 25, 2026"
        case .acknowledgements:
            return "Thank you for using Lingoverse"
        }
    }

    static func sections(for type: LegalDocumentType) -> [LegalSection] {
        switch type {
        case .privacyPolicy:
            return privacyPolicySections
        case .termsOfUse:
            return termsOfUseSections
        case .acknowledgements:
            return acknowledgementsSections
        }
    }

    // MARK: - Privacy Policy Sections

    static let privacyPolicySections: [LegalSection] = [
        LegalSection(
            title: "Information We Collect",
            icon: "doc.text.magnifyingglass",
            content: """
                We collect minimal information to provide you with the best experience:

                • Search History: Your recent word searches are stored locally on your device.
                • Favorites: Words you save as favorites are stored locally on your device.
                • Cache Data: Previously searched word definitions are cached locally.
                """
        ),
        LegalSection(
            title: "How We Use Your Information",
            icon: "gearshape.fill",
            content: """
                The information stored on your device is used solely to:

                • Display your recent search history
                • Maintain your favorites list
                • Provide offline access to cached word definitions
                • Improve app performance
                """
        ),
        LegalSection(
            title: "Data Storage",
            icon: "externaldrive.fill",
            content: """
                All data is stored locally on your device using iOS standard storage mechanisms (UserDefaults and NSCache).

                We do not transmit your personal data to external servers.
                """
        ),
        LegalSection(
            title: "Third-Party Services",
            icon: "globe",
            content: """
                Our app uses the Free Dictionary API to provide word definitions.

                When you search for a word, your query is sent to this third-party service. Please review their privacy policy for more information.
                """
        ),
        LegalSection(
            title: "Data Retention",
            icon: "clock.fill",
            content: """
                • Recent Searches: Up to 15 recent searches are retained
                • Favorites: Retained until you manually remove them
                • Cache: Automatically expires after 7 days
                """
        ),
        LegalSection(
            title: "Your Rights",
            icon: "person.fill.checkmark",
            content: """
                You have full control over your data:

                • Clear your search history at any time
                • Remove words from favorites
                • Clear the cache from Settings
                • Delete the app to remove all stored data
                """
        ),
        LegalSection(
            title: "Children's Privacy",
            icon: "figure.and.child.holdinghands",
            content: """
                Our app does not knowingly collect information from children under 13.

                The app is designed for general audiences and does not require any personal information to function.
                """
        ),
        LegalSection(
            title: "Contact Us",
            icon: "envelope.fill",
            content: """
                If you have questions about this Privacy Policy, please contact us at:

                📧 cllcnsgnk0@gmail.com
                """
        ),
    ]

    // MARK: - Terms of Use Sections

    static let termsOfUseSections: [LegalSection] = [
        LegalSection(
            title: "Acceptance of Terms",
            icon: "checkmark.seal.fill",
            content: """
                By downloading, installing, or using Lingoverse, you agree to be bound by these Terms.

                If you do not agree to these Terms, do not use the app.
                """
        ),
        LegalSection(
            title: "Description of Service",
            icon: "book.fill",
            content: """
                Lingoverse is a dictionary application that provides:

                • English and Turkish word definitions
                • Phonetic pronunciations
                • Audio playback of word pronunciations
                • Synonym listings and example sentences
                • Favorites and search history functionality
                • Flashcards and Quiz features for learning
                """
        ),
        LegalSection(
            title: "Use License",
            icon: "doc.badge.gearshape.fill",
            content: """
                We grant you a limited, non-exclusive, non-transferable license to:

                ✓ Download and install the app on your personal device
                ✓ Use the app for personal, non-commercial purposes

                You may not:
                ✗ Copy, modify, or distribute the app
                ✗ Reverse engineer or attempt to extract source code
                ✗ Use the app for any illegal or unauthorized purpose
                """
        ),
        LegalSection(
            title: "Intellectual Property",
            icon: "shield.fill",
            content: """
                The app, including its design, features, and content, is protected by copyright and other intellectual property laws.

                All rights not expressly granted are reserved.
                """
        ),
        LegalSection(
            title: "Disclaimer of Warranties",
            icon: "exclamationmark.triangle.fill",
            content: """
                The app is provided "AS IS" without warranties of any kind.

                We do not guarantee that:
                • The app will be error-free or uninterrupted
                • Word definitions will be completely accurate
                • The app will meet your specific requirements
                """
        ),
        LegalSection(
            title: "Third-Party Content",
            icon: "globe",
            content: """
                Word definitions are provided by the Free Dictionary API and TDK API.

                We are not responsible for the accuracy or completeness of third-party content.
                """
        ),
        LegalSection(
            title: "Governing Law",
            icon: "building.columns.fill",
            content: """
                These Terms shall be governed by the laws of Turkey, without regard to conflict of law principles.
                """
        ),
        LegalSection(
            title: "Contact",
            icon: "envelope.fill",
            content: """
                For questions about these Terms, contact us at:

                📧 cllcnsgnk0@gmail.com
                """
        ),
    ]

    // MARK: - Acknowledgements Sections

    static let acknowledgementsSections: [LegalSection] = [
        LegalSection(
            title: "Free Dictionary API",
            icon: "book.closed.fill",
            content: """
                Word definitions, phonetics, and pronunciations for English are provided by the Free Dictionary API.

                🌐 dictionaryapi.dev
                📄 License: Open Source

                We are grateful to the maintainers of this free service that makes educational apps like ours possible.
                """
        ),
        LegalSection(
            title: "TDK API",
            icon: "text.book.closed.fill",
            content: """
                Turkish word definitions are provided by the Turkish Language Association (TDK) API.

                🌐 sozluk.gov.tr

                We thank TDK for providing this valuable language resource.
                """
        ),
        LegalSection(
            title: "SF Symbols",
            icon: "star.fill",
            content: """
                Icons used throughout the app are from Apple's SF Symbols library.

                © Apple Inc.
                """
        ),
        LegalSection(
            title: "Open Source Community",
            icon: "chevron.left.forwardslash.chevron.right",
            content: """
                Special thanks to the iOS and Swift development community for their continuous support, tutorials, and shared knowledge.
                """
        ),
    ]
}

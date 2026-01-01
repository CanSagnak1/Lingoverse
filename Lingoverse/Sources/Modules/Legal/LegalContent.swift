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
}

enum LegalContent {

    static func content(for type: LegalDocumentType) -> String {
        switch type {
        case .privacyPolicy:
            return privacyPolicy
        case .termsOfUse:
            return termsOfUse
        case .acknowledgements:
            return acknowledgements
        }
    }

    // MARK: - Privacy Policy

    static let privacyPolicy = """
        PRIVACY POLICY

        Last Updated: January 1, 2026

        Lingoverse ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.

        1. INFORMATION WE COLLECT

        We collect minimal information to provide you with the best experience:

        • Search History: Your recent word searches are stored locally on your device to provide quick access to previously searched words.

        • Favorites: Words you save as favorites are stored locally on your device.

        • Cache Data: Previously searched word definitions are cached locally to enable offline access and faster loading.

        2. HOW WE USE YOUR INFORMATION

        The information stored on your device is used solely to:
        • Display your recent search history
        • Maintain your favorites list
        • Provide offline access to cached word definitions
        • Improve app performance

        3. DATA STORAGE

        All data is stored locally on your device using iOS standard storage mechanisms (UserDefaults and NSCache). We do not transmit your personal data to external servers.

        4. THIRD-PARTY SERVICES

        Our app uses the Free Dictionary API (https://dictionaryapi.dev) to fetch word definitions. When you search for a word, your search query is sent to this third-party service. Please refer to their privacy policy for information about how they handle data.

        5. DATA RETENTION

        • Recent Searches: Up to 15 recent searches are retained
        • Favorites: Retained until you manually remove them
        • Cache: Automatically expires after 7 days

        6. YOUR RIGHTS

        You can:
        • Clear your search history at any time
        • Remove words from favorites
        • Clear the cache from Settings
        • Delete the app to remove all stored data

        7. CHILDREN'S PRIVACY

        Our app does not knowingly collect information from children under 13. The app is designed for general audiences and does not require any personal information to function.

        8. CHANGES TO THIS POLICY

        We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date.

        9. CONTACT US

        If you have questions about this Privacy Policy, please contact us at:
        Email: support@lingoverse.app

        By using Lingoverse, you agree to the terms of this Privacy Policy.
        """

    // MARK: - Terms of Use

    static let termsOfUse = """
        TERMS OF USE

        Last Updated: January 1, 2026

        Please read these Terms of Use ("Terms") carefully before using the Lingoverse mobile application.

        1. ACCEPTANCE OF TERMS

        By downloading, installing, or using Lingoverse, you agree to be bound by these Terms. If you do not agree to these Terms, do not use the app.

        2. DESCRIPTION OF SERVICE

        Lingoverse is a dictionary application that provides:
        • English word definitions
        • Phonetic pronunciations
        • Audio playback of word pronunciations
        • Synonym listings
        • Example sentences
        • Favorites and search history functionality

        3. USE LICENSE

        We grant you a limited, non-exclusive, non-transferable license to:
        • Download and install the app on your personal device
        • Use the app for personal, non-commercial purposes

        You may not:
        • Copy, modify, or distribute the app
        • Reverse engineer or attempt to extract source code
        • Use the app for any illegal or unauthorized purpose
        • Sell, rent, or sublicense access to the app

        4. INTELLECTUAL PROPERTY

        The app, including its design, features, and content, is protected by copyright and other intellectual property laws. All rights not expressly granted are reserved.

        5. DISCLAIMER OF WARRANTIES

        THE APP IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND. WE DO NOT GUARANTEE THAT:
        • The app will be error-free or uninterrupted
        • Word definitions will be completely accurate
        • The app will meet your specific requirements

        6. LIMITATION OF LIABILITY

        TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, OR CONSEQUENTIAL DAMAGES ARISING FROM YOUR USE OF THE APP.

        7. THIRD-PARTY CONTENT

        Word definitions are provided by the Free Dictionary API. We are not responsible for the accuracy or completeness of third-party content.

        8. MODIFICATIONS

        We reserve the right to modify or discontinue the app at any time without notice. We may also update these Terms, and your continued use constitutes acceptance of any changes.

        9. TERMINATION

        We may terminate your access to the app if you violate these Terms. Upon termination, you must delete the app from your device.

        10. GOVERNING LAW

        These Terms shall be governed by the laws of Turkey, without regard to conflict of law principles.

        11. CONTACT

        For questions about these Terms, contact us at:
        Email: support@lingoverse.app

        By using Lingoverse, you acknowledge that you have read, understood, and agree to be bound by these Terms of Use.
        """

    // MARK: - Acknowledgements

    static let acknowledgements = """
        ACKNOWLEDGEMENTS

        Lingoverse is made possible thanks to the following:

        FREE DICTIONARY API

        Word definitions, phonetics, and pronunciations are provided by the Free Dictionary API.

        Website: https://dictionaryapi.dev
        License: Open Source

        We are grateful to the maintainers of this free service that makes educational apps like ours possible.

        SF SYMBOLS

        Icons used throughout the app are from Apple's SF Symbols library.

        © Apple Inc.

        OPEN SOURCE COMMUNITY

        Special thanks to the iOS and Swift development community for their continuous support, tutorials, and shared knowledge.

        SPECIAL THANKS

        • All beta testers who provided valuable feedback
        • Users who report bugs and suggest improvements
        • Everyone who helps spread the word about Lingoverse


        © 2026 Lingoverse. All rights reserved.
        """
}

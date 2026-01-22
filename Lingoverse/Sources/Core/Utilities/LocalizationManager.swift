//
//  LocalizationManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 22.01.2026.
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case turkish = "tr"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
    
    var localeIdentifier: String {
        rawValue
    }
}

final class LocalizationManager {
    
    static let shared = LocalizationManager()
    
    private let userDefaults: UserDefaults
    private let languageKey = "app_language"
    
    private(set) var currentLanguage: AppLanguage {
        didSet {
            userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
            UserDefaults.standard.set([currentLanguage.rawValue], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        if let savedLanguage = userDefaults.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.hasPrefix("tr") {
                self.currentLanguage = .turkish
            } else {
                self.currentLanguage = .english
            }
        }
    }
    
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
    }
    
    func localizedString(for key: String, comment: String = "") -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: comment)
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: comment)
    }
}

extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(for: self)
    }
    
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

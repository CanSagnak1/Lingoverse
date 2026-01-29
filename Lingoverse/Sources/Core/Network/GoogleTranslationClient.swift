//
//  GoogleTranslationClient.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import Foundation

/// Google Cloud Translation API v2 Client
final class GoogleTranslationClient {

    static let shared = GoogleTranslationClient()

    private let baseURL = "https://translation.googleapis.com/language/translate/v2"
    private var apiKey: String?
    private let session: URLSession
    private var cache: [String: String] = [:]

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15
        self.session = URLSession(configuration: config)
        loadAPIKey()
    }

    private func loadAPIKey() {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict["GOOGLE_TRANSLATE_API_KEY"] as? String
        else {
            print("⚠️ Google Translate API key not found in Secrets.plist")
            return
        }
        self.apiKey = key
        print("✅ Google Translate API key loaded")
    }

    /// Translate text from source language to target language
    /// - Parameters:
    ///   - text: Text to translate
    ///   - source: Source language code (e.g., "en")
    ///   - target: Target language code (e.g., "tr")
    /// - Returns: Translated text or nil if failed
    func translate(text: String, from source: String = "en", to target: String = "tr") async
        -> String?
    {
        // Check cache first
        let cacheKey = "\(source):\(target):\(text.lowercased())"
        if let cached = cache[cacheKey] {
            return cached
        }

        guard let apiKey = apiKey else {
            print("❌ API key not available")
            return nil
        }

        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "source", value: source),
            URLQueryItem(name: "target", value: target),
            URLQueryItem(name: "format", value: "text"),
        ]

        guard let url = components?.url else {
            print("❌ Invalid URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return nil
            }

            guard httpResponse.statusCode == 200 else {
                print("❌ API Error: \(httpResponse.statusCode)")
                if let errorBody = String(data: data, encoding: .utf8) {
                    print("Error body: \(errorBody)")
                }
                return nil
            }

            // Parse response
            let decoded = try JSONDecoder().decode(TranslationResponse.self, from: data)

            if let translation = decoded.data.translations.first?.translatedText {
                // Cache the result
                cache[cacheKey] = translation
                return translation
            }

            return nil

        } catch {
            print("❌ Translation error: \(error.localizedDescription)")
            return nil
        }
    }

    /// Clear translation cache
    func clearCache() {
        cache.removeAll()
    }
}

// MARK: - Response Models

struct TranslationResponse: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
    let detectedSourceLanguage: String?
}

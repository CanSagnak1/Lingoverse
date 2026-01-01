//
//  WordKitClient.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation
import WordAPI

public enum WordKitClientError: Error, LocalizedError {
    case underlying(Error)
    case unsupportedLanguage(String)
    case mappingFailed
    case notFound
    case networkUnavailable
    case timeout

    public var errorDescription: String? {
        switch self {
        case .underlying(let error):
            return error.localizedDescription
        case .unsupportedLanguage(let lang):
            return String(format: NSLocalizedString("error.unsupportedLanguage", comment: ""), lang)
        case .mappingFailed:
            return NSLocalizedString("error.mappingFailed", comment: "Data mapping error")
        case .notFound:
            return Strings.errorNotFound
        case .networkUnavailable:
            return Strings.errorIntCon
        case .timeout:
            return NSLocalizedString("error.timeout", comment: "Request timeout")
        }
    }
}

public protocol WordKitClient {
    func search(query: String, sourceLang: String, targetLang: String, page: Int?) async throws
        -> [WKWord]
}

public final class WordKitClientLive: WordKitClient {

    private let api: WordAPI
    private let cache: CacheManagerProtocol
    private let maxRetries = 3
    private let retryDelay: TimeInterval = 1.0

    public init(cache: CacheManagerProtocol = CacheManager.shared) {
        self.api = WordAPI()
        self.cache = cache
    }

    public func search(query: String, sourceLang: String, targetLang: String, page: Int?)
        async throws -> [WKWord]
    {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Check cache first
        if let cachedWord = await cache.getCachedWord(term: normalizedQuery) {
            return [cachedWord]
        }

        // Check network availability
        guard Reachability.isConnectedToNetwork() else {
            throw WordKitClientError.networkUnavailable
        }

        guard let language = Language(rawValue: sourceLang) else {
            throw WordKitClientError.unsupportedLanguage(sourceLang)
        }

        // Retry logic
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                let results = try await api.fetch(word: query, language: language)
                let mappedResults = results.map(mapToWKWord)

                // Cache the results
                for word in mappedResults {
                    await cache.cacheWord(word)
                }

                return mappedResults
            } catch {
                lastError = error

                // Check if it's a not found error - don't retry
                if isNotFoundError(error) {
                    throw WordKitClientError.notFound
                }

                // Wait before retry (exponential backoff)
                if attempt < maxRetries {
                    try? await Task.sleep(
                        nanoseconds: UInt64(retryDelay * Double(attempt) * 1_000_000_000))
                }
            }
        }

        // All retries failed
        if let error = lastError {
            throw WordKitClientError.underlying(error)
        }

        throw WordKitClientError.notFound
    }

    private func isNotFoundError(_ error: Error) -> Bool {
        let nsError = error as NSError
        return nsError.localizedDescription.contains("WordAPI.NetworkError error 3")
            || nsError.localizedDescription.contains("404")
            || nsError.localizedDescription.contains("not found")
    }
}

extension WordKitClientLive {
    fileprivate func mapToWKWord(_ entry: WordEntry) -> WKWord {
        let phoneticText = entry.phonetic
        let audioString = entry.phonetics
            .first(where: { $0.audio?.isEmpty == false })?
            .audio

        let meanings: [WKMeaning] = entry.meanings.map { meaning in

            let definitions: [WKDefinition] = meaning.definitions.map { definition in
                return WKDefinition(
                    definition: definition.definition,
                    example: definition.example
                )
            }

            return WKMeaning(
                partOfSpeech: meaning.partOfSpeech,
                definitions: definitions,
                synonyms: meaning.synonyms
            )
        }

        return WKWord(
            term: entry.word,
            phonetic: phoneticText,
            audioURL: URL(string: audioString ?? ""),
            meanings: meanings
        )
    }
}

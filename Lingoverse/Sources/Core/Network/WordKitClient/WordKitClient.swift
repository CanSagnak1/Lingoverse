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
    
    public var errorDescription: String? {
        switch self {
        case .underlying(let error):
            return error.localizedDescription
        case .unsupportedLanguage(let lang):
            return "Dil desteklenmiyor: \(lang)"
        case .mappingFailed:
            return "Gelen veri haritalanamadı."
        case .notFound:
            return "Kelime bulunamadı."
        }
    }
}

public protocol WordKitClient {
    func search(query: String, sourceLang: String, targetLang: String, page: Int?) async throws -> [WKWord]
}

public final class WordKitClientLive: WordKitClient {
    
    private let api: WordAPI
    
    public init() {
        self.api = WordAPI()
    }
    
    public func search(query: String, sourceLang: String, targetLang: String, page: Int?) async throws -> [WKWord] {
        guard let language = Language(rawValue: sourceLang) else {
            throw WordKitClientError.unsupportedLanguage(sourceLang)
        }
        
        do {
            let results = try await api.fetch(word: query, language: language)
            let mappedResults = results.map(mapToWKWord)
            return mappedResults
        } catch {
            if (error as NSError).localizedDescription.contains("WordAPI.NetworkError error 3") {
                throw WordKitClientError.notFound
            } else {
                throw WordKitClientError.underlying(error)
            }
        }
    }
}

private extension WordKitClientLive {
    func mapToWKWord(_ entry: WordEntry) -> WKWord {
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

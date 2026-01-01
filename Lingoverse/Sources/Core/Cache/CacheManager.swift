//
//  CacheManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import Foundation

public protocol CacheManagerProtocol {
    func cacheWord(_ word: WKWord) async
    func getCachedWord(term: String) async -> WKWord?
    func clearCache() async
    func getCacheSize() -> Int
}

public final class CacheManager: CacheManagerProtocol {

    public static let shared = CacheManager()

    private let cache = NSCache<NSString, CachedWord>()
    private let userDefaults: UserDefaults
    private let cacheKey = "cached_words_keys"
    private let maxCacheAge: TimeInterval = 60 * 60 * 24 * 7  // 7 days

    private var cachedKeys: Set<String> {
        get {
            Set(userDefaults.stringArray(forKey: cacheKey) ?? [])
        }
        set {
            userDefaults.set(Array(newValue), forKey: cacheKey)
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        cache.countLimit = 500
        cache.totalCostLimit = 50 * 1024 * 1024  // 50 MB
        loadPersistedCache()
    }

    public func cacheWord(_ word: WKWord) async {
        let key = word.term.lowercased() as NSString
        let cached = CachedWord(word: word, timestamp: Date())
        cache.setObject(cached, forKey: key)

        var keys = cachedKeys
        keys.insert(word.term.lowercased())
        cachedKeys = keys

        persistWord(cached, forKey: word.term.lowercased())
    }

    public func getCachedWord(term: String) async -> WKWord? {
        let key = term.lowercased() as NSString

        if let cached = cache.object(forKey: key) {
            if Date().timeIntervalSince(cached.timestamp) < maxCacheAge {
                return cached.word
            } else {
                cache.removeObject(forKey: key)
                removePersistedWord(forKey: term.lowercased())
                return nil
            }
        }

        if let persisted = loadPersistedWord(forKey: term.lowercased()) {
            if Date().timeIntervalSince(persisted.timestamp) < maxCacheAge {
                cache.setObject(persisted, forKey: key)
                return persisted.word
            } else {
                removePersistedWord(forKey: term.lowercased())
                return nil
            }
        }

        return nil
    }

    public func clearCache() async {
        cache.removeAllObjects()
        for key in cachedKeys {
            removePersistedWord(forKey: key)
        }
        cachedKeys = []
    }

    public func getCacheSize() -> Int {
        return cachedKeys.count
    }

    // MARK: - Persistence

    private func persistWord(_ cached: CachedWord, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(cached) {
            userDefaults.set(data, forKey: "cache_\(key)")
        }
    }

    private func loadPersistedWord(forKey key: String) -> CachedWord? {
        guard let data = userDefaults.data(forKey: "cache_\(key)") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(CachedWord.self, from: data)
    }

    private func removePersistedWord(forKey key: String) {
        userDefaults.removeObject(forKey: "cache_\(key)")
        var keys = cachedKeys
        keys.remove(key)
        cachedKeys = keys
    }

    private func loadPersistedCache() {
        for key in cachedKeys {
            if let cached = loadPersistedWord(forKey: key) {
                if Date().timeIntervalSince(cached.timestamp) < maxCacheAge {
                    cache.setObject(cached, forKey: key as NSString)
                } else {
                    removePersistedWord(forKey: key)
                }
            }
        }
    }
}

// MARK: - CachedWord Model

private final class CachedWord: NSObject, Codable {
    let word: WKWord
    let timestamp: Date

    init(word: WKWord, timestamp: Date) {
        self.word = word
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case word, timestamp
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(WKWord.self, forKey: .word)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

// MARK: - WKWord Codable Extension

extension WKWord: Codable {
    enum CodingKeys: String, CodingKey {
        case term, phonetic, audioURL, meanings
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        term = try container.decode(String.self, forKey: .term)
        phonetic = try container.decodeIfPresent(String.self, forKey: .phonetic)
        audioURL = try container.decodeIfPresent(URL.self, forKey: .audioURL)
        meanings = try container.decode([WKMeaning].self, forKey: .meanings)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(term, forKey: .term)
        try container.encodeIfPresent(phonetic, forKey: .phonetic)
        try container.encodeIfPresent(audioURL, forKey: .audioURL)
        try container.encode(meanings, forKey: .meanings)
    }
}

extension WKMeaning: Codable {
    enum CodingKeys: String, CodingKey {
        case partOfSpeech, definitions, synonyms
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        partOfSpeech = try container.decode(String.self, forKey: .partOfSpeech)
        definitions = try container.decode([WKDefinition].self, forKey: .definitions)
        synonyms = try container.decode([String].self, forKey: .synonyms)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(partOfSpeech, forKey: .partOfSpeech)
        try container.encode(definitions, forKey: .definitions)
        try container.encode(synonyms, forKey: .synonyms)
    }
}

extension WKDefinition: Codable {
    enum CodingKeys: String, CodingKey {
        case definition, example
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        definition = try container.decode(String.self, forKey: .definition)
        example = try container.decodeIfPresent(String.self, forKey: .example)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(definition, forKey: .definition)
        try container.encodeIfPresent(example, forKey: .example)
    }
}

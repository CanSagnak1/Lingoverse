//
//  CacheManager.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 1.01.2026.
//

import Foundation

public protocol CacheManagerProtocol {
    func cacheWords(_ words: [WKWord], for term: String) async
    func getCachedWords(term: String) async -> [WKWord]?
    func clearCache() async
    func getCacheSize() -> Int
}

public final class CacheManager: CacheManagerProtocol {

    public static let shared = CacheManager()

    private let cache = NSCache<NSString, CachedResult>()
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

    public func cacheWords(_ words: [WKWord], for term: String) async {
        let key = term.lowercased() as NSString
        let cached = CachedResult(words: words, timestamp: Date())
        cache.setObject(cached, forKey: key)

        var keys = cachedKeys
        keys.insert(term.lowercased())
        cachedKeys = keys

        persistResult(cached, forKey: term.lowercased())
    }

    public func getCachedWords(term: String) async -> [WKWord]? {
        let key = term.lowercased() as NSString

        if let cached = cache.object(forKey: key) {
            if Date().timeIntervalSince(cached.timestamp) < maxCacheAge {
                return cached.words
            } else {
                cache.removeObject(forKey: key)
                removePersistedResult(forKey: term.lowercased())
                return nil
            }
        }

        if let persisted = loadPersistedResult(forKey: term.lowercased()) {
            if Date().timeIntervalSince(persisted.timestamp) < maxCacheAge {
                cache.setObject(persisted, forKey: key)
                return persisted.words
            } else {
                removePersistedResult(forKey: term.lowercased())
                return nil
            }
        }

        return nil
    }

    public func clearCache() async {
        cache.removeAllObjects()
        for key in cachedKeys {
            removePersistedResult(forKey: key)
        }
        cachedKeys = []
    }

    public func getCacheSize() -> Int {
        return cachedKeys.count
    }

    // MARK: - Persistence

    private func persistResult(_ cached: CachedResult, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(cached) {
            userDefaults.set(data, forKey: "cache_\(key)")
        }
    }

    private func loadPersistedResult(forKey key: String) -> CachedResult? {
        guard let data = userDefaults.data(forKey: "cache_\(key)") else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(CachedResult.self, from: data)
    }

    private func removePersistedResult(forKey key: String) {
        userDefaults.removeObject(forKey: "cache_\(key)")
        var keys = cachedKeys
        keys.remove(key)
        cachedKeys = keys
    }

    private func loadPersistedCache() {
        for key in cachedKeys {
            if let cached = loadPersistedResult(forKey: key) {
                if Date().timeIntervalSince(cached.timestamp) < maxCacheAge {
                    cache.setObject(cached, forKey: key as NSString)
                } else {
                    removePersistedResult(forKey: key)
                }
            }
        }
    }
}

// MARK: - CachedResult Model

private final class CachedResult: NSObject, Codable {
    let words: [WKWord]
    let timestamp: Date

    init(words: [WKWord], timestamp: Date) {
        self.words = words
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case words, timestamp
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        words = try container.decode([WKWord].self, forKey: .words)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(words, forKey: .words)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

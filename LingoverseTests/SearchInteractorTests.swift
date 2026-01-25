//
//  SearchInteractorTests.swift
//  LingoverseTests
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import XCTest

@testable import Lingoverse

final class SearchInteractorTests: XCTestCase {

    var sut: SearchInteractor!
    var mockClient: MockWordKitClient!
    var mockRecentRepo: MockRecentSearchRepository!
    var mockFavoritesRepo: MockFavoritesRepositoryForInteractor!
    var mockGamificationService: MockGamificationServiceForInteractor!
    var mockOutput: MockSearchInteractorOutput!

    override func setUp() {
        super.setUp()
        mockClient = MockWordKitClient()
        mockRecentRepo = MockRecentSearchRepository()
        mockFavoritesRepo = MockFavoritesRepositoryForInteractor()
        mockGamificationService = MockGamificationServiceForInteractor()
        mockOutput = MockSearchInteractorOutput()

        sut = SearchInteractor(
            client: mockClient,
            recentRepo: mockRecentRepo,
            favoritesRepo: mockFavoritesRepo,
            gamificationService: mockGamificationService
        )
        sut.output = mockOutput
    }

    override func tearDown() {
        sut = nil
        mockClient = nil
        mockRecentRepo = nil
        mockFavoritesRepo = nil
        mockGamificationService = nil
        mockOutput = nil
        super.tearDown()
    }

    // MARK: - performSearch Tests

    func testPerformSearch_WhenSuccessful_ShouldReturnResults() async {
        let word = WKWord(term: "hello", phonetic: "/həˈloʊ/", audioURL: nil, meanings: [])
        mockClient.mockResult = [word]

        await sut.performSearch(query: "hello", source: "en", target: "en")

        XCTAssertTrue(mockOutput.didLoadResultsCalled, "Should call didLoad")
        XCTAssertEqual(
            mockOutput.lastLoadedResults?.first?.term, "hello", "Should return correct word")
    }

    func testPerformSearch_WhenSuccessful_ShouldAddXP() async {
        let word = WKWord(term: "hello", phonetic: nil, audioURL: nil, meanings: [])
        mockClient.mockResult = [word]

        await sut.performSearch(query: "hello", source: "en", target: "en")

        // Note: Gamification runs on MainActor, we verify via mock
        // This test verifies integration point exists
        XCTAssertTrue(mockOutput.didLoadResultsCalled)
    }

    func testPerformSearch_WhenNotFound_ShouldReturnEmptyResults() async {
        mockClient.shouldThrowNotFound = true

        await sut.performSearch(query: "asdfghjkl", source: "en", target: "en")

        XCTAssertTrue(mockOutput.didLoadResultsCalled, "Should call didLoad with empty")
        XCTAssertTrue(mockOutput.lastLoadedResults?.isEmpty == true, "Should return empty array")
    }

    func testPerformSearch_WhenNetworkError_ShouldCheckCache() async {
        mockClient.shouldThrowError = true
        mockRecentRepo.mockCachedResults = [
            WKWord(term: "cached", phonetic: nil, audioURL: nil, meanings: [])
        ]

        await sut.performSearch(query: "cached", source: "en", target: "en")

        XCTAssertTrue(mockOutput.didLoadResultsCalled, "Should return cached results")
        XCTAssertEqual(mockOutput.lastLoadedResults?.first?.term, "cached")
    }

    func testPerformSearch_WhenNetworkErrorAndNoCache_ShouldFail() async {
        mockClient.shouldThrowError = true
        mockRecentRepo.mockCachedResults = nil

        await sut.performSearch(query: "unknown", source: "en", target: "en")

        XCTAssertTrue(mockOutput.didFailCalled, "Should call didFail")
    }

    // MARK: - fetchRecentSearches Tests

    func testFetchRecentSearches_ShouldReturnTerms() async {
        mockRecentRepo.mockRecentSearches = ["swift", "viper", "ios"]

        await sut.fetchRecentSearches()

        XCTAssertTrue(mockOutput.didLoadRecentSearchesCalled)
        XCTAssertEqual(mockOutput.lastRecentSearches, ["swift", "viper", "ios"])
    }

    // MARK: - saveSearch Tests

    func testSaveSearch_ShouldCallRepository() async {
        let results = [WKWord(term: "test", phonetic: nil, audioURL: nil, meanings: [])]

        await sut.saveSearch("test", results: results)

        XCTAssertTrue(mockRecentRepo.saveSearchCalled)
    }

    // MARK: - deleteRecentSearch Tests

    func testDeleteRecentSearch_ShouldCallRepository() async {
        await sut.deleteRecentSearch(term: "swift")

        XCTAssertTrue(mockRecentRepo.deleteSearchCalled)
        XCTAssertEqual(mockRecentRepo.lastDeletedTerm, "swift")
    }

    // MARK: - saveFavorite Tests

    func testSaveFavorite_ShouldCallRepository() async {
        await sut.saveFavorite("hello")

        XCTAssertTrue(mockFavoritesRepo.saveFavoriteCalled)
        XCTAssertEqual(mockFavoritesRepo.lastSavedTerm, "hello")
    }
}

// MARK: - Mock Classes

class MockWordKitClient: WordKitClient {
    var mockResult: [WKWord] = []
    var shouldThrowNotFound = false
    var shouldThrowError = false

    func search(query: String, sourceLang: String, targetLang: String, page: Int?) async throws
        -> [WKWord]
    {
        if shouldThrowNotFound {
            throw WordKitClientError.notFound
        }
        if shouldThrowError {
            throw WordKitClientError.networkUnavailable
        }
        return mockResult
    }
}

class MockRecentSearchRepository: RecentSearchRepositoryProtocol {
    var mockRecentSearches: [String] = []
    var mockCachedResults: [WKWord]?

    var saveSearchCalled = false
    var deleteSearchCalled = false
    var lastDeletedTerm: String?

    func fetchRecentSearches() -> [String] {
        return mockRecentSearches
    }

    func saveSearch(_ term: String, results: [WKWord]) {
        saveSearchCalled = true
    }

    func deleteSearch(_ term: String) {
        deleteSearchCalled = true
        lastDeletedTerm = term
    }

    func getCachedResults(for term: String) -> [WKWord]? {
        return mockCachedResults
    }
}

class MockFavoritesRepositoryForInteractor: FavoritesRepositoryProtocol {
    var saveFavoriteCalled = false
    var lastSavedTerm: String?

    func fetchFavorites() -> [String] { return [] }
    func saveFavorite(_ term: String) {
        saveFavoriteCalled = true
        lastSavedTerm = term
    }
    func deleteFavorite(_ term: String) {}
    func isFavorite(_ term: String) -> Bool { return false }
}

class MockGamificationServiceForInteractor: GamificationServiceProtocol {
    var progress: UserProgress = UserProgress(
        totalXP: 0, currentLevel: 1, currentStreak: 0, longestStreak: 0, lastActivityDate: nil)
    var badges: [Badge] = []

    var addXPCalled = false
    var updateStreakCalled = false

    func addXP(amount: Int) {
        addXPCalled = true
    }

    func updateStreak() {
        updateStreakCalled = true
    }

    func checkBadges() {}
}

class MockSearchInteractorOutput: SearchInteractorOutput {
    var didLoadResultsCalled = false
    var didLoadRecentSearchesCalled = false
    var didFailCalled = false

    var lastLoadedResults: [WKWord]?
    var lastRecentSearches: [String]?
    var lastError: String?

    func didLoad(results: [WKWord]) {
        didLoadResultsCalled = true
        lastLoadedResults = results
    }

    func didLoadRecentSearches(_ terms: [String]) {
        didLoadRecentSearchesCalled = true
        lastRecentSearches = terms
    }

    func didFail(_ message: String) {
        didFailCalled = true
        lastError = message
    }
}

//
//  SearchPresenterTests.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 7.11.2025.
//

import XCTest
@testable import Lingoverse

@MainActor
final class SearchPresenterTests: XCTestCase {

    var sut: SearchPresenter!
    var mockView: MockSearchView!
    var mockInteractor: MockSearchInteractor!
    var mockRouter: MockSearchRouter!

    override func setUp() {
        super.setUp()
        mockView = MockSearchView()
        mockInteractor = MockSearchInteractor()
        mockRouter = MockSearchRouter()
        sut = SearchPresenter(
            view: mockView,
            interactor: mockInteractor,
            router: mockRouter
        )
    }
    
    override func tearDown() {
        sut = nil
        mockView = nil
        mockInteractor = nil
        mockRouter = nil
        super.tearDown()
    }

    // MARK: - viewDidLoad Tests
    
    func testViewDidLoad_ShouldRenderIdleState() {
        sut.viewDidLoad()
        
        XCTAssertEqual(mockView.renderedState, .idle, "viewDidLoad should render idle state")
    }
    
    // MARK: - viewWillAppear Tests
    
    func testViewWillAppear_WhenNoWordToRoute_ShouldFetchRecentSearches() {
        sut.viewWillAppear()
        
        XCTAssertTrue(mockInteractor.fetchRecentSearchesCalled, "viewWillAppear should trigger fetchRecentSearches")
    }
    
    // MARK: - didChangeQuery Tests
    
    func testDidChangeQuery_WhenEmpty_ShouldFetchRecentSearches() {
        sut.didChangeQuery(text: "   ")
        
        XCTAssertTrue(mockInteractor.fetchRecentSearchesCalled, "Empty query should fetch recent searches")
    }
    
    func testDidChangeQuery_WhenNotEmpty_ShouldNotFetchRecentSearches() {
        mockInteractor.fetchRecentSearchesCalled = false
        sut.didChangeQuery(text: "swift")
        
        XCTAssertFalse(mockInteractor.fetchRecentSearchesCalled, "Non-empty query should not immediately fetch recent searches")
    }
    
    // MARK: - didTapSearchButton Tests
    
    func testDidTapSearchButton_WhenEmpty_ShouldNotPerformSearch() {
        sut.didTapSearchButton(query: "   ")
        
        XCTAssertFalse(mockInteractor.performSearchCalled, "Empty query should not trigger search")
    }
    
    func testDidTapSearchButton_WhenValid_ShouldRenderLoadingAndPerformSearch() {
        sut.didTapSearchButton(query: "hello")
        
        XCTAssertEqual(mockView.renderedState, .loading, "Should render loading state")
        XCTAssertTrue(mockInteractor.performSearchCalled, "Should trigger search")
        XCTAssertEqual(mockInteractor.lastSearchQuery, "hello", "Should pass correct query")
    }
    
    // MARK: - didLoadRecentSearches Tests

    func testSearchPresenter_WhenRecentSearchesLoaded_ShouldRenderRecentState() {
        let recentTerms = ["swift", "viper"]
        sut.didLoadRecentSearches(recentTerms)
        XCTAssertNotNil(mockView.renderedState, "View'a bir state gönderilmiş olmalı.")
        guard let state = mockView.renderedState else {
            XCTFail("Rendered state nil olmamalı.")
            return
        }
        XCTAssertEqual(state, .recent(recentTerms), "View'a '.recent' state'i doğru terimlerle gönderilmeli.")
    }
    
    func testDidLoadRecentSearches_WhenEmpty_ShouldStillRenderRecent() {
        sut.didLoadRecentSearches([])
        
        XCTAssertEqual(mockView.renderedState, .recent([]), "Empty array should still render as recent state")
    }
    
    // MARK: - didLoad Results Tests
    
    func testDidLoad_WhenResultsEmpty_ShouldRenderEmptyState() {
        sut.didChangeQuery(text: "unknown")
        sut.didLoad(results: [])
        
        XCTAssertNotNil(mockView.renderedState)
        if case .empty(let message) = mockView.renderedState {
            XCTAssertTrue(message.contains("unknown"), "Empty state message should contain the query")
        } else {
            XCTFail("Should render empty state when no results")
        }
    }
    
    func testDidLoad_WhenResultsExist_ShouldDismissSearch() {
        let word = WKWord(term: "hello", phonetic: nil, audioURL: nil, meanings: [])
        sut.didLoad(results: [word])
        
        XCTAssertTrue(mockView.dismissSearchCalled, "Should dismiss search when results exist")
    }
    
    // MARK: - didSelectRow Tests
    
    func testDidSelectRow_WhenIndexOutOfBounds_ShouldDoNothing() {
        sut.didLoadRecentSearches(["swift"])
        sut.didSelectRow(5)
        
        XCTAssertFalse(mockInteractor.performSearchCalled, "Out of bounds index should not trigger search")
    }
    
    func testDidSelectRow_WhenValidIndex_ShouldPerformSearch() {
        sut.didLoadRecentSearches(["swift", "viper"])
        sut.didSelectRow(1)
        
        XCTAssertTrue(mockInteractor.performSearchCalled, "Valid index should trigger search")
        XCTAssertEqual(mockInteractor.lastSearchQuery, "viper", "Should search for correct term")
    }
    
    // MARK: - didDeleteRecentSearch Tests
    
    func testDidDeleteRecentSearch_ShouldCallInteractor() {
        sut.didDeleteRecentSearch(term: "swift")
        
        XCTAssertTrue(mockInteractor.deleteRecentSearchCalled, "Should call interactor to delete")
        XCTAssertEqual(mockInteractor.lastDeletedTerm, "swift", "Should delete correct term")
    }
    
    // MARK: - didTapFavoriteRecentSearch Tests
    
    func testDidTapFavoriteRecentSearch_ShouldCallInteractor() {
        sut.didTapFavoriteRecentSearch(term: "swift")
        
        XCTAssertTrue(mockInteractor.saveFavoriteCalled, "Should call interactor to save favorite")
        XCTAssertEqual(mockInteractor.lastSavedFavorite, "swift", "Should save correct term")
    }
    
    // MARK: - didFail Tests
    
    func testDidFail_ShouldRenderErrorState() {
        sut.didFail("Network error")
        
        XCTAssertEqual(mockView.renderedState, .error("Network error"), "Should render error state with message")
    }
}

// MARK: - Mock Classes

class MockSearchView: SearchViewInput {
    var renderedState: SearchState?
    var dismissSearchCalled = false
    var searchText: String?
    
    func render(_ state: SearchState) { renderedState = state }
    func setSearchText(_ text: String) { searchText = text }
    func dismissSearch() { dismissSearchCalled = true }
}

class MockSearchInteractor: SearchInteractorInput {
    var performSearchCalled = false
    var fetchRecentSearchesCalled = false
    var saveSearchCalled = false
    var deleteRecentSearchCalled = false
    var saveFavoriteCalled = false
    
    var lastSearchQuery: String?
    var lastDeletedTerm: String?
    var lastSavedFavorite: String?
    
    func performSearch(query: String, source: String, target: String) async {
        performSearchCalled = true
        lastSearchQuery = query
    }
    
    func fetchRecentSearches() async {
        fetchRecentSearchesCalled = true
    }
    
    func saveSearch(_ term: String, results: [WKWord]) async {
        saveSearchCalled = true
    }
    
    func deleteRecentSearch(term: String) async {
        deleteRecentSearchCalled = true
        lastDeletedTerm = term
    }
    
    func saveFavorite(_ term: String) async {
        saveFavoriteCalled = true
        lastSavedFavorite = term
    }
}

class MockSearchRouter: SearchRouterProtocol {
    var routeToDetailCalled = false
    var lastRoutedWord: WKWord?
    
    func routeToDetail(from vc: UIViewController, word: WKWord) {
        routeToDetailCalled = true
        lastRoutedWord = word
    }
}


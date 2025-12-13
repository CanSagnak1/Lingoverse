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

    // TEST 5
    // Interactor'dan son aramalar listesi geldiğinde, Presenter'ın View'a doğru ".recent" state'ini gönderip göndermediğini test eder.
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
}

class MockSearchView: SearchViewInput {
    var renderedState: SearchState?
    func render(_ state: SearchState) { renderedState = state }
    func setSearchText(_ text: String) {}
    func dismissSearch() {}
}

class MockSearchInteractor: SearchInteractorInput {
    func performSearch(query: String, source: String, target: String) async {}
    func fetchRecentSearches() async {}
    func saveSearch(_ term: String) async {}
    func deleteRecentSearch(term: String) async {}
    func saveFavorite(_ term: String) async {}
}

class MockSearchRouter: SearchRouterProtocol {
    func routeToDetail(from vc: UIViewController, word: WKWord) {}
    func routeToFavorites(from vc: UIViewController) {}
}

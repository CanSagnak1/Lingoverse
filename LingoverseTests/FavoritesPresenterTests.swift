//
//  FavoritesPresenterTests.swift
//  LingoverseTests
//
//  Created by Celal Can Sağnak on 26.01.2026.
//

import XCTest

@testable import Lingoverse

@MainActor
final class FavoritesPresenterTests: XCTestCase {

    var sut: FavoritesPresenter!
    var mockView: MockFavoritesView!
    var mockInteractor: MockFavoritesInteractor!
    var mockRouter: MockFavoritesRouter!

    override func setUp() {
        super.setUp()
        mockView = MockFavoritesView()
        mockInteractor = MockFavoritesInteractor()
        mockRouter = MockFavoritesRouter()
        sut = FavoritesPresenter(
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

    func testViewDidLoad_ShouldRenderLoadingAndFetchFavorites() {
        sut.viewDidLoad()

        XCTAssertEqual(mockView.renderedState, .loading, "Should render loading state")
        XCTAssertTrue(mockInteractor.fetchFavoritesCalled, "Should fetch favorites")
    }

    // MARK: - viewWillAppear Tests

    func testViewWillAppear_WhenNoWordToRoute_ShouldFetchFavorites() {
        mockInteractor.fetchFavoritesCalled = false
        sut.viewWillAppear()

        XCTAssertTrue(mockInteractor.fetchFavoritesCalled, "Should fetch favorites on appear")
    }

    // MARK: - didLoadFavorites Tests

    func testDidLoadFavorites_WhenEmpty_ShouldRenderEmptyState() {
        sut.didLoadFavorites([])

        XCTAssertEqual(mockView.renderedState, .empty, "Empty favorites should render empty state")
    }

    func testDidLoadFavorites_WhenHasItems_ShouldRenderContentState() {
        let terms = ["swift", "viper", "ios"]
        sut.didLoadFavorites(terms)

        XCTAssertEqual(mockView.renderedState, .content(terms), "Should render content with terms")
    }

    // MARK: - didSelectRow Tests

    func testDidSelectRow_WhenIndexOutOfBounds_ShouldDoNothing() {
        sut.didLoadFavorites(["swift"])
        mockView.renderedState = nil
        sut.didSelectRow(5)

        XCTAssertNil(mockView.renderedState, "Out of bounds should not trigger any action")
    }

    func testDidSelectRow_WhenValidIndex_ShouldRenderLoadingAndFetchDetail() {
        sut.didLoadFavorites(["swift", "viper"])
        sut.didSelectRow(1)

        XCTAssertEqual(mockView.renderedState, .loading, "Should render loading")
        XCTAssertTrue(mockInteractor.fetchWordDetailCalled, "Should fetch word detail")
        XCTAssertEqual(mockInteractor.lastFetchedTerm, "viper", "Should fetch correct term")
    }

    // MARK: - didDeleteFavorite Tests

    func testDidDeleteFavorite_WhenValidIndex_ShouldRemoveAndRenderContent() {
        sut.didLoadFavorites(["swift", "viper", "ios"])
        sut.didDeleteFavorite(at: 1)

        XCTAssertTrue(mockInteractor.deleteFavoriteCalled, "Should call delete on interactor")
        XCTAssertEqual(mockInteractor.lastDeletedTerm, "viper", "Should delete correct term")
        XCTAssertEqual(mockView.renderedState, .content(["swift", "ios"]), "Should update content")
    }

    func testDidDeleteFavorite_WhenLastItem_ShouldRenderEmpty() {
        sut.didLoadFavorites(["swift"])
        sut.didDeleteFavorite(at: 0)

        XCTAssertEqual(mockView.renderedState, .empty, "Should render empty when last item deleted")
    }

    func testDidDeleteFavorite_WhenIndexOutOfBounds_ShouldDoNothing() {
        sut.didLoadFavorites(["swift"])
        mockInteractor.deleteFavoriteCalled = false
        sut.didDeleteFavorite(at: 5)

        XCTAssertFalse(mockInteractor.deleteFavoriteCalled, "Should not delete for invalid index")
    }

    // MARK: - didLoadWordDetail Tests

    func testDidLoadWordDetail_ShouldDismissSearch() {
        let word = WKWord(term: "hello", phonetic: nil, audioURL: nil, meanings: [])
        sut.didLoadWordDetail(word)

        XCTAssertTrue(mockView.dismissSearchCalled, "Should dismiss search to trigger navigation")
    }

    // MARK: - didFail Tests

    func testDidFail_WhenHasFavorites_ShouldRenderContent() {
        sut.didLoadFavorites(["swift", "viper"])
        sut.didFail(message: "Network error")

        XCTAssertEqual(
            mockView.renderedState, .content(["swift", "viper"]),
            "Should keep showing content on error")
    }

    func testDidFail_WhenNoFavorites_ShouldRenderEmpty() {
        sut.didLoadFavorites([])
        sut.didFail(message: "Network error")

        XCTAssertEqual(mockView.renderedState, .empty, "Should render empty when no favorites")
    }
}

// MARK: - Mock Classes

class MockFavoritesView: FavoritesViewInput {
    var renderedState: FavoritesState?
    var dismissSearchCalled = false

    func render(_ state: FavoritesState) {
        renderedState = state
    }

    func dismissSearch() {
        dismissSearchCalled = true
    }
}

class MockFavoritesInteractor: FavoritesInteractorInput {
    var fetchFavoritesCalled = false
    var deleteFavoriteCalled = false
    var fetchWordDetailCalled = false

    var lastDeletedTerm: String?
    var lastFetchedTerm: String?

    func fetchFavorites() {
        fetchFavoritesCalled = true
    }

    func deleteFavorite(_ term: String) {
        deleteFavoriteCalled = true
        lastDeletedTerm = term
    }

    func fetchWordDetail(for term: String) async {
        fetchWordDetailCalled = true
        lastFetchedTerm = term
    }
}

class MockFavoritesRouter: FavoritesRouterProtocol {
    var routeToDetailCalled = false
    var lastRoutedWord: WKWord?

    func routeToDetail(from vc: UIViewController, word: WKWord) {
        routeToDetailCalled = true
        lastRoutedWord = word
    }
}

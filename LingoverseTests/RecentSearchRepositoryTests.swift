//
//  RecentSearchRepositoryTests.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 7.11.2025.
//

import XCTest
@testable import Lingoverse

final class RecentSearchRepositoryTests: XCTestCase {

    var sut: RecentSearchRepository!
    var testUserDefaults: UserDefaults!
    let testSuiteName = "TestDefaults"

    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: testSuiteName)
        sut = RecentSearchRepository(userDefaults: testUserDefaults)
    }

    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: testSuiteName)
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    // TEST 1
    // Bir arama teriminin kaydedilip kaydedilmediğini ve küçük harfe çevrildiğini test eder.
    func testSaveSearch_ShouldBeLowercasedAndSaved() {
        let searchTerm = "Hello"
        sut.saveSearch(searchTerm)
        let searches = sut.fetchRecentSearches()
        XCTAssertEqual(searches.count, 1, "Arama listesinde 1 öğe olmalı.")
        XCTAssertEqual(searches.first, "hello", "Kaydedilen terim küçük harfe çevrilmeli.")
    }

    // TEST 2
    // Aramaların doğru sırada (en yeni en üstte) ve kopyalar olmadan kaydedildiğini test eder.
    func testFetchRecentSearches_ShouldHandleDuplicatesAndOrder() {
        sut.saveSearch("One")
        sut.saveSearch("Two")
        sut.saveSearch("One")
        let searches = sut.fetchRecentSearches()
        let expectedOrder = ["one", "two"]
        XCTAssertEqual(searches, expectedOrder, "Aramalar doğru sırada ve kopyalar olmadan gelmeli.")
        XCTAssertEqual(searches.count, 2, "Kopya terimler listede bir kez bulunmalı.")
    }
}

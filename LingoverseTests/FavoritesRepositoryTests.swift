//
//  FavoritesRepositoryTests.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 7.11.2025.
//

import XCTest
@testable import Lingoverse

final class FavoritesRepositoryTests: XCTestCase {

    var sut: FavoritesRepository!
    var testUserDefaults: UserDefaults!
    let testSuiteName = "TestFavoritesDefaults"
    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: testSuiteName)
        sut = FavoritesRepository(userDefaults: testUserDefaults)
    }
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: testSuiteName)
        testUserDefaults = nil
        sut = nil
        super.tearDown()
    }

    // TEST 3
    // Bir terimin favorilere eklenip eklenmediğini ve kontrol metodunun doğru çalıştığını test eder.
    func testSaveAndCheckFavorite_ShouldReturnIsFavoriteTrue() {
        let term = "Lingoverse"
        sut.saveFavorite(term)
        let isFavorite = sut.isFavorite("lingoverse")
        let isNotFavorite = sut.isFavorite("Swift")
        XCTAssertTrue(isFavorite, "Kaydedilen terim favori olarak bulunmalı.")
        XCTAssertFalse(isNotFavorite, "Kaydedilmeyen terim favori olmamalı.")
    }

    // TEST 4
    // Bir terimin favorilerden silinip silinmediğini test eder.
    func testDeleteFavorite_ShouldReturnIsFavoriteFalse() {
        let term = "Test"
        sut.saveFavorite(term)
        XCTAssertTrue(sut.isFavorite(term), "Silmeden önce terim favori olmalı.")
        sut.deleteFavorite(term)
        XCTAssertFalse(sut.isFavorite(term), "Sildikten sonra terim favori olmamalı.")
    }
}

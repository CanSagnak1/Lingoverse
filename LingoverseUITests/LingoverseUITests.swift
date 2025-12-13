//
//  LingoverseUITests.swift
//  LingoverseUITests
//
//  Created by Celal Can Sağnak on 7.11.2025.
//

import XCTest

@MainActor
final class LingoverseUITests: XCTestCase {

    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        super.tearDown()
    }


    // TEST 1: Ana Ekranın Boş Durumunu Kontrol Etme
    func testSearchIdleEmptyState() throws {
        let searchNavigationBar = app.navigationBars["Search"]
        XCTAssertTrue(searchNavigationBar.waitForExistence(timeout: 10), "Ana 'Search' ekranı 10 saniye içinde yüklenmedi.")
        let emptyStateText = app.staticTexts["You have no recent searches."]
        XCTAssertTrue(emptyStateText.exists, "You have no recent searches. boş durum metni bulunamadı.")
    }

    // TEST 2: Favoriler Ekranına Gidişi Test Etme
    func testNavigationToFavorites() throws {
        let searchNavigationBar = app.navigationBars["Search"]
        XCTAssertTrue(searchNavigationBar.waitForExistence(timeout: 10), "Ana 'Search' ekranı yüklenmedi.")
        let favoritesButton = app.buttons["Favorites"]
        XCTAssertTrue(favoritesButton.exists, "Favoriler butonu (accessibilityLabel: 'Favorites') ekranda bulunamadı.")
        favoritesButton.tap()
        let favoritesNavigationBar = app.navigationBars["Favorites"]
        XCTAssertTrue(favoritesNavigationBar.exists, "Favoriler ekranına (NavigationBar başlığı: 'Favorites') başarıyla yönlendirilmedi.")
    }

    // TEST 3: Favoriler Ekranından Ana Ekrana Geri Dönüşü Test Etme
    func testNavigationToFavoritesAndBack() throws {
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 10), "Ana 'Search' ekranı yüklenmedi.")
        app.buttons["Favorites"].tap()
        let favoritesNavigationBar = app.navigationBars["Favorites"]
        XCTAssertTrue(favoritesNavigationBar.exists, "Favoriler ekranına gidilemedi.")
        favoritesNavigationBar.buttons["Search"].tap()
        XCTAssertTrue(app.navigationBars["Search"].exists, "Favoriler ekranından 'Search' ekranına geri dönülemedi.")
    }

    // TEST 4: Favoriler Ekranının Boş Durumunu Test Etme
    func testFavoritesEmptyState() throws {
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 10), "Ana 'Search' ekranı yüklenmedi.")
        app.buttons["Favorites"].tap()
        XCTAssertTrue(app.navigationBars["Favorites"].exists, "Favoriler ekranına gidilemedi.")
        let emptyStateText = app.staticTexts["You have no favorited words yet.\nAdd words from the recent search list."]
        XCTAssertTrue(emptyStateText.exists, "Favoriler ekranındaki 'You have no favorited...' boş durum metni bulunamadı.")
    }

    // TEST 5: Arama Çubuğunun (Search Bar) Etkileşimini Test Etme
    func testSearchBarIsTypable() throws {
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 10), "Ana 'Search' ekranı yüklenmedi.")
        let searchField = app.searchFields["Search for a word…"]
        XCTAssertTrue(searchField.exists, "Arama çubuğu (placeholder: 'Search for a word…') bulunamadı.")
        searchField.tap()
        searchField.typeText("Hello")
        XCTAssertEqual(searchField.value as? String, "Hello", "Arama çubuğuna 'Hello' yazılamadı.")
    }
}

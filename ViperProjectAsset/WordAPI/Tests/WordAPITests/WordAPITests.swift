import XCTest
@testable import WordAPI

final class WordAPITests: XCTestCase {

    var sut: WordAPI!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let mockSession = URLSession(configuration: config)
        sut = WordAPI(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.clearHandlers()
        super.tearDown()
    }

    func test_fetchWord_Success() async throws {
        
        let successStub = try StubLoader.loadJSON(name: "word_hello_success")
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString.contains("/en/hello"), true)
            return (200, successStub)
        }
        
        let results = try await sut.fetch(word: "hello", language: .english)
        
        XCTAssertFalse(results.isEmpty, "Sonuçlar boş olmamalı")
        XCTAssertEqual(results.count, 1, "Bir giriş bekliyorduk")
        XCTAssertEqual(results.first?.word, "hello")
        XCTAssertEqual(results.first?.meanings.first?.partOfSpeech, "exclamation")
    }

    func test_fetchWord_Failure_WordNotFound() async {
        let errorStub = try! StubLoader.loadJSON(name: "word_not_found_error")
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString.contains("/en/asdfg"), true)
            return (404, errorStub)
        }
        
        do {
            _ = try await sut.fetch(word: "asdfg", language: .english)
            XCTFail("Hata fırlatılması bekleniyordu ama fırlatılmadı.")
        } catch let error as NetworkError {
            guard case .wordNotFound(let apiError) = error else {
                XCTFail("Yanlış türde hata fırlatıldı: \(error)")
                return
            }
            XCTAssertEqual(apiError.title, "No Definitions Found")
        } catch {
            XCTFail("NetworkError dışında bir hata fırlatıldı: \(error)")
        }
    }

    func test_fetchWord_Failure_NetworkError() async {
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
        MockURLProtocol.requestHandler = { request in
            throw networkError
        }
        
        do {
            _ = try await sut.fetch(word: "hello", language: .english)
            XCTFail("Hata fırlatılması bekleniyordu.")
        } catch let error as NetworkError {
            guard case .networkError = error else {
                XCTFail("Yanlış türde hata fırlatıldı: \(error)")
                return
            }
            XCTAssert(true)
        } catch {
            XCTFail("NetworkError dışında bir hata fırlatıldı: \(error)")
        }
    }
}

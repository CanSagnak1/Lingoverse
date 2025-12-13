//
//  MockURLProtocol.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation
import XCTest

final class MockURLProtocol: URLProtocol {
    
    private static let lock = NSLock()
    
    nonisolated(unsafe) private static var _requestHandler: ((URLRequest) throws -> (Int, Data))?
    
    static var requestHandler: ((URLRequest) throws -> (Int, Data))? {
        get {
            lock.withLock {
                _requestHandler
            }
        }
        set {
            lock.withLock {
                _requestHandler = newValue
            }
        }
    }
    
    static func clearHandlers() {
        lock.withLock {
            _requestHandler = nil
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("MockURLProtocol.requestHandler ayarlanmadı.")
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Handler not set"]))
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        do {
            let (statusCode, data) = try handler(request)
            
            guard let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"]
            ) else {
                XCTFail("Failed to create HTTPURLResponse")
                client?.urlProtocol(self, didFailWithError: NSError(domain: "MockError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Response creation failed"]))
                client?.urlProtocolDidFinishLoading(self)
                return
            }
            
            self.client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
            
            self.client?.urlProtocol(self, didLoad: data)
            
            self.client?.urlProtocolDidFinishLoading(self)
            
        } catch {
            self.client?.urlProtocol(self, didFailWithError: error)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        
    }
}


//
//  StubLoader.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation
import XCTest

struct StubLoader {
    static func loadJSON(name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json", subdirectory: nil) else {
            throw StubLoaderError.fileNotFound(name)
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            XCTFail("Stub JSON dosyası yüklenemedi: \(error)")
            throw StubLoaderError.invalidData(name)
        }
    }
}

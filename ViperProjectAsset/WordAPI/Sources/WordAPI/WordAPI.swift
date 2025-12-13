//
//  WordAPI.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public final class WordAPI {
    
    private let client: APIClient
    
    public init() {
        self.client = APIClient(session: .shared)
    }
    
    internal init(session: URLSession) {
        self.client = APIClient(session: session)
    }

    public func fetch(word: String, language: Language) async throws -> [WordEntry] {
        
        guard let safeWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw NetworkError.invalidURL
        }
        
        return try await client.fetch(word: safeWord, language: language)
    }
}

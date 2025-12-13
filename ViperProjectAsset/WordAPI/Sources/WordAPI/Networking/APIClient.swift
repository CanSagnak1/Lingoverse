//
//  APIClient.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

struct APIClient {
    
    private let session: URLSession
    private let baseURL = "https://api.dictionaryapi.dev/api/v2/entries"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch(word: String, language: Language) async throws -> [WordEntry] {
        
        let urlString = "\(baseURL)/\(language.rawValue)/\(word)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.requestFailed(statusCode: 0)
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let entries = try decoder.decode([WordEntry].self, from: data)
                    return entries
                } catch {
                    throw NetworkError.decodingError(error)
                }
            }
            else if httpResponse.statusCode == 404 {
                let decoder = JSONDecoder()
                let apiError: APIError
                do {
                    apiError = try decoder.decode(APIError.self, from: data)
                } catch {
                    throw NetworkError.decodingError(error)
                }
                throw NetworkError.wordNotFound(apiError)
            } else {
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
            }
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
}

//
//  NetworkError.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case requestFailed(statusCode: Int)
    case decodingError(Error)
    case wordNotFound(APIError)
}

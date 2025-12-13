//
//  APIError.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public struct APIError: Codable, Error {
    public let title: String
    public let message: String
    public let resolution: String
}

//
//  Definition.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public struct Definition: Codable, Identifiable {
    public var id: String { definition }
    public let definition: String
    public let synonyms: [String]
    public let antonyms: [String]
    public let example: String?
}

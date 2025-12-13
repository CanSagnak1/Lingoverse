//
//  Meaning.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public struct Meaning: Codable, Identifiable {
    public var id: String { partOfSpeech }
    public let partOfSpeech: String 
    public let definitions: [Definition]
    public let synonyms: [String]
    public let antonyms: [String]
}

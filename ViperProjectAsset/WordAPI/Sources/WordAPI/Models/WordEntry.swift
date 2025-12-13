//
//  WordEntry.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public struct WordEntry: Codable, Identifiable {
    public var id: String { word }
    public let word: String
    public let phonetic: String?
    public let phonetics: [Phonetic]
    public let meanings: [Meaning]
    public let sourceUrls: [String]
}

//
//  Phonetic.swift
//  WordAPI
//
//  Created by Celal Can Sağnak on 1.11.2025.
//

import Foundation

public struct Phonetic: Codable, Identifiable {
    public var id: String { UUID().uuidString }
    public let text: String?
    public let audio: String?
    public let sourceUrl: String?
}

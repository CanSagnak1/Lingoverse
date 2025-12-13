//
//  Models.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation

public struct WKWord: Equatable, Hashable {
    public let term: String
    public let phonetic: String?
    public let audioURL: URL?
    public let meanings: [WKMeaning]
    
    public init(term: String, phonetic: String?, audioURL: URL?, meanings: [WKMeaning]) {
        self.term = term
        self.phonetic = phonetic
        self.audioURL = audioURL
        self.meanings = meanings
    }
}

public struct WKMeaning: Equatable, Hashable {
    public let partOfSpeech: String
    public let definitions: [WKDefinition]
    public let synonyms: [String]
    
    public init(partOfSpeech: String, definitions: [WKDefinition], synonyms: [String]) {
        self.partOfSpeech = partOfSpeech
        self.definitions = definitions
        self.synonyms = synonyms
    }
}

public struct WKDefinition: Equatable, Hashable {
    public let definition: String
    public let example: String?
    
    public init(definition: String, example: String?) {
        self.definition = definition
        self.example = example
    }
}

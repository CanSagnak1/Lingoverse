//
//  SearchDetailInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation

protocol SearchDetailInteractorInput: AnyObject {
    func loadContent()
}

protocol SearchDetailInteractorOutput: AnyObject {
    func didLoadContent(word: WKWord)
    func didFail(message: String)
}

final class SearchDetailInteractor: SearchDetailInteractorInput {
    
    private let initialWord: WKWord
    
    weak var output: SearchDetailInteractorOutput?

    init(initialWord: WKWord) {
        self.initialWord = initialWord
    }
    
    func loadContent() {
        output?.didLoadContent(word: initialWord)
    }
}

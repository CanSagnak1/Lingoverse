//
//  SearchDetailPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 2.11.2025.
//

import Foundation
import UIKit

enum SearchDetailState: Equatable {
    case loading
    case content(header: SearchDetailHeaderVM, segments: SearchDetailSegmentVM, meanings: [SearchDetailMeaningVM])
    case error(String)
}

protocol SearchDetailViewOutput: AnyObject {
    func viewDidLoad()
}

struct SearchDetailHeaderVM: Equatable {
    let title: String
    let phonetic: String?
    let audioURL: URL?
}

struct SearchDetailSegmentVM: Equatable {
    let titles: [String]
}

struct SearchDetailMeaningVM: Equatable {
    let partOfSpeech: String
    let definitions: [SearchDetailDefinitionVM]
    let synonyms: [String]?
}

struct SearchDetailDefinitionVM: Equatable {
    let definition: String
    let example: String?
}

final class SearchDetailPresenter: SearchDetailViewOutput, SearchDetailInteractorOutput {
    
    private weak var view: SearchDetailViewInput?
    private let interactor: SearchDetailInteractorInput
    private let router: SearchDetailRouterProtocol
    
    init(view: SearchDetailViewInput,
         interactor: SearchDetailInteractorInput,
         router: SearchDetailRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    
    func viewDidLoad() {
        view?.render(.loading)
        interactor.loadContent()
    }
    
    func didLoadContent(word: WKWord) {
        let headerVM = SearchDetailHeaderVM(
            title: word.term.capitalized,
            phonetic: word.phonetic,
            audioURL: word.audioURL
        )
        
        let segmentTitles = word.meanings.map { $0.partOfSpeech.capitalized }
        let segmentVM = SearchDetailSegmentVM(titles: segmentTitles)
        let meaningsVM: [SearchDetailMeaningVM] = word.meanings.map { meaning in
            let definitionsVM: [SearchDetailDefinitionVM] = meaning.definitions.enumerated().map { (index, def) in
                SearchDetailDefinitionVM(
                    definition: "\(index + 1) - \(def.definition.capitalized)",
                    example: def.example
                )
            }
            
            let synonyms = meaning.synonyms.isEmpty ? nil : meaning.synonyms
            
            return SearchDetailMeaningVM(
                partOfSpeech: meaning.partOfSpeech.capitalized,
                definitions: definitionsVM,
                synonyms: synonyms
            )
        }
            view?.render(.content(header: headerVM, segments: segmentVM, meanings: meaningsVM))
    }
    
    func didFail(message: String) {
        view?.render(.error(message))
    }
}

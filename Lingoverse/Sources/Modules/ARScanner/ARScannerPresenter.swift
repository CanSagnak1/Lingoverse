//
//  ARScannerPresenter.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import CoreGraphics
import CoreVideo
import Foundation

protocol ARScannerViewOutput: AnyObject {
    func viewDidLoad()
    func didTapScan(pixelBuffer: CVPixelBuffer?)
}

final class ARScannerPresenter: ARScannerViewOutput {
    weak var view: ARScannerViewInput?
    var interactor: ARScannerInteractorInput!
    var router: ARScannerRouterProtocol!

    func viewDidLoad() {
        view?.render(state: .idle)
    }

    func didTapScan(pixelBuffer: CVPixelBuffer?) {
        guard let buffer = pixelBuffer else {
            view?.render(state: .error(Strings.arNoObjectDetected))
            return
        }
        view?.render(state: .scanning)
        interactor.classifyImage(buffer)
    }
}

extension ARScannerPresenter: ARScannerInteractorOutput {
    func didClassify(results: [ARDetectionResult]) {
        if results.isEmpty {
            view?.render(state: .error(Strings.arNoObjectDetected))
        } else {
            view?.render(state: .detected(results))
        }
    }

    func didFailClassification(error: String) {
        view?.render(state: .error(error))
    }
}

// MARK: - Models

struct ARDetectionResult: Identifiable {
    let id = UUID()
    let englishWord: String
    let turkishWord: String
    let confidence: Float
    let boundingBox: CGRect  // Normalized 0-1 coordinates

    init(englishWord: String, turkishWord: String, confidence: Float, boundingBox: CGRect = .zero) {
        self.englishWord = englishWord
        self.turkishWord = turkishWord
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

enum ARScannerState {
    case idle
    case scanning
    case detected([ARDetectionResult])  // Now supports multiple results
    case error(String)
}

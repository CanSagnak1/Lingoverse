//
//  ARScannerInteractor.swift
//  Lingoverse
//
//  Created by Celal Can Sağnak on 29.01.2026.
//

import CoreGraphics
import CoreML
import Foundation
import Vision

protocol ARScannerInteractorInput: AnyObject {
    func classifyImage(_ pixelBuffer: CVPixelBuffer)
}

protocol ARScannerInteractorOutput: AnyObject {
    func didClassify(results: [ARDetectionResult])
    func didFailClassification(error: String)
}

final class ARScannerInteractor: ARScannerInteractorInput {
    weak var output: ARScannerInteractorOutput?

    private var detectionRequest: VNCoreMLRequest?
    private let translationService = ARTranslationService()
    private let googleClient = GoogleTranslationClient.shared
    private let maxResults = 5  // Maximum objects to detect

    init() {
        setupModel()
    }

    private func setupModel() {
        // Try YOLOv3 first, fallback to MobileNetV2
        let modelName = "YOLOv3"

        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc"),
            let model = try? MLModel(contentsOf: modelURL),
            let visionModel = try? VNCoreMLModel(for: model)
        else {
            print("Failed to load \(modelName) model, trying alternative...")
            setupFallbackModel()
            return
        }

        detectionRequest = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        detectionRequest?.imageCropAndScaleOption = .scaleFill
        print("\(modelName) model loaded successfully")
    }

    private func setupFallbackModel() {
        guard let modelURL = Bundle.main.url(forResource: "MobileNetV2", withExtension: "mlmodelc"),
            let model = try? MLModel(contentsOf: modelURL),
            let visionModel = try? VNCoreMLModel(for: model)
        else {
            print("Failed to load fallback model")
            return
        }

        detectionRequest = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        detectionRequest?.imageCropAndScaleOption = .centerCrop
    }

    func classifyImage(_ pixelBuffer: CVPixelBuffer) {
        guard let request = detectionRequest else {
            output?.didFailClassification(error: "Model not loaded")
            return
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            output?.didFailClassification(error: error.localizedDescription)
        }
    }

    private func handleDetectionResults(request: VNRequest, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {
                self.output?.didFailClassification(error: error.localizedDescription)
            }
            return
        }

        var detectedResults: [ARDetectionResult] = []

        // Try object detection results (YOLOv3) - supports multiple objects
        if let objectResults = request.results as? [VNRecognizedObjectObservation] {
            let topResults = objectResults.prefix(maxResults).filter {
                $0.labels.first?.confidence ?? 0 > 0.15
            }

            for observation in topResults {
                guard let label = observation.labels.first else { continue }

                let identifier = label.identifier
                let mainWord =
                    identifier.components(separatedBy: ", ").first?.lowercased()
                    ?? identifier.lowercased()

                let result = ARDetectionResult(
                    englishWord: mainWord.capitalized,
                    turkishWord: mainWord.capitalized,  // Placeholder, will be translated
                    confidence: label.confidence,
                    boundingBox: observation.boundingBox
                )
                detectedResults.append(result)
            }
        }

        // Try classification results (MobileNetV2 fallback) - single object only
        if detectedResults.isEmpty,
            let classResults = request.results as? [VNClassificationObservation],
            let topResult = classResults.first,
            topResult.confidence > 0.3
        {
            let identifier = topResult.identifier
            let mainWord =
                identifier.components(separatedBy: ", ").first?.lowercased()
                ?? identifier.lowercased()

            let result = ARDetectionResult(
                englishWord: mainWord.capitalized,
                turkishWord: mainWord.capitalized,
                confidence: topResult.confidence,
                boundingBox: CGRect(x: 0.25, y: 0.25, width: 0.5, height: 0.5)  // Center box
            )
            detectedResults.append(result)
        }

        // No results found
        if detectedResults.isEmpty {
            DispatchQueue.main.async {
                self.output?.didFailClassification(error: Strings.arNoObjectDetected)
            }
            return
        }

        // Translate all results
        translateAndReport(results: detectedResults)
    }

    /// Translate all detected words and report results
    private func translateAndReport(results: [ARDetectionResult]) {
        Task {
            var translatedResults: [ARDetectionResult] = []

            for result in results {
                let englishWord = result.englishWord.lowercased()

                // First try offline dictionary
                let offlineTranslation = translationService.translate(word: englishWord)

                var turkishWord = offlineTranslation

                // If offline dictionary returned the same word (no translation), try Google API
                if offlineTranslation.lowercased() == englishWord {
                    if let googleTranslation = await googleClient.translate(
                        text: englishWord,
                        from: "en",
                        to: "tr"
                    ) {
                        turkishWord = googleTranslation
                    }
                }

                let translatedResult = ARDetectionResult(
                    englishWord: result.englishWord,
                    turkishWord: turkishWord,
                    confidence: result.confidence,
                    boundingBox: result.boundingBox
                )
                translatedResults.append(translatedResult)
            }

            await MainActor.run {
                self.output?.didClassify(results: translatedResults)
            }
        }
    }
}

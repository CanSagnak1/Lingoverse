import AVFoundation
import Combine
import Foundation
import Speech

// MARK: - SpeechServiceProtocol

protocol SpeechServiceProtocol {
    var isRecording: Bool { get }
    var recognizedTextPublisher: AnyPublisher<String, Never> { get }

    func speak(text: String, language: String)
    func startRecording(language: String) throws
    func stopRecording()
    func requestPermissions(completion: @escaping (Bool) -> Void)
}

// MARK: - SpeechManager

final class SpeechManager: NSObject, SpeechServiceProtocol {

    // MARK: - Properties

    static let shared = SpeechManager()

    private let synthesizer = AVSpeechSynthesizer()
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published private var _isRecording = false
    var isRecording: Bool { _isRecording }

    private let _recognizedTextSubject = PassthroughSubject<String, Never>()
    var recognizedTextPublisher: AnyPublisher<String, Never> {
        _recognizedTextSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - TTS (Text-to-Speech)

    func speak(text: String, language: String = "en-US") {
        // Configure Audio Session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session for TTS: \(error)")
        }

        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        synthesizer.speak(utterance)
    }

    // MARK: - STT (Speech-to-Text)

    func startRecording(language: String = "en-US") throws {
        // Cancel existing task if any
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        // Force specific language for recognition if needed, otherwise uses locale
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: language))

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) {
            [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                self._recognizedTextSubject.send(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
                self._isRecording = false
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        _isRecording = true
    }

    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        _isRecording = false
    }

    // MARK: - Permissions

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                        DispatchQueue.main.async {
                            completion(allowed)
                        }
                    }
                default:
                    completion(false)
                }
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension SpeechManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance
    ) {
        // Handle finish if needed
    }
}

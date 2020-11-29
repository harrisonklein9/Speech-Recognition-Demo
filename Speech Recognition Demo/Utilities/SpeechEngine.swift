//
//  SpeechEngine.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/27/20.
//

import Foundation
import Speech

open class SpeechEngine: NSObject {
    
    //MARK: - Properties
    
    /// The property responsible for managing the speech recognition process
    /// - initialized with localized language
    open var speechRecognizer: SFSpeechRecognizer
    
    open var canRecognizeSpeech: Bool = false
    
    /// Speech recognition request needed to identify captured audio
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    /// Determines the state of the current recognition task
    private var recognitionTask: SFSpeechRecognitionTask?
    
    /// The property responsible for generating and processing audio
    private let audioEngine = AVAudioEngine()
    
    //MARK: - Initializers
    
    init(speechRecognizer: SFSpeechRecognizer) {
        //initialize the speech recognizer before calling initializer of superclass
        self.speechRecognizer = speechRecognizer
        
        super.init()
        self.speechRecognizer.delegate = self
    }
    
    //MARK: - Class Methods
    
    /// Gets current speech recognition auth status and assigns to canRecord boolean value
    open func getStatus(completion: @escaping () -> ()) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                self.canRecognizeSpeech = true
                break
            case .denied, .restricted, .notDetermined:
                self.canRecognizeSpeech = false
                break
            default:
                self.canRecognizeSpeech = false
                break
            }
            completion()
        }
    }
    
    /// Transribes audio from a localized recording, will return nil if audio is not able to be transcribed
    open func transcribeAudio(fromUrl url: URL, textProgress: @escaping (String?) -> (), completion: @escaping () -> ()) {
        let request = SFSpeechURLRecognitionRequest(url: url)
        var transcribedText: String!
        speechRecognizer.recognitionTask(with: request) { (result, error) in
            if let result = result {
                let transcription = result.bestTranscription
                transcribedText = transcription.formattedString
                print(transcribedText ?? "")
                textProgress(transcribedText)
                if result.isFinal {
                    completion()
                }
            }
        }
    }
}

//MARK: - SFSpeechRecognizerDelegate

extension SpeechEngine: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        canRecognizeSpeech = available
    }
    
    
}

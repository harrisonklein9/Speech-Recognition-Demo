//
//  TranscriptionViewController.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/28/20.
//

import UIKit
import Speech

class TranscriptionViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var transcriptionLabel: UILabel!
    
    var recording: Recording!
    
    private var speechEngine = SpeechEngine(speechRecognizer: SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        titleLabel.text = recording.name
        speechEngine.getStatus {
            if self.speechEngine.canRecognizeSpeech {
                self.speechEngine.transcribeAudio(fromUrl: self.recording.path) {
                    self.transcriptionLabel.text = $0
                }
            }
        }
    }
}

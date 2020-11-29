//
//  TranscriptionViewController.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/28/20.
//

import UIKit
import Speech

class TranscriptionViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var transcriptionLabel: UILabel!
    
    var recording: Recording!
    
    private var speechEngine = SpeechEngine(speechRecognizer: SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        setupView()
    }
    
    private func setupProgressView() {
        progressView.layer.cornerRadius = 10
        progressView.layer.shadowColor = UIColor.black.cgColor
        progressView.layer.shadowRadius = 4
        progressView.layer.shadowOffset = .zero
        progressView.layer.shadowOpacity = 0.5
    }

    private func setupView() {
        titleLabel.text = recording.name
        speechEngine.getStatus {
            if self.speechEngine.canRecognizeSpeech {
                DispatchQueue.main.async {
                    self.progressView.isHidden = false
                }
                self.speechEngine.transcribeAudio(fromUrl: self.recording.path, textProgress: {
                    self.transcriptionLabel.text = $0
                }) {
                    self.progressView.isHidden = true
                }
            }
        }
    }
}

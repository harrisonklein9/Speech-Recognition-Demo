//
//  TranscriberViewController.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/29/20.
//

import UIKit
import Speech

class TranscriberViewController: UIViewController {
    
    @IBOutlet weak var transcribedTextLabel: UILabel!
    @IBOutlet weak var transcribeButton: UIButton!
    
    private var isRecording: Bool = false {
        didSet {
            transcribeButton.setTitle(isRecording ? "Stop" : "Transcribe", for: .normal)
        }
    }
    
    private var speechEngine = SpeechEngine(speechRecognizer: SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func transcribeButtonPressed(_ sender: UIButton) {
        if !isRecording {
            speechEngine.getStatus {
                if self.speechEngine.canRecognizeSpeech {
                    self.speechEngine.startTranscribing {
                        self.transcribedTextLabel.text = $0
                    }
                }
            }
        }
        else {
            speechEngine.stopTranscribing()
        }
        isRecording = !isRecording
    }
}

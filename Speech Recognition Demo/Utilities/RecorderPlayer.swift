//
//  RecorderPlayer.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/28/20.
//

import Foundation
import AVFoundation

protocol RecorderPlayerDelegate {
    func recorderPlayer(_ recorderPlayer: RecorderPlayer, didFinishRecording: Bool)
    func recorderPlayer(_ recorderPlayer: RecorderPlayer, didGetErrorWhileRecording: Error)
}

class RecorderPlayer: NSObject {
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var session = AVAudioSession.sharedInstance()
    
    var delegate: RecorderPlayerDelegate?
    
    /// Requests recording permission from user if first time, otherwise returns users privacy capability
    func setupSession(recordingAllowed: @escaping (Bool) -> ()) {
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            session.requestRecordPermission { (permission) in
                recordingAllowed(permission)
            }
        }
        catch {
            recordingAllowed(false)
        }
    }
    
    /// starts audio recording with default settings
    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let randomDocumentId = UUID().uuidString
        
        // get default documents path
        guard let documentPath = getDocumentsDirectory() else {
            return
        }
        
        let audioFilename = documentPath.appendingPathComponent("\(randomDocumentId).m4a")
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.isMeteringEnabled = true
            self.audioRecorder.delegate = self
            self.audioRecorder.record()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func finishRecording() {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    /// Returns an array of recordings from the default documents directory
    func getRecordings() -> [Recording] {
        var recordings = [Recording]()
        let filemanager = FileManager.default
        if let documentsDirectory = getDocumentsDirectory() {
            do {
                let paths = try filemanager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
                for path in paths {
                    let recording = Recording(name: path.lastPathComponent, path: path)
                    recordings.append(recording)
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return recordings
    }
    
    /// gets default document directory in sandbox
    private func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension RecorderPlayer: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        recorder.stop()
        if let error = error {
            print("Audio recorder did encounter error: ", error.localizedDescription)
            delegate?.recorderPlayer(self, didGetErrorWhileRecording: error)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.recorderPlayer(self, didFinishRecording: flag)
    }
}

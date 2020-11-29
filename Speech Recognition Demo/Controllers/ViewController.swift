//
//  ViewController.swift
//  Speech Recognition Demo
//
//  Created by Harrison Klein on 11/27/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    private var recorderPlayer = RecorderPlayer()
    private var isRecording: Bool = false {
        didSet {
            recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
        }
    }
    private var recordings = [Recording]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Speech Recognition Demo"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecordingCell")
        recorderPlayer.setupSession { success in
            DispatchQueue.main.async {
                self.recordButton.isEnabled = success
            }
        }
        recorderPlayer.delegate = self
        
        getRecordings()
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        isRecording ? recorderPlayer.finishRecording() : recorderPlayer.startRecording()
        isRecording = !isRecording
    }
    
    @IBAction func transcribeButtonPressed(_ sender: UIButton) {
        let vc = TranscriberViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func getRecordings() {
        recordings = recorderPlayer.getRecordings()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)
        cell.textLabel?.text = recordings[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TranscriptionViewController()
        vc.recording = recordings[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: RecorderPlayerDelegate {
    func recorderPlayer(_ recorderPlayer: RecorderPlayer, didFinishRecording: Bool) {
        isRecording = false
        getRecordings()
    }
    
    func recorderPlayer(_ recorderPlayer: RecorderPlayer, didGetErrorWhileRecording: Error) {
        isRecording = false
    }
}

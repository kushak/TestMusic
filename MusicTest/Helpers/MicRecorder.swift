//
//  AudioRecorder.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 01.11.2023.
//

import AVFoundation

final class MicRecorder: NSObject {
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var completion: (URL) -> Void = { _ in }

    func startRecord() {
        audioSession.requestRecordPermission() { [unowned self] allowed in
//            DispatchQueue.main.async {
                if allowed {
                    self.startRecording()
                }
//            }
        }
    }

    func stopRecord(completion: @escaping (URL) -> Void) {
        self.completion = completion
        stopRecording()
    }

    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("mic\(Date().timeIntervalSince1970).m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            self.audioRecorder = audioRecorder
        } catch {
            stopRecording()
        }
    }

    private func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


extension MicRecorder: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully success: Bool) {
        if !success {
            print("Fuuu")
        } else {
            completion(recorder.url)
        }
    }
}

//
//  AudioOutputRecoder.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.11.2023.
//

import AVFoundation

final class AudioOutputRecoder {
    private let engine: AVAudioEngine
    private var file: AVAudioFile?
    private var url: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("record\(Date().timeIntervalSince1970).caf")
    }

    init(engine: AVAudioEngine) {
        self.engine = engine
    }

    func record() {
        if !engine.isRunning {
            try? engine.start()
        }
        file = try? AVAudioFile(forWriting: url, settings: engine.mainMixerNode.inputFormat(forBus: 0).settings)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: engine.mainMixerNode.outputFormat(forBus: 0)) { (buffer, time) -> Void in
            do {
                try self.file?.write(from: buffer)
            } catch {
                print(error.localizedDescription)
                print(error)
            }
            return
        }
    }

    func stop() -> URL? {
        engine.mainMixerNode.removeTap(onBus: 0)
        return file?.url
    }
}

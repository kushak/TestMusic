//
//  AudioOutputRecoder.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.11.2023.
//

import AVFoundation

final class AudioOutputRecoder {
    private let engine: AudioEngine
    private var file: AVAudioFile?
    private var url: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("record\(Date().timeIntervalSince1970).caf")
    }

    init(engine: AudioEngine) {
        self.engine = engine
    }

    func record() {
        file = try? AVAudioFile(forWriting: url, settings: engine.settings)
        engine.add(delegate: self)
    }

    func stop() -> URL? {
        engine.remove(delegate: self)
        return file?.url
    }
}

extension AudioOutputRecoder: AudioEngineDelegate {
    func tapBlock(buffer: AVAudioPCMBuffer) {
        do {
            try self.file?.write(from: buffer)
        } catch {
            print(error.localizedDescription)
            print(error)
        }
        return
    }
}

//
//  AudioEngine.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 05.11.2023.
//

import AVFoundation

protocol AudioEngineDelegate: AnyObject {
    func tapBlock(buffer: AVAudioPCMBuffer)
}

final class AudioEngine {
    var settings: [String: Any] { engine.mainMixerNode.inputFormat(forBus: 0).settings }
    private let engine: AVAudioEngine
    private let delegates = NSHashTable<AnyObject>.weakObjects()

    init(engine: AVAudioEngine) {
        self.engine = engine
        _ = engine.mainMixerNode
        engine.prepare()

        try! engine.start()
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: engine.mainMixerNode.outputFormat(forBus: 0)
        ) { [weak self] buffer, time -> Void in
            self?.delegates.allObjects.forEach {
                ($0 as? AudioEngineDelegate)?.tapBlock(buffer: buffer)
            }
        }
    }

    func add(delegate: AudioEngineDelegate) {
        delegates.add(delegate as AnyObject)
    }

    func remove(delegate: AudioEngineDelegate) {
        delegates.remove(delegate as AnyObject)
    }
}

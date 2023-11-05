//
//  VisulizerWorker.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 04.11.2023.
//

import AVFoundation
import Accelerate

enum VisualizerConstants {
    static let updateInterval = 0.03
    static let barAmount = 40
    static let magnitudeLimit: Float = 32
}

final class VisualizerWorker {

    typealias Constants = VisualizerConstants

    private let engine: AVAudioEngine
    private let bufferSize = 1024

//    let player = AVAudioPlayerNode()
    var fftMagnitudes: [Float] = []

    init(engine: AVAudioEngine) {
        self.engine = engine
        _ = engine.mainMixerNode

        engine.prepare()
        try! engine.start()

        /**
         - Music: Moonlight Sonata Op. 27 No. 2 - III. Presto
         - Performed by: Paul Pitman
         - https://musopen.org/music/2547-piano-sonata-no-14-in-c-sharp-minor-moonlight-sonata-op-27-no-2/
         */
//        let audioFile = try! AVAudioFile(
//            forReading: Bundle.main.url(forResource: "music", withExtension: "mp3")!
//        )
//        let format = audioFile.processingFormat
//
//        engine.attach(player)
//        engine.connect(player, to: engine.mainMixerNode, format: format)
//
//        player.scheduleFile(audioFile, at: nil)

        let fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            UInt(bufferSize),
            vDSP_DFT_Direction.FORWARD
        )

        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: UInt32(bufferSize),
            format: nil
        ) { [self] buffer, _ in
            let channelData = buffer.floatChannelData?[0]
            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
        }
    }

    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)

        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }

        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)

        var magnitudes = [Float](repeating: 0, count: Constants.barAmount)

        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(Constants.barAmount))
            }
        }

        var normalizedMagnitudes = [Float](repeating: 0.0, count: Constants.barAmount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(Constants.barAmount))

        return normalizedMagnitudes
    }
}


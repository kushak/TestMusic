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

    private let engine: AudioEngine
    private let bufferSize = 1024
    private lazy var fftSetup = vDSP_DFT_zop_CreateSetup(
        nil,
        UInt(bufferSize),
        vDSP_DFT_Direction.FORWARD
    )

    var fftMagnitudes: [Float] = []

    init(engine: AudioEngine) {
        self.engine = engine
        engine.add(delegate: self)
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

extension VisualizerWorker: AudioEngineDelegate {

    func tapBlock(buffer: AVAudioPCMBuffer) {
        let channelData = buffer.floatChannelData?[0]
        fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
    }
}

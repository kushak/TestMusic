//
//  Visualizer.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 04.11.2023.
//

import Charts
import SwiftUI

enum Constants {
    static let updateInterval = 0.03
    static let barAmount = 10
    static let magnitudeLimit: Float = 15
}

struct Visualizer: View {
    let audioProcessing: VisualizerWorker
    let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()

    @State var isPlaying = false
    @State var data: [Float] = []

    init(worker: VisualizerWorker) {
        audioProcessing = worker
    }

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Chart(Array(data.enumerated()), id: \.0) { index, magnitude in
                    BarMark(
                        x: .value("Frequency", String(index)),
                        y: .value("Magnitude", magnitude)
                    )
                    .foregroundStyle(
                        Color(
                            red: 1,
                            green: 1,
                            blue: 1
                        )
                    )
                }
                .onReceive(timer, perform: updateData)
                .chartYScale(domain: 0 ... Constants.magnitudeLimit)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
            }
            .shadow(radius: 40)
        }
        .preferredColorScheme(.dark)
    }

    func updateData(_: Date) {
        withAnimation(.easeOut(duration: 0.08)) {
            data = audioProcessing.fftMagnitudes.map {
                let value = min($0, Constants.magnitudeLimit)

//                if value != 0 {
//                    print(value)
//                }

                return value
            }
        }
    }
}

import AVFoundation
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Visualizer(worker: .init(engine: AudioEngine(engine: AVAudioEngine())))
    }
}

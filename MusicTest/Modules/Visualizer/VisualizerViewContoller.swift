//
//  VisualizerViewContoller.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 04.11.2023.
//

import AVFoundation
import SwiftUI

protocol VisualizerInput: UIViewController {

}

final class VisualizerViewContoller: UIHostingController<Visualizer>, VisualizerInput {

    init(engine: AudioEngine) {
        let visualizer = Visualizer(worker: VisualizerWorker(engine: engine))
        super.init(rootView: visualizer)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

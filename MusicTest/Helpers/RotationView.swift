//
//  RotationView.swift
//  MusicTest
//
//  Created by Oleg Shipulin on 02.12.2023.
//

import SwiftUI

struct Rotation: View {
    @State var degrees = 0.0

    var body: some View {
//        VStack {
            Image("Rectangle")
//            Button("Animate..!") {
//                withAnimation {
//                    self.degrees += 360
//                }
//            }
//            .padding(20)
//            .background(Color.blue.opacity(0.8))
//            .foregroundColor(Color.white)
            .rotation3DEffect(.degrees(degrees), axis: (x: 1, y: 1, z: 1))


//            Text("SwiftUI Animations")
//                .rotation3DEffect(.degrees(45), axis: (x: 1, y: 0, z: 0))
//        }
    }

    var uiView: UIView {
        return UIHostingController(rootView: self).view
    }

    func updateAnimation() {
        withAnimation {
            self.degrees += .random(in: 0...360)
        }
    }
}


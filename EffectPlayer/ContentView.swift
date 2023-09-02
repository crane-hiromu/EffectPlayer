//
//  ContentView.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/06/12.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    let audioSoundModel = AudioSoundModel()
    let microphoneModel = MicrophoneModel()
    let audioMgr = AudioMgr()
    
    var body: some View {
        VStack {
            Button("1. wav play demo") {
                audioSoundModel.disconnect()
                audioSoundModel.tap_1()
            }
            Button("2. Oscillator play demo") {
                audioSoundModel.disconnect()
                audioSoundModel.tap_2()
            }
            Button("3. wav effect demo") {
                audioSoundModel.disconnect()
                audioSoundModel.tap_3()
            }
        }
        VStack {
            Button("normal") {
                microphoneModel.disconnect()
                microphoneModel.normal()
            }
            Button("withReverb") {
                microphoneModel.disconnect()
                microphoneModel.withReverb()
            }
            Button("withDelay") {
                microphoneModel.disconnect()
                microphoneModel.withDelay()
            }
            Button("withDistotion") {
                microphoneModel.disconnect()
                microphoneModel.withDistotion()
            }
            Button("withKitDistotion") {
                microphoneModel.disconnect()
                microphoneModel.withKitDistotion()
            }
            Button("withRhinoGuitarProcessor") {
                microphoneModel.disconnect()
                microphoneModel.withRhinoGuitarProcessor()
            }
            Button("withSigmoidDistotion") {
                microphoneModel.disconnect()
                microphoneModel.withSigmoidDistotion()
            }
            Button("applyDistortionToBufferFromCpp") {
                microphoneModel.disconnect()
                microphoneModel.applyDistortionToBufferFromCpp()
            }
//            Button("applyDistortionToBufferFromCppWithEngine") {
//                microphoneModel.disconnect()
//                microphoneModel.applyDistortionToBufferFromCppWithEngine()
//            }
        }
        .padding()
        .onAppear {
//            do {
//                try audioMgr.connect()
//            } catch {
//
//            }
            microphoneModel.connect()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
        VStack(alignment: .leading) {
            Button("1. Play wav") {
                audioSoundModel.disconnect()
                audioSoundModel.playWav()
            }
            Button("2. Play AudioKit Oscillator") {
                audioSoundModel.disconnect()
                audioSoundModel.playOscillator()
            }
            Button("3. Play wav with AudioKit effect") {
                audioSoundModel.disconnect()
                audioSoundModel.playWavWithAudioKit()
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

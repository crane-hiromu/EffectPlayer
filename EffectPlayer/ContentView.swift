//
//  ContentView.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/06/12.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    private let audioSoundModel = AudioSoundModel()
    private let microphoneModel = MicrophoneModel()
    
    var body: some View {
        VStack {
            Text("Play sound demo")
            samplePlayWavButton
            samplePlayAudioKitOscillatorButton
            samplePlayWavWithAudioKitEffectButton
        }
        VStack {
            Text("Effect demo")
            effectCleanButton
            effectReverbButton
            effectDelayButton
            effectDistorionFromAVAudioUnitButton
            effectDistorionFromAudioKitButton
            effectRhinoGuitarProcessorButton
            effectSwiftSigmoidDistotionButton
            effectCppSigmoidDistotionButton
        }
        .padding()
        .onAppear { microphoneModel.connect() }
        .onDisappear { microphoneModel.disconnect() }
    }
}

private extension ContentView {
    
    // Audio sample
    
    var samplePlayWavButton: some View {
        Button(action: {
            audioSoundModel.disconnect()
            audioSoundModel.playWav()
        }) {
            buttonText("1. Play wav")
        }
    }
    var samplePlayAudioKitOscillatorButton: some View {
        Button(action: {
            audioSoundModel.disconnect()
            audioSoundModel.playOscillator()
        }) {
            buttonText("2. Play AudioKit Oscillator")
        }
    }
    var samplePlayWavWithAudioKitEffectButton: some View {
        Button(action: {
            audioSoundModel.disconnect()
            audioSoundModel.playWavWithAudioKit()
        }) {
            buttonText("3. Play wav with AudioKit effect")
        }
    }
    
    // Effect Sample
    
    var effectCleanButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachClean()
        }) {
            buttonText("Clean")
        }
    }
    
    var effectReverbButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachReverb()
        }) {
            buttonText("Reverb")
        }
    }
    
    var effectDelayButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachDelay()
        }) {
            buttonText("Delay")
        }
    }
    
    var effectDistorionFromAVAudioUnitButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachDistotion()
        }) {
            buttonText("Distorion from AVAudioUnit")
        }
    }
    
    var effectDistorionFromAudioKitButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachAudioKitDistotion()
        }) {
            buttonText("Distorion from AudioKit")
        }
    }
    
    var effectRhinoGuitarProcessorButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachRhinoGuitarProcessor()
        }) {
            buttonText("Distorion from RhinoGuitarProcessorButton")
        }
    }
    
    var effectSwiftSigmoidDistotionButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachSwiftSigmoidDistotion()
        }) {
            buttonText("Sigmoid Distotion on Swift")
        }
    }
    
    var effectCppSigmoidDistotionButton: some View {
        Button(action: {
            microphoneModel.disconnect()
            microphoneModel.attachCppSigmoidDistortion()
        }) {
            buttonText("Sigmoid Distotion on C++")
        }
    }
    
    // Common
    
    func buttonText(_ label: String) -> some View {
        Text(label)
            .bold()
            .padding()
            .frame(width: 400, height: 44)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(25)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

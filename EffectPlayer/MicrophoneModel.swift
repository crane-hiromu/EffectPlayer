//
//  MicrophoneModel.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/07/09.
//

import Foundation
import AVFAudio
import AVFoundation
import AudioKit
import SoundpipeAudioKit
import DevoloopAudioKit
import Combine

final class AudioMgr {
    let session = AVAudioSession.sharedInstance()
    let engine = AVAudioEngine()
    
    func connect() throws {
        try session.setCategory(.playAndRecord)
        try session.setActive(true)

        engine.connect(engine.inputNode, to: engine.outputNode, format: nil)
        engine.prepare()
        try engine.start()
    }
}

final class MicrophoneModel {
    
    var engine = AVAudioEngine()
    var audioEngine = AudioEngine()
    let processor = DistortionProcessorWrapper()
    
    var cancellable: AnyCancellable?
    let firebaseModel: FirebaseModel = {
        let model = FirebaseModel()
        model.startMessageListener()
        return model
    }()
    
    func connect() {
        print("----\(#function)----")
        
        do {
            Settings.bufferLength = .short
            try Settings.setSession(
                category: .playAndRecord,
                with: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP]
            )
        } catch let err {
            print(err)
        }
        
        cancellable = firebaseModel
            .effectType
            .compactMap { $0 }
            .sink { [weak self] type in
                self?.disconnect()
                
                switch type {
                case .clean: self?.normal()
                case .disconnect: break
                case .avAudioEngine: self?.withDistotion()
                case .devoloopAudioKit: self?.withRhinoGuitarProcessor()
                case .cppSigmoid: self?.applyDistortionToBufferFromCpp()
                }
            }
    }
    
    func disconnect() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        engine = AVAudioEngine()
        audioEngine = AudioEngine()
        
        // objc
        processor.engine.stop()
        processor.engine?.inputNode.removeTap(onBus: 0)
        processor.engine = AVAudioEngine()
    }
    
    func normal() {
        let input = engine.inputNode
        let output = engine.outputNode
        engine.connect(input, to: output, format: nil)
        engine.prepare()
        
        do {
            try engine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withReverb() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)
        
        let reverb = AVAudioUnitReverb()
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 40
        engine.attach(reverb)
        engine.connect(input, to: reverb, format: format)
        engine.connect(reverb, to: output, format: format)
        engine.prepare()
        
        do {
            try engine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withDelay() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)
        
        let delay = AVAudioUnitDelay()
        delay.delayTime = 0.4
        delay.wetDryMix = 25
        engine.attach(delay)
        engine.connect(input, to: delay, format: format)
        engine.connect(delay, to: output, format: format)
        engine.prepare()

        do {
            try engine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withDistotion() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)

//        let comp = AVAudioUnitEffect(audioComponentDescription: .init(
//            appleEffect: kAudioUnitSubType_DynamicsProcessor)
//        )
//        engine.attach(comp)
        
        let distortion = AVAudioUnitDistortion()
//        distortion.loadFactoryPreset(.drumsBitBrush)
        distortion.preGain = 5
        distortion.wetDryMix = 20
        engine.attach(distortion)
        
//        let reverb = AVAudioUnitReverb()
//        reverb.loadFactoryPreset(.smallRoom)
//        reverb.wetDryMix = 20
//        engine.attach(reverb)

        engine.connect(input, to: distortion, format: format)
        engine.connect(distortion, to: output, format: format)
        engine.prepare()

        do {
            try engine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withKitDistotion() {
        guard let input = audioEngine.input else { return }

        let distortion = Distortion(input)
        distortion.softClipGain = 0
        distortion.finalMix = 50
        audioEngine.output = distortion
        
        do {
            try audioEngine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withRhinoGuitarProcessor() {
        if audioEngine.input == nil {
            return
        }
        
        let comp = DynaRageCompressor(audioEngine.input!)
        
        
        let node = RhinoGuitarProcessor(comp, distortion: 3)
//        RhinoGuitarProcessor(
//            comp,
//            preGain: 0.5,
//            postGain: 0.5,
//            lowGain: 0.5,
//            midGain: 0.5,
//            highGain: 0.5,
//            distortion: 5
//        )
        audioEngine.output = Reverb(node)
        
        do {
            try audioEngine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func withSigmoidDistotion() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        input.installTap(onBus: .zero,
                         bufferSize: 1024,
                         format: format) { [weak self] buffer, time in
            self?.applyDistortion(to: buffer, gain: 1.5, threshold: 0.8)
            player.scheduleBuffer(buffer)
        }
        
        let comp = AVAudioUnitEffect(audioComponentDescription: .init(
            appleEffect: kAudioUnitSubType_DynamicsProcessor)
        )
        engine.attach(comp)
        
        engine.connect(player, to: comp, format: format)
        engine.connect(comp, to: output, format: format)
        engine.prepare()
        
        do {
            try engine.start()
            player.play()
        } catch {
            debugPrint("failure")
        }
    }
    
    func applyDistortionToBufferFromCpp() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        input.installTap(onBus: .zero,
                         bufferSize: 1024,
                         format: format) { [weak self] buffer, _ in
            self?.processor.applyDistortion(to: buffer)
            player.scheduleBuffer(buffer)
        }
        
        let comp = AVAudioUnitEffect(audioComponentDescription: .init(
            appleEffect: kAudioUnitSubType_DynamicsProcessor)
        )
        engine.attach(comp)
        
        engine.connect(player, to: comp, format: format)
        engine.connect(comp, to: output, format: format)
        engine.prepare()
        
        do {
            try engine.start()
            player.play()
        } catch {
            debugPrint("failure")
        }
    }
}

import CoreAudio

// sigmoid
extension MicrophoneModel {
    
    func applyDistortion(to buffer: AVAudioPCMBuffer, gain: Float, threshold: Float) {
        guard let floatChannelData = buffer.floatChannelData else { return }
        
        // ex ステレオオーディオ信号の場合、左と右の2つのチャンネル、左側と右側の音声情報を格納
        for channel in 0..<Int(buffer.format.channelCount) {
            let channelData = floatChannelData[channel]
            
            // サンプリングすることで得られた、フレームごとのサンプル値を、シグモイド関数で変化させる
            for frame in 0..<Int(buffer.frameLength) {
                let sample = channelData[frame]
                let distortedSample = sigmoidDistortion(sample: sample, gain: gain, threshold: threshold)
                channelData[frame] = distortedSample
            }
        }
    }

    func sigmoidDistortion(sample: Float, gain: Float, threshold: Float) -> Float {
        let k = 2 / (1 - exp(-2 * threshold))
        let distortedSample = (1 + exp(-2 * threshold * (sample * gain))) / (1 + exp(-2 * threshold)) - 0.5
        return distortedSample * k
    }
}

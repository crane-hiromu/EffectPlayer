//
//  MicrophoneModel.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/07/09.
//

import Foundation
import AVFAudio
import AVFoundation
import CoreAudio
import AudioKit
import SoundpipeAudioKit
import DevoloopAudioKit
import Combine

final class MicrophoneModel {
    
    private var engine = AVAudioEngine()
    private var audioEngine = AudioEngine()
    private let processor = DistortionProcessorWrapper()
    
    private var cancellable: AnyCancellable?
    private let firebaseModel: FirebaseModel = {
        let model = FirebaseModel()
        model.startMessageListener()
        return model
    }()
    
    func connect() {
        do {
            Settings.bufferLength = .short
            try Settings.setSession(
                category: .playAndRecord,
                with: [.defaultToSpeaker, .mixWithOthers, .allowBluetoothA2DP]
            )
        } catch {
            print("failure: \(error)")
        }
        bind()
    }
    
    func bind() {
        cancellable = firebaseModel
            .effectType
            .compactMap { $0 }
            .sink { [weak self] type in
                self?.handleFirebase(with: type)
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
    
    func attachClean() {
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
    
    func attachReverb() {
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
    
    func attachDelay() {
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
    
    func attachDistotion() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)

        let distortion = AVAudioUnitDistortion()
        distortion.preGain = 5
        distortion.wetDryMix = 20
        engine.attach(distortion)

        engine.connect(input, to: distortion, format: format)
        engine.connect(distortion, to: output, format: format)
        engine.prepare()

        do {
            try engine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func attachAudioKitDistotion() {
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
    
    func attachRhinoGuitarProcessor() {
        guard let input = audioEngine.input else { return }
        
        let comp = DynaRageCompressor(input)
        let node = RhinoGuitarProcessor(comp, distortion: 3)
        audioEngine.output = node
        
        do {
            try audioEngine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func attachRhinoGuitarProcessorWithReverb() {
        guard let input = audioEngine.input else { return }
        
        let comp = DynaRageCompressor(input)
        let node = RhinoGuitarProcessor(comp, distortion: 3)
        audioEngine.output = Reverb(node)
        
        do {
            try audioEngine.start()
        } catch {
            debugPrint("failure")
        }
    }
    
    func attachSwiftSigmoidDistotion() {
        let input = engine.inputNode
        let output = engine.outputNode
        let format = engine.inputNode.inputFormat(forBus: 0)
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        input.installTap(onBus: .zero,
                         bufferSize: 1024,
                         format: format) { [weak self] buffer, time in
            self?.applyDistortion(to: buffer, gain: 50, level: 0.2)
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
    
    func attachCppSigmoidDistortion() {
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

private extension MicrophoneModel {
    
    func applyDistortion(to buffer: AVAudioPCMBuffer, gain: Float, level: Float) {
        guard let floatChannelData = buffer.floatChannelData else { return }
        
        // ex ステレオオーディオ信号の場合、左と右の2つのチャンネル、左側と右側の音声情報を格納
        for channel in 0..<Int(buffer.format.channelCount) {
            let channelData = floatChannelData[channel]
            
            // サンプリングすることで得られた、フレームごとのサンプル値を、シグモイド関数で変化させる
            for frame in 0..<Int(buffer.frameLength) {
                let sample = channelData[frame]
                let distortedSample = sigmoidDistortion(sample: sample, gain: gain, level: level)
                channelData[frame] = distortedSample
            }
        }
    }

    func sigmoidDistortion(sample: Float, gain: Float, level: Float) -> Float {
        tanh(5 * sample * gain / 2) * level
    }
    
    func handleFirebase(with type: EffectType) {
        disconnect()
        
        switch type {
        case .disconnect: break
        case .clean: attachClean()
        case .reverb: attachReverb()
        case .avAudioEngine: attachDistotion()
        case .devoloopAudioKit: attachRhinoGuitarProcessor()
        case .devoloopAudioKitWithRev: attachRhinoGuitarProcessorWithReverb()
        case .cppSigmoid: attachCppSigmoidDistortion()
        }
    }
}

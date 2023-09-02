//
//  AudioSoundModel.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/07/09.
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import DevoloopAudioKit
import AVFoundation

final class AudioSoundModel: NSObject {
    
    // MARK: Property
    
    private var avAudioPlayer: AVAudioPlayer?
    private var audioPlayer: AudioPlayer?
    private var engine = AudioEngine()

    private var resourcePath: String? {
        Bundle.main.path(forResource: "12345", ofType: "wav")
    }
    private var resourceURL: URL? {
        Bundle.main.url(forResource: "12345", withExtension: "wav")
    }
    
    // MARK: Method

    // "12345.wav" をシミュレータで再生するテスト
    func playWav() {
        guard let path = resourcePath else { return }

        do {
            avAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            avAudioPlayer?.delegate = self
            avAudioPlayer?.play()
        } catch {
            print("Playback failed")
        }
    }
        
    // AudioKit で単音を再生するデモ
    func playOscillator() {
        let oscillator = Oscillator()
        engine.output = oscillator
        
        try? engine.start()
        oscillator.start()
        
        sleep(1)
        
        engine.stop()
        oscillator.stop()
    }
    
    // "12345.wav" を AudioKit でエフェクトするデモ
    func playWavWithAudioKit() {
        guard let path = resourceURL,
              let audioFile = try? AVAudioFile(forReading: path) else { return }

        audioPlayer = AudioPlayer(file: audioFile)
        guard let audioPlayer else { return }
        
        let node = RhinoGuitarProcessor(audioPlayer)
        let reverb = Reverb(node)
        let mixir = Mixer([reverb, node])

        engine.output = mixir

        try? engine.start()
        audioPlayer.play()
        
        sleep(5)

        engine.stop()
        audioPlayer.stop()
    }
    
    func disconnect() {
        engine.stop()
        engine = AudioEngine()

        avAudioPlayer?.stop()
        avAudioPlayer = nil

        audioPlayer?.stop()
        audioPlayer = nil
    }
}

extension AudioSoundModel: AVAudioPlayerDelegate {}

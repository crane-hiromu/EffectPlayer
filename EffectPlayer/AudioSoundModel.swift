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
    var avAudioPlayer: AVAudioPlayer?
    var audioPlayer: AudioPlayer?
    var engine = AudioEngine()
    
    func disconnect() {
        engine.stop()
        engine = AudioEngine()
        avAudioPlayer?.stop()
    }
    
    // シミュレータで音が鳴るテスト
    func tap_1() {
        debugPrint("----tap----", #function)
        guard let path = Bundle.main.path(forResource: "12345", ofType: "wav") else {
            debugPrint("---- fail to load wav ----")
            return
        }

        do {
            avAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            avAudioPlayer?.delegate = self
            avAudioPlayer?.play()
        } catch {
            print("Playback failed")
        }
    }
        
    // audiokit のデモ
    func tap_2() {
        debugPrint("----tap----", #function)

        let oscillator = Oscillator()
        engine.output = oscillator
        
        try? engine.start()
        oscillator.start()
        
        sleep(1)
        
        engine.stop()
        oscillator.stop()
    }
    
    // "12345.wav" をaudiokitで再生したい
    func tap_3() {
        debugPrint("----tap----", #function)
        
        guard
            let url = Bundle.main.url(forResource: "12345", withExtension: "wav"),
            let audioFile = try? AVAudioFile(forReading: url)
        else {
            debugPrint("---- fail to load wav ----")
            return
        }

        audioPlayer = AudioPlayer(file: audioFile)
        
        guard let audioPlayer else { return }
        
//        let node = DynaRageCompressor(audioPlayer)
        
        let node = RhinoGuitarProcessor(audioPlayer)
//        let reverb = Reverb(node)
//        let mixir = Mixer([reverb, node])

        engine.output = node // reverb // mixir // node

        try? engine.start()
        audioPlayer.play()
        
        sleep(5)

        engine.stop()
        audioPlayer.stop()
    }
}

extension AudioSoundModel: AVAudioPlayerDelegate {
    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        print("finish!")
//    }
}

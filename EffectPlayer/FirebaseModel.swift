//
//  FirebaseModel.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/09/02.
//

import Foundation
import Firebase
import Combine

/*
 呼び出し側に登録されたKey
 */
enum EffectType: String {
    case clean = "didTapClean"
    case disconnect = "didTapDisconnect"
    case avAudioEngine = "didTapDistOfAVAudioEngine"
    case devoloopAudioKit = "didTapDistOfDevoloopAudioKit"
    case cppSigmoid = "didTapDistOfCppSigmoid"
}

final class FirebaseModel {
    
    private lazy var reference: DatabaseReference = {
        Database.database().reference().ref.child("watch").child("action")
    }()
    private var handle: DatabaseHandle?
    var effectType = PassthroughSubject<EffectType?, Never>()
    
    func startMessageListener() {
        handle = reference.observe(.value, with: { [weak self] snapshot in
            let value = snapshot.value as? [String: String]
            let key = value?["type"] ?? ""
            debugPrint("receive: \(key)")

            self?.effectType.send(.init(rawValue: key))
        })
    }
    
    func stopMessageListener() {
        guard let handle else { return }
        reference.removeObserver(withHandle: handle)
    }
}

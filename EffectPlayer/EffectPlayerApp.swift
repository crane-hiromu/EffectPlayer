//
//  EffectPlayerApp.swift
//  EffectPlayer
//
//  Created by Tsuruta, Hiromu | Tsuru | ECID on 2023/06/12.
//

import SwiftUI
import Firebase

@main
struct EffectPlayerApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

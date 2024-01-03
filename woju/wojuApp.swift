//
//  wojuApp.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import SwiftUI

@main
@available(iOS 16.1, *)
struct wojuApp: App {
    init() {
//        AudioManager.shared.configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            RecordingView()
        }
    }
}

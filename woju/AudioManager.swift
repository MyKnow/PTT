//
//  AudioManager.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    private init() {}

    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])

            // 메인 스피커로 오디오 출력 설정
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try audioSession.setActive(true)

        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }
}

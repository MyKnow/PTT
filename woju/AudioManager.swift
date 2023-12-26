//
//  AudioManager.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import AVFoundation
import MediaPlayer

class AudioManager {
    static let shared = AudioManager()

    private init() {}

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .duckOthers, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            print("Error configuring audio session: \(error.localizedDescription)")
        }
    }

    func setMaxVolume() {
        MPVolumeView.setVolume(1.0)
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}

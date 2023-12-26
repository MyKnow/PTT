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
    private let volumeView: MPVolumeView
    
    private init() {
        // MPVolumeView 초기화
        self.volumeView = MPVolumeView()
    }

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
        MPVolumeView.setVolume(1.0, using: volumeView)
    }
    
    func setSoundVolume(_ volume: Int) {
        MPVolumeView.setVolume(normalizeVolume(volume), using: volumeView)
    }
    
    private func normalizeVolume(_ volume: Int) -> Float {
            let clampedVolume = max(0, min(100, volume)) // 0 이하는 0, 100 이상은 100으로 고정
            return Float(clampedVolume) / 100.0 // 정규화
    }
    
    func setSoundVolumeAccordingToFocusFilter() async {
        do {
            let currentFilter = try await SoundVolumeFocusFilter.current
            let volume = currentFilter.soundVolume

            // UI 업데이트는 메인 스레드에서 수행해야 함
            DispatchQueue.main.async {
                self.setSoundVolume(volume)
            }
        } catch {
            print("Error setting sound volume according to focus filter: \(error.localizedDescription)")
        }
    }

    func getCurrentVolume() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let currentVolume = AVAudioSession.sharedInstance().outputVolume
            print(currentVolume)
        } catch {
            print("Error getting current volume: \(error.localizedDescription)")
        }
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float, using volumeView: MPVolumeView) {
        DispatchQueue.main.async {
            let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
            slider?.value = volume
        }
    }
}

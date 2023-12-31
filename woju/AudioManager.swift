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
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioFileURL: URL?
    
    private init() {
        // MPVolumeView 초기화
        self.volumeView = MPVolumeView()
    }
    
    // 오디오 세션 설정
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers, .defaultToSpeaker, .allowAirPlay])
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
            
        } catch {
            print("오디오 세션 구성 오류: \(error.localizedDescription)")
        }
    }
    
    // 최대 볼륨 설정
    func setMaxVolume() {
        MPVolumeView.setVolume(1.0, using: volumeView)
    }
    
    // 볼륨 설정
    func setSoundVolume(_ volume: Int) {
        MPVolumeView.setVolume(normalizeVolume(volume), using: volumeView)
    }
    
    // 볼륨 정규화
    private func normalizeVolume(_ volume: Int) -> Float {
        let clampedVolume = max(0, min(100, volume)) // 0 이하는 0, 100 이상은 100으로 고정
        return Float(clampedVolume) / 100.0 // 정규화
    }
    
    // 포커스 필터에 따라 볼륨 설정
    func setSoundVolumeAccordingToFocusFilter() async {
        do {
            let currentFilter = try await SoundVolumeFocusFilter.current
            let volume = currentFilter.soundVolume
            
            // UI 업데이트는 메인 스레드에서 수행해야 함
            DispatchQueue.main.async {
                self.setSoundVolume(volume)
            }
        } catch {
            print("포커스 필터에 따라 볼륨 설정 오류: \(error.localizedDescription)")
        }
    }
    
    // 현재 볼륨 가져오기
    func getCurrentVolume() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            let currentVolume = AVAudioSession.sharedInstance().outputVolume
            print(currentVolume)
        } catch {
            print("현재 볼륨 가져오기 오류: \(error.localizedDescription)")
        }
    }
    
    // 녹음 시작
    func startRecording(to url: URL) {
        do {
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
        } catch {
            print("오디오 녹음 설정 오류: \(error.localizedDescription)")
        }
    }

    // 녹음 중지
    func stopRecording() {
        audioRecorder?.stop()
    }

    // 재생 시작
    func startPlayback(from url: URL) {
        do {
            print("audioPlayer URL : ", url)
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("오디오 재생 설정 오류: \(error.localizedDescription)")
        }
    }
}

// MPVolumeView 확장(extension)을 통해 볼륨 조절을 쉽게 수행할 수 있도록 함
extension MPVolumeView {
    static func setVolume(_ volume: Float, using volumeView: MPVolumeView) {
        DispatchQueue.main.async {
            let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
            slider?.value = volume
        }
    }
}

//
//  ContentView.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import AVFoundation
import SwiftUI

struct RecordingView: View {
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioFileURL: URL?
    @GestureState private var isDetectingContinuousPress = false

    var body: some View {
        VStack {
            Button {
                // 버튼이 눌렸을 때 수행할 작업
            } label: {
                Image(systemName: isDetectingContinuousPress ? "pause.fill" : "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: min(UIScreen.main.bounds.width / 3, UIScreen.main.bounds.height / 3))
                    .padding(50)
                    .background(Circle().foregroundColor(.blue))
                    .foregroundColor(.white)
            }.simultaneousGesture(continuousPress)
        }
        .onAppear {
            AudioManager.shared.configureAudioSession()

            A()

            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            audioFileURL = documentPath.appendingPathComponent("audioRecording.m4a")
        }
    }

    var continuousPress: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($isDetectingContinuousPress) { value, gestureState, _ in
                switch value {
                case .second(true, nil):
                    gestureState = true
                    print("updating: Second")
                    DispatchQueue.main.async {
                        HapticManager.shared.vibrate()
                        startRecording()
                    }
                default:
                    break
                }
            }.onEnded { value in
                switch value {
                case .second(_, _):
                    print("onended: Second")
                    DispatchQueue.main.async {
                        stopRecording()
                        startPlayback()
                    }
                default:
                    break
                }
            }
    }
    
    func A() {
        Task {
            await AudioManager.shared.setSoundVolumeAccordingToFocusFilter()
        }
    }


    func startRecording() {
        do {
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]

            AudioManager.shared.getCurrentVolume()
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.record()

        } catch {
            print("Error setting up audio recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }

    func startPlayback() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
            audioPlayer?.volume = 1.0 // Adjust volume from 0.0 to 1.0
            
            try AVAudioSession.sharedInstance().setMode(.default)

            audioPlayer?.prepareToPlay()
            audioPlayer?.play()

        } catch {
            print("Error setting up audio playback: \(error.localizedDescription)")
        }
    }
}

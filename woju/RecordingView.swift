//
//  ContentView.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import AVFoundation
import SwiftUI

struct RecordingView: View {
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioFileURL: URL?
    @GestureState private var isDetectingContinuousPress = false

    var body: some View {
        VStack {
            Image(systemName: isDetectingContinuousPress ? "globe" : "pause.fill")
            Button {
            } label: {
                Text("Recording")
            }.simultaneousGesture(continuousPress)
        }
        .onAppear {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)

                let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                audioFileURL = documentPath.appendingPathComponent("audioRecording.m4a")

            } catch {
                print("Error setting up audio session: \(error.localizedDescription)")
            }
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


    func startRecording() {
        do {
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: settings)
            audioRecorder?.record()
            isRecording = true

        } catch {
            print("Error setting up audio recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    func startPlayback() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
            audioPlayer?.volume = 1.0 // Adjust volume from 0.0 to 1.0
            audioPlayer?.play()

        } catch {
            print("Error setting up audio playback: \(error.localizedDescription)")
        }
    }
}

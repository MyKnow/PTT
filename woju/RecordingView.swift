//
//  ContentView.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import SwiftUI
import Foundation

struct RecordingView: View {
    // 연속적인 제스처 상태를 추적하기 위한 속성
    @GestureState private var isDetectingContinuousPress = false
    
    // WebSocketManager의 인스턴스를 저장하는 속성
    @State private var socket = WebSocketManager.shared

    var body: some View {
        VStack {
            // 녹음 및 재생을 수행하는 버튼
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

            // 서버에서 받은 오디오 파일을 재생하는 버튼
            Button {
                playtoServer()
            } label: {
                Image(systemName: "play.fill")
            }
        }
        .onAppear {
            // AudioManager 초기화 및 오디오 세션 설정
            AudioManager.shared.configureAudioSession()

        }
    }

    // 연속된 프레스를 감지하기 위한 제스처
    var continuousPress: some Gesture {
        LongPressGesture(minimumDuration: 0.1)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
            .updating($isDetectingContinuousPress) { value, state, _ in
                if case .second(true, nil) = value {
                    // 두 번째 단계: 연속된 프레스의 두 번째 단계
                    state = true
                    var audioFileURL: URL?
                    audioFileURL = FileManager.fileURLInDocumentDirectory(fileName: "audioRecording.m4a")
                    
                    // 추가: audioFileURL이 nil이 아닐 때만 녹음 시작
                   if let audioURL = audioFileURL {
                       print("Record : ", audioURL)
                       AudioManager.shared.startRecording(to: audioURL)
                   } else {
                       print("Error: audioFileURL is nil.")
                   }
                }
            }.onEnded { value in
                if case .second(_, _) = value {
                    var audioFileURL: URL?
                    audioFileURL = FileManager.fileURLInDocumentDirectory(fileName: "audioRecording.m4a")
                    // 연속된 프레스의 끝
                    if let url = audioFileURL {
                        print("play : ", url)
                        AudioManager.shared.stopRecording()
                        // AudioManager.shared.startPlayback(from: url)
                        socket.sendAudioFile(fileURL: url)
                    } else {
                        print("audioFileURL is nil")
                    }
                }
            }
    }

    // 서버에서 받은 오디오를 재생하는 함수
    func playtoServer() {
        var audioFileURL: URL?
        audioFileURL = FileManager.fileURLInDocumentDirectory(fileName: "audioRecording.m4a")
        if let url = audioFileURL {
            AudioManager.shared.startPlayback(from: url)
        } else {
            print("audioFileURL is nil")
        }
    }
}

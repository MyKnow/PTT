//
//  ContentView.swift
//  woju
//
//  Created by 정민호 on 12/26/23.
//

import SwiftUI
import Foundation
import ActivityKit

@available(iOS 16.1, *)
struct RecordingView: View {
    // 연속적인 제스처 상태를 추적하기 위한 속성
    @GestureState private var isDetectingContinuousPress = false
    @StateObject var viewModel = DIManager()
    
    // WebSocketManager의 인스턴스를 저장하는 속성
    @ObservedObject var socket = WebSocketManager.shared
    
    @Binding var goIndex:MainView.Tab

    var body: some View {
            // 녹음 및 재생을 수행하는 버튼
        VStack {
            HStack {
                Text(socket.nowSessionName ?? "세션 없음").padding(10)
            }
            Spacer()
            if socket.nowSessionID == nil {
                Image(systemName: "mic.slash.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: min(UIScreen.main.bounds.width / 2, UIScreen.main.bounds.height / 2))
                    .foregroundColor(.gray)
            } else {
                Button {} label: {
                    Image(systemName: isDetectingContinuousPress ? "mic.slash.circle.fill" : "mic.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: min(UIScreen.main.bounds.width / 2, UIScreen.main.bounds.height / 2))
                }.simultaneousGesture(continuousPress)
            }
            Spacer()
        }
        .onAppear {
            // AudioManager 초기화 및 오디오 세션 설정
            AudioManager.shared.configureAudioSession(isRecording: false)

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
                    AudioManager.shared.startRecording()
                }
            }.onEnded { value in
                if case .second(_, _) = value {
                    self.end()
                }
            }
    }
    
    func end() {
        var audioFileURL: URL?
        audioFileURL = FileManager.fileURLInDocumentDirectory(fileName: "audioRecording.m4a")
        // 연속된 프레스의 끝
        if let url = audioFileURL {
            print("play : ", url)
            AudioManager.shared.stopRecording()
            socket.sendAudioFile(fileURL: url)
        } else {
            print("audioFileURL is nil")
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

//#Preview {
//    if #available(iOS 16.1, *) {
////        RecordingView()
//    } else {
//        Text("Not Support iOS version")
//    }
//}

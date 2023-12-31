//
//  WebSocketManager.swift
//  woju
//
//  Created by 정민호 on 12/28/23.
//

import Foundation
import SocketIO

class WebSocketManager: NSObject {
    static let shared = WebSocketManager()

    let manager: SocketManager
    let socket: SocketIOClient

    private override init() {
        self.manager = SocketManager(socketURL: URL(string: "https://port-0-woju-nodejs-9zxht12blqmfgnv0.sel4.cloudtype.app/:3000")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket

        super.init()

        // Socket.IO 서버에 연결
        self.addHandlers()

        // 연결
        self.socket.connect()
    }

    func addHandlers() {
        // 서버로부터 응답을 받았을 때
        self.socket.on("receive-audio") { data, ack in
            if let audioData = data[0] as? [String: Any],
               let audioContentData = audioData["data"] as? Data {
                
                // 생성된 현재 시간을 이용하여 파일명 생성
                let fileName = "receivedAudioFile\(Date().timeIntervalSince1970).m4a"
                
                print("Received audio file: \(fileName)")
                
                // 저장된 파일의 URL을 얻어옴
                if let audioFileURL = FileManager.fileURLInDocumentDirectory(fileName: fileName) {
                    print("File URL: \(audioFileURL)")

                    // 파일 저장
                    do {
                        try audioContentData.write(to: audioFileURL)
                        print("Received audio file saved at: \(audioFileURL)")

                        // TODO: 이제 얻어온 audioFileURL을 사용하여 오디오를 재생하거나 추가 작업 수행
                        AudioManager.shared.startPlayback(from: audioFileURL)
                    } catch {
                        print("Error saving audio file: \(error.localizedDescription)")
                    }
                } else {
                    print("Error getting file URL.")
                }
            } else {
                print("Error getting audio content data.")
            }
        }
    }

    func sendData(data: Data) {
        // 클라이언트에서 음성 파일을 서버로 전송
        self.socket.emit("send-audio", data)
    }

    // 새로운 함수 추가: 클라이언트에서 파일을 전송하는 코드
    func sendAudioFile(fileURL: URL) {
        do {
            let audioData = try Data(contentsOf: fileURL)
            self.sendData(data: audioData)
        } catch {
            print("Error converting file to data: \(error.localizedDescription)")
        }
    }
}

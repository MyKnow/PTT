//
//  WebSocketManager.swift
//  woju
//
//  Created by 정민호 on 12/28/23.
//

import Foundation
import SocketIO
import ActivityKit

class WebSocketManager: NSObject, ObservableObject {
    static let shared = WebSocketManager()
    
    let manager: SocketManager
    var socket: SocketIOClient
    @Published var nowSessionID: String?
    @Published var nowSessionName: String?
    @Published var myName: String?
    
    private override init() {
        //        self.manager = SocketManager(socketURL: URL(string: "https://port-0-woju-nodejs-9zxht12blqmfgnv0.sel4.cloudtype.app/:3000")!, config: [.log(true), .compress])
                self.manager = SocketManager(socketURL: URL(string: "http://192.168.1.214:3000")!, config: [.log(true), .compress])
//        self.manager = SocketManager(socketURL: URL(string: "http://127.0.0.1:3000")!, config: [.log(true), .compress])
        self.socket = self.manager.defaultSocket
        
        super.init()
        
        // Socket.IO 서버에 연결
        self.addHandlers()
        
        // 연결
        self.socket.connect()
        
        login()
    }
    
    func login() {
        let userName = FileManager.loadDataFromDocumentDirectory("myName.text", as: String.self) ?? "ERROR"
        print(userName)
        
        self.socket.emit("login", userName)
    }
    
    // 외부에서 채널 ID를 설정하는 함수
    func setSession(_ sessionID: String, _ sessionName: String) async -> String {
        // continuation을 클로저 외부에서 선언
        var continuation: CheckedContinuation<String, Never>?
        
        leaveNowSession()
        
        // withCheckedContinuation 내부에서 continuation에 값을 할당
        return await withCheckedContinuation { cont in
            continuation = cont
            self.socket.emit("join", sessionID)
            
            // join-success 이벤트 처리
            self.socket.once("join-success") { data, _ in
                print("JOIN!!!!!!!")
                self.nowSessionID = sessionID
                self.nowSessionName = sessionName
                // join 요청을 서버에 보냄
                continuation?.resume(returning: "JOIN")
                continuation = nil
            }
            
            // room-full 이벤트 처리
            self.socket.once("room-full") { data, _ in
                print("Failed!!!!!!!")
                // join 실패 시 여기에 처리 로직을 추가할 수 있습니다.
                continuation?.resume(returning: "FAIL")
                continuation = nil
            }
        }
    }
    
    func leaveNowSession() {
        self.leaveSession(self.nowSessionID)
        self.nowSessionID = nil
        self.nowSessionName = nil
    }
    
    func leaveSession(_ sessionID: String?) {
        if sessionID != nil {
            self.socket.emit("leave", sessionID ?? "MAIN")
        }
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
        self.myName = FileManager.loadDataFromDocumentDirectory("myName.txt", as: String.self) ?? "ANONYMOUS"
        // Data를 JSON 형식으로 변환
        let json = ["audio" : data, "roomName" : self.nowSessionID ?? "MAIN", "myName" : self.myName ?? "ANONYMOUS"] as [String : Any]
        
        // 서버로 JSON 데이터 전송
        self.socket.emit("send-audio", json)
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

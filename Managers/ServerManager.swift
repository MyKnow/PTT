//
//  ServerManager.swift
//  woju
//
//  Created by 정민호 on 12/27/23.
//

import Foundation

class ServerManager {
    // 파일을 서버에 업로드하는 함수
    static func uploadFile(fileURL: URL, completion: @escaping (Error?) -> Void) {
        // 서버 업로드 URL
        let serverURL = URL(string: "https://port-0-woju-nodejs-9zxht12blqmfgnv0.sel4.cloudtype.app/upload")!
        
        // 업로드할 파일의 로컬 URL
        let fileURL = fileURL
        
        // URLRequest 초기화
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        // 멀티파트 형식의 Content-Type 설정
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // 파일 데이터 추가
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(try! Data(contentsOf: fileURL))
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // 업로드를 위한 URLSession 작업
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("파일 업로드 오류:", error)
            } else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("파일 업로드 성공! 상태 코드: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
    }

    // 서버에서 파일을 다운로드하는 함수
    static func downloadFile(filename: String, completion: @escaping (URL?, Error?) -> Void) {
        // 서버 다운로드 URL
        let serverURL = URL(string: "https://port-0-woju-nodejs-9zxht12blqmfgnv0.sel4.cloudtype.app/download/\(filename)")!

        // URLSession을 사용하여 파일 다운로드
        URLSession.shared.downloadTask(with: serverURL) { localURL, response, error in
            guard let localURL = localURL else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            // 다운로드한 파일을 저장할 로컬 URL
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(filename)

            // 다운로드한 파일을 원하는 위치로 이동
            do {
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                DispatchQueue.main.async {
                    completion(destinationURL, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}

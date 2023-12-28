//
//  ServerManager.swift
//  woju
//
//  Created by 정민호 on 12/27/23.
//

import Foundation

class FileTransferManager {
    static func uploadFile(fileURL: URL, completion: @escaping (Error?) -> Void) {
        let serverURL = URL(string: "https://port-0-woju-server-9zxht12blqmfgnv0.sel4.cloudtype.app/upload")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"

        URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            DispatchQueue.main.async {
                completion(error)
            }
        }.resume()
    }

    static func downloadFile(filename: String, completion: @escaping (URL?, Error?) -> Void) {
        let serverURL = URL(string: "https://port-0-woju-server-9zxht12blqmfgnv0.sel4.cloudtype.app/download/\(filename)")!

        URLSession.shared.downloadTask(with: serverURL) { localURL, response, error in
            guard let localURL = localURL else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(filename)

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

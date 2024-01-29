//
//  FileManager.swift
//  woju
//
//  Created by 정민호 on 12/31/23.
//

import Foundation

extension FileManager {
    static func fileURLInDocumentDirectory(fileName: String) -> URL? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent(fileName)
    }

    static func saveDataToDocumentDirectory<T: Encodable>(_ data: T, fileName: String) {
        if let fileURL = fileURLInDocumentDirectory(fileName: fileName) {
            let encoder = JSONEncoder()

            do {
                let encodedData = try encoder.encode(data)
                try encodedData.write(to: fileURL, options: .atomicWrite)
            } catch {
                print("Error saving data to \(fileName): \(error.localizedDescription)")
            }
        }
    }

    static func loadDataFromDocumentDirectory<T: Decodable>(_ fileName: String, as type: T.Type) -> T? {
        if let fileURL = fileURLInDocumentDirectory(fileName: fileName) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(type, from: data)
                return decodedData
            } catch {
                print("Error loading data from \(fileName): \(error.localizedDescription)")
                return nil
            }
        } else {
            print("Error loading data (fileURL is nil)")
            return nil
        }
    }

    static func removeFileFromDocumentDirectory(_ fileName: String) {
        if let fileURL = fileURLInDocumentDirectory(fileName: fileName){
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error removing file \(fileName): \(error.localizedDescription)")
            }
        }
    }
    
    
}

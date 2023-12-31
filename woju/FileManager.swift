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
}

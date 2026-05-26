//
//  StorageFactory.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

enum StorageFactory {
    static func fileStorage(
        fileURL: URL,
        maxFileSizeInMB: Int
    ) throws -> DataStorable {
        let maxFileSize = ByteSize.mb(maxFileSizeInMB)
        return try FileStorage(fileURL: fileURL, maxFileSize: maxFileSize)
    }
}

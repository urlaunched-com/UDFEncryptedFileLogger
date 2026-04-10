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
    let maxFileSize = Int(maxFileSizeInMB) * 1024 * 1024
    try FileManager.createFileIfNeeded(at: fileURL)
    
    return try FileStorage(fileURL: fileURL, maxFileSize: maxFileSize)
  }
}

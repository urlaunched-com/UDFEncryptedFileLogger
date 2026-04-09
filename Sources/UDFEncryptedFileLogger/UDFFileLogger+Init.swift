//
//  UDFFileLogger+Init.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import UDF
import Foundation

public extension ActionLogger where Self == UDFFileLogger {
  static var empty: UDFFileLogger {
    UDFFileLogger()
  }
  
  static func fileLogger(
    fileURL: URL,
    maxFileSizeInMB: UInt,
    encryptionMethod: EncryptionMethod = .plaintext,
    extraFilters: [ActionFilter] = []
  ) -> ActionLogger? {
    let maxFileSize = UInt64(maxFileSizeInMB) * 1024 * 1024
    do {
      let processor = try StreamProcessorFactory.processor(for: encryptionMethod, fileURL: fileURL)
      let secureFileLogger = try SecureFileLogger(
        fileURL: fileURL,
        maxFileSize: maxFileSize,
        processor: processor
      )
      
      return try? UDFFileLogger(
        fileLogger: secureFileLogger,
        filters: [.debugOnly] + extraFilters
      )
    } catch {
      return nil
    }
  }
  
  static func fileLoggerOrEmpty(
    fileURL: URL,
    maxFileSizeInMB: UInt,
    encryptionMethod: EncryptionMethod = .plaintext,
    extraFilters: [ActionFilter] = [],
  ) -> ActionLogger {
    .fileLogger(
      fileURL: fileURL,
      maxFileSizeInMB: maxFileSizeInMB,
      encryptionMethod: encryptionMethod,
      extraFilters: extraFilters
    ) ?? .empty
  }
}

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
    maxFileSizeInMB: Int,
    encryptionMethod: EncryptionMethod = .plaintext,
    extraFilters: [ActionFilter] = []
  ) -> ActionLogger? {
    do {
      try FileManager.createFileIfNeeded(at: fileURL, permission: 0o600)
      let storage = try StorageFactory.fileStorage(fileURL: fileURL, maxFileSizeInMB: maxFileSizeInMB)
      let chiper = try ChiperFactory.chiper(for: encryptionMethod, fileURL: fileURL)
      let logger = try UDFFileLogger(
        intervalToSync: 1,
        logger: SecureLogger(cipher: chiper, storage: storage),
        filters: [.default] + extraFilters
      )
      return logger
    } catch {
      print("[UDFFileLogger] Failed to initialize logger: \(error.localizedDescription)")
      return nil
    }
  }
  
  static func fileLoggerOrEmpty(
    fileURL: URL,
    maxFileSizeInMB: Int,
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

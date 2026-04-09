//
//  LoggerRegistry.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation
import CryptoSwift

enum StreamProcessorFactory {
  static func processor(
    for method: EncryptionMethod,
    fileURL: URL? = nil,
    key: String? = nil
  ) throws -> StreamCipherable {
    switch method {
      case .plaintext:
        return AESCipher.PassthroughStreamProcessor()
      case let .aesCBC(key):
        guard let fileURL else {
          throw UDFFileLoggerError.missingParameters
        }
        
        let ivData = try? FileManager.default.read(at: fileURL, upToCount: AES.blockSize)
        if ivData == nil {
          try AESCipher.CBCStreamProcessor.initialize(fileURL: fileURL)
        }
        guard let ivData = try? FileManager.default.read(at: fileURL, upToCount: AES.blockSize) else {
          throw UDFFileLoggerError.readFailed(at: fileURL)
        }
        
        return try AESCipher.CBCStreamProcessor(password: key, iv: ivData.toHexString())
    }
  }
  
}

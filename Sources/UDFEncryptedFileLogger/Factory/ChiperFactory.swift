//
//  ChiperFactory.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

enum ChiperFactory {
  static func chiper(
    for method: EncryptionMethod,
    writeMode: WriteMode,
    fileURL: URL? = nil,
    key: String? = nil
  ) throws -> StreamCipherable {
    switch method {
      case .plaintext:
        return AESCipher.PassthroughStreamProcessor()
      case let .aesCBC(key):
        guard let fileURL else {
          throw ChiperError.missingParameters
        }
        let scaleBlock = writeMode == .hex ? 2 : 1
        let blockSize = scaleBlock * AESCipher.Credentials.blockSize
        var ivData = try? FileManager.default.read(at: fileURL, upToCount: blockSize)
        if ivData == nil {
          ivData = try writeMode.encode(Data(AESCipher.Credentials.randomIV(AESCipher.Credentials.blockSize)))
        }
      
        guard let ivData else {
          throw CredentialsError.initializationIVFailed
        }
      
        let credentials = try AESCipher.Credentials(key, iv: ivData.byteArray)
        if try FileManager.default.isFileEmpty(fileURL) {
          try ivData.write(to: fileURL)
        }
      
        return try AESCipher.CBCStreamProcessor(credentials: credentials)
    }
  }
}

//
//  ChiperFactory.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation
import CryptoSwift

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
      
        let blockSize = (writeMode == .hex ? 2 : 1) * AES.blockSize
        var ivDataHex = try? FileManager.default.read(at: fileURL, upToCount: blockSize)
        if ivDataHex == nil {
          ivDataHex = try writeMode.encode(Data(AES.randomIV(AES.blockSize)))
        }
      
        guard let ivDataHex, let ivDataHexText = String(data: ivDataHex, encoding: .utf8) else {
          throw CredentialsError.initializationIVFailed
        }
      
        let ivData = Data(hex: ivDataHexText)
        let credentials = try AESCipher.Credentials(key, iv: ivData.byteArray)
        if try FileManager.default.isFileEmpty(fileURL) {
          try ivDataHex.write(to: fileURL)
        }
      
        return try AESCipher.CBCStreamProcessor(credentials: credentials)
    }
  }
}

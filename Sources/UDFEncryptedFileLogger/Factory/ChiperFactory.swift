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
        let credentials = try AESCipher.Credentials(key: key, fileURL: fileURL)
        return try AESCipher.CBCStreamProcessor(credentials: credentials)
    }
  }
}

//
//  Key.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import Foundation
import CommonCrypto

extension AESCipher {
  struct Credentials: KeyValidatable {
    let key: Array<UInt8>
    var iv: Array<UInt8>
    
    init(base64Key value: String, iv: [UInt8] = Self.randomIV()) throws {
      
      try Self.validate(value)
      try Self.validateIV(iv)
      
      let key = Data(base64Encoded: value)?.byteArray ?? []
      self.key = key
      self.iv = iv
    }
    
    // MARK: - KeyValidatable
    static func validate(_ key: String) throws {
      guard let keyData = Data(base64Encoded: key) else {
        throw CredentialsError.decodingBase64Failed
      }
      
      if keyData.count != AESCipher.Config.keySize {
        throw CredentialsError.invalidKeySize
      }
    }
    
    static func randomIV(_ count: Int = AESCipher.Config.blockSize) -> Array<UInt8> {
      (0..<count).map({ _ in UInt8.random(in: 0...UInt8.max) })
    }
  }
}

// MARK: - Private
private extension AESCipher.Credentials {
  static func validateIV(_ iv: [UInt8]) throws {
    if iv.count != AESCipher.Config.blockSize {
      throw CredentialsError.invalidIVSize
    }
  }
}

extension AESCipher {
  enum Config {
    static let blockSize = 16
    static let keySize = kCCKeySizeAES256
  }
}

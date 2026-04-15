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
    static let blockSize = 16
    static let keySize = kCCKeySizeAES256
    
    init(_ value: String, iv: [UInt8] = Self.randomIV()) throws {
      try Self.validate(value)
      try Self.validateIV(iv)
      
      self.key = value.bytes
      self.iv = iv
    }
    
    // MARK: - KeyValidatable
    static func validate(_ key: String) throws {
      if key.bytes.count != keySize {
        throw CredentialsError.invalidKeySize
      }
    }
    
    static func randomIV(_ count: Int = Self.blockSize) -> Array<UInt8> {
      (0..<count).map({ _ in UInt8.random(in: 0...UInt8.max) })
    }
  }
}

// MARK: - Private
private extension AESCipher.Credentials {
  static func validateIV(_ iv: [UInt8]) throws {
    if iv.count != Self.blockSize {
      throw CredentialsError.invalidIVSize
    }
  }
}

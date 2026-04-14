//
//  Key.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import CryptoSwift
import Foundation

extension AESCipher {
  struct Credentials: KeyValidatable {
    let key: Array<UInt8>
    let iv: Array<UInt8>
    static let keySize = AES.blockSize
    
    init(_ value: String, iv: [UInt8] = AES.randomIV(AES.blockSize)) throws {
      try Self.validate(value)
      try Self.validateIV(iv)
      
      self.key = value.bytes
      self.iv = iv
    }
    
    // MARK: - KeyValidatable
    static func validate(_ key: String) throws {
      if key.bytes.count != Self.keySize {
        throw CredentialsError.invalidKeySize
      }
    }
  }
}

// MARK: - Private
private extension AESCipher.Credentials {
  static func validateIV(_ iv: [UInt8]) throws {
    if iv.count != Self.keySize {
      throw CredentialsError.invalidIVSize
    }
  }
}

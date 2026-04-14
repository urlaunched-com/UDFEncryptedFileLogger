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
    
    init(_ value: String, iv: [UInt8]) throws {
      try Self.validate(value)
      try Self.validateIV(iv)
      
      self.key = value.bytes
      self.iv = iv
    }
    
    init(key: String, fileURL: URL) throws {
      let ivData = try? FileManager.default.read(at: fileURL, upToCount: Self.keySize)
      if ivData == nil {
        try Self.initializeIV(fileURL: fileURL)
      }
      guard let ivData = try? FileManager.default.read(at: fileURL, upToCount: Self.keySize) else {
        throw CredentialsError.initializationFailed
      }
      
      try self.init(key, iv: ivData.byteArray)
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
  
  // MARK: - Initialization
  static func initializeIV(fileURL: URL) throws {
    let ivData = Data(AES.randomIV(Self.keySize))
    do {
      try ivData.write(to: fileURL)
    } catch {
      throw CredentialsError.initializationFailed
    }
  }
}

//
//  CBCStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import CryptoSwift
import Foundation

extension AESCipher {
  class CBCStreamProcessor: StreamCipherable {
    private var aes: AES
    private var enryptor: Cryptor & Updatable
    private var decryptor: Cryptor & Updatable
    
    var blockSize: UInt64 {
      UInt64(AES.blockSize)
    }
    
    init(
      password: String,
      iv: String = AES.randomIV(16).toHexString()
    ) throws {
      self.aes = try AES(
        key: password.bytes,
        blockMode: CBC(iv: iv.bytes),
        padding: .zeroPadding
      )
      self.enryptor = try aes.makeEncryptor()
      self.decryptor = try aes.makeDecryptor()
    }
    
    func encode(data: Data) throws -> Data {
      let encodedData = try self.enryptor.update(withBytes: data.byteArray)
      return Data(encodedData)
    }
    
    func finish() throws -> Data {
      Data(try self.enryptor.finish())
    }
    
    func decode(data: Data) throws -> Data {
      let decodedData = try self.decryptor.update(withBytes: data.byteArray)
      return Data(decodedData)
    }
  }
}

// MARK: - Static methods
extension AESCipher.CBCStreamProcessor {
  static func initialize(fileURL: URL) throws {
    let ivData = Data(AES.randomIV(AES.blockSize))
    do {
      try FileManager.createFileIfNeeded(at: fileURL)
      try ivData.write(to: fileURL)
    } catch {
      throw UDFFileLoggerError.creatingFileFailed(at: fileURL)
    }
  }
}

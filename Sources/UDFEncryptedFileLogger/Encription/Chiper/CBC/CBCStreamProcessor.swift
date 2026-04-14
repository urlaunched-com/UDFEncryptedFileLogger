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
    
    var blockSize: Int {
      AES.blockSize
    }
    
    init(credentials: Credentials) throws {
      self.aes = try AES(
        key: credentials.key,
        blockMode: CBC(iv: credentials.iv),
        padding: .zeroPadding
      )
      
      self.enryptor = try aes.makeEncryptor()
      self.decryptor = try aes.makeDecryptor()
    }
    
    func encode(data: Data) throws -> Data {
      let encodedData = try self.enryptor.update(withBytes: data.byteArray)
      return Data(encodedData)
    }
    
    func decode(data: Data) throws -> Data {
      let decodedData = try self.decryptor.update(withBytes: data.byteArray)
      return Data(decodedData)
    }
    
    func finish() throws -> Data {
      Data(try self.enryptor.finish())
    }
  }
}

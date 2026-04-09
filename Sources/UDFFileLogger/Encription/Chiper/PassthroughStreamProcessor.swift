//
//  PassthroughStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import CryptoSwift
import Foundation

extension AESCipher {
  class PassthroughStreamProcessor: StreamCipherable {

    var blockSize: UInt64 {
      return 1
    }
    
    func finish() throws -> Data {
      return Data()
    }
    
    func encode(data: Data) throws -> Data {
      return data
    }
    
    func decode(data: Data) throws -> Data {
      return data
    }
  }
}

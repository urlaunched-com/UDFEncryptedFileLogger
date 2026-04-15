//
//  PassthroughStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

extension AESCipher {
  class PassthroughStreamProcessor: StreamCipherable {
    var blockSize: Int {
      return 1
    }
    
    func encode(data: Data) throws -> Data {
      return data
    }
    
    func finish() throws -> Data {
      return Data()
    }
    
    static func decode(data: Data, key: Array<UInt8>, iv: Array<UInt8>) throws -> Data {
      data
    }
  }
}

//
//  Data+.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 15.04.2026.
//
import Foundation

extension Data {
  var byteArray: Array<UInt8> {
    Array(self)
  }
  
  func toHexString() -> String {
    self.reduce(into: "") { result, byte in
      result.append(String(format: "%02x", byte))
    }
  }
}

//
//  Strings+.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 15.04.2026.
//

import Foundation

extension String {
  
  var bytes: Array<UInt8> {
    data(using: String.Encoding.utf8, allowLossyConversion: true)?.byteArray ?? Array(utf8)
  }
  
  func toHexString() -> String {
    self.utf8.map { String(format: "%02x", $0) }.joined()
  }
}

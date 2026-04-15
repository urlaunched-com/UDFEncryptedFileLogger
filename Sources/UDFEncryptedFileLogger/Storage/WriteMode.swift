//
//  WriteMode.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import Foundation

enum WriteMode {
  case hex
  case bin
  
  func encode(_ data: Data) throws -> Data {
    switch self {
    case .hex:
      guard let encodedData = data.toHexString().data(using: .utf8) else {
        throw StorageError.utf8EncodingFailed
      }
      return encodedData
    case .bin:
      return data
    }
  }
}

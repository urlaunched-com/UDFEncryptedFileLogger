//
//  AES.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import Foundation

// MARK: - Name spacing
enum AESCipher {}

protocol StreamCipherable {
  var blockSize: Int { get }
  func encode(data: Data) throws -> Data
  func finish() throws -> Data
  
  static func decode(data: Data, key: Array<UInt8>, iv: Array<UInt8>) throws -> Data
}

protocol KeyValidatable {
    static func validate(_ key: String) throws
}

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
  func encrypt(data: Data) throws -> Data
  func finish() throws -> Data
}

protocol Decryptable {
  static func decrypt(data: Data, key: Array<UInt8>, iv: Array<UInt8>) throws -> Data
}

protocol KeyValidatable {
    static func validate(base64Key: String) throws -> Data
}

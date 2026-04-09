//
//  AES.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import CryptoSwift
import Foundation

// MARK: - Name spacing
enum AESCipher {}

protocol StreamCipherable {
  var blockSize: UInt64 { get }
  func encode(data: Data) throws -> Data
  func decode(data: Data) throws -> Data
  func finish() throws -> Data
}

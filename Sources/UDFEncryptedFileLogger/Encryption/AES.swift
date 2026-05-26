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

protocol Decryptable: Sendable {
    func decrypt(data: Data) throws -> Data
}

protocol Encryptable: Sendable {
    func encrypt(data: Data) throws -> Data
}

protocol KeyValidatable {
    static func validate(base64Key: String) throws -> Data
    static func validate(key: [UInt8]) throws
}

typealias Cryptable = Decryptable & Encryptable

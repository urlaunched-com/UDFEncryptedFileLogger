//
//  DataClosable.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

protocol DataCloseable: Sendable {
    mutating func close() throws
}

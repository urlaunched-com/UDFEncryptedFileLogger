//
//  DataWritable.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

protocol DataWritable: Sendable {
    mutating func append(data: Data) throws
    mutating func rewrite(data: Data) throws
}

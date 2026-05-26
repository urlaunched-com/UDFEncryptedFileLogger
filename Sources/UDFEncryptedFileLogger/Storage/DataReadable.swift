//
//  DataReadable.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 23.05.2026.
//

import Foundation

protocol DataReadable {
    func read() throws -> Data
}

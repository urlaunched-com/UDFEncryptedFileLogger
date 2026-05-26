//
//  ByteSize.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 16.04.2026.
//

import Foundation

enum ByteSize {
    static func kb(_ value: Int) -> Int {
        value * 1024
    }

    static func mb(_ value: Int) -> Int {
        kb(value) * 1024
    }
}

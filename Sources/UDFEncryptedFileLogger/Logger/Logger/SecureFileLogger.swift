//
//  SecureFileLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

struct SecureLogger: Loggable {
    let cipher: StreamCipherable
    var storage: DataStorable
    let releaseFileRatio: Double

    init(
        cipher: StreamCipherable,
        storage: DataStorable,
        releaseFileRatio: Double = 0.4
    ) {
        self.cipher = cipher
        self.storage = storage
        self.releaseFileRatio = min(1, max(0, releaseFileRatio))
    }

    mutating func log(data: Data) throws {
        var encryptedData = try cipher.encrypt(data: data)
        try encryptedData.append(cipher.finish())

        do {
            try storage.append(data: encryptedData)
        } catch StorageError.sizeOverflow {
            var releaseByteSize = Int(Double(storage.size) * releaseFileRatio)
            releaseByteSize -= releaseByteSize % cipher.blockSize

            try storage.reduce(size: releaseByteSize)
            try storage.append(data: encryptedData)
        }
    }
}

//
//  MemoryStorage.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

/// Usage for testing purpose
final class MemoryStorage: DataStorable, @unchecked Sendable {
    private(set) var collectedData: Data
    let maxSize: Int?

    init(data: Data = Data(), maxSize: Int? = nil) {
        self.maxSize = maxSize
        if let maxSize {
            self.collectedData = data.prefix(maxSize)
        } else {
            self.collectedData = data
        }
    }

    var size: Int {
        collectedData.count
    }
}

// MARK: - DataStorable
extension MemoryStorage: DataWritable {
    func append(data: Data) throws {
        if let maxSize, size + data.count > maxSize {
            throw StorageError.sizeOverflow
        }

        collectedData.append(data)
    }

    func rewrite(data: Data) throws {
        collectedData = data
    }
}

// MARK: - DataCloseable
extension MemoryStorage: DataCloseable {
    func close() throws {
        collectedData = Data()
    }
}

// MARK: - DataCompactor
extension MemoryStorage: DataCompactor {
    func reduce(size releaseByteSize: Int) throws {
        guard releaseByteSize >= 0 else {
            throw StorageError.invalidSizeParameter
        }
        guard !collectedData.isEmpty else {
            return
        }

        let startPosition = max(0, min(releaseByteSize, collectedData.count - 1))
        let newData = collectedData.subdata(in: startPosition ..< collectedData.count)
        try rewrite(data: newData)
    }
}

// MARK: - DataReadable
extension MemoryStorage: DataReadable {
    func read() throws -> Data {
        collectedData
    }
}

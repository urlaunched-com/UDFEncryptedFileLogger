//
//  DataStorageTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation
import Testing
@testable import UDFEncryptedFileLogger

struct DataStorageTests {
    var dataStorage: MemoryStorage
    let maxSize = 128

    init() {
        dataStorage = MemoryStorage(maxSize: maxSize)
    }

    @Test("Data storage throws data size overflow")
    mutating func dataStorageOverflow() throws {
        let data = Data(repeating: 0x00, count: dataStorage.maxSize + 1)

        #expect(
            throws: StorageError.sizeOverflow,
            "storage should throw error about data size overflow"
        ) {
            try dataStorage.append(data: data)
        }
    }

    @Test("Data storage collect new data")
    mutating func collectDataInStorage() throws {
        let data = Data(repeating: 0x00, count: maxSize / 2)

        try dataStorage.append(data: data)

        #expect(dataStorage.collectedData == data, "data should be saved inside the storage")
    }

    @Test("Data storage throws size overflow error and handles it correctly")
    mutating func handleDataSizeOverflowInStorage() throws {
        dataStorage = MemoryStorage(
            maxSize: maxSize,
            data: Data(repeating: 0x00, count: maxSize)
        )

        let data = Data(repeating: 0x11, count: maxSize / 2)
        var expectedCollectedData = Data(repeating: 0x00, count: dataStorage.maxSize / 2)
        expectedCollectedData.append(data)

        do {
            try dataStorage.append(data: data)
        } catch StorageError.sizeOverflow {
            try dataStorage.reduce(size: maxSize / 2)
            try dataStorage.append(data: data)
        }
        #expect(
            dataStorage.collectedData == expectedCollectedData,
            "data storage should contain consistent data"
        )
        #expect(dataStorage.size == expectedCollectedData.count, "data storage should contains correct size in bytes")
    }

    @Test("Reduce storage with incorrect parameters")
    mutating func failToReduceStorage() {
        #expect(
            throws: StorageError.invalidSizeParameter,
            "storage should throw error about invalid reduce size parameter"
        ) {
            try dataStorage.reduce(size: -1)
        }
    }
}

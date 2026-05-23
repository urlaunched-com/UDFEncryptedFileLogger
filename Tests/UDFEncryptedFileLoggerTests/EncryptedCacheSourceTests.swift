//
//  EncryptedCacheSourceTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 23.05.2026.
//

import Foundation
import Testing
@testable import UDFEncryptedFileLogger

struct EncryptedCacheSourceTests {
    var cacheSource: EncryptedCacheSource

    init() throws {
        let key = "qeQ2xcG1ICJN4tBemRT6zdb4zQ/W6g8vvw4FycRx3Lw="
        let iv = "abcdef9876543210"

        let credentials = try AESCipher.Credentials(base64Key: key, iv: iv.bytes)
        let cryptor = AESCipher.AESCryptor(credentials: credentials, padding: .zero)

        cacheSource = EncryptedCacheSource(
            key: "secure_data",
            cryptor: cryptor,
            dataStorable: MemoryStorage()
        )
    }

    @Test("Store/Load strings", arguments: ["4440 1234 6732 1345", "07/09/2000", "$1200"])
    func storeLoadEncryptedStringValues(value: String) async throws {
        try await assertStoreLoad(value: value)
    }

    @Test("Store/Load numbers", arguments: [100, 1999, 2000])
    func storeLoadEncryptedIntValues(value: Int) async throws {
        try await assertStoreLoad(value: value)
    }

    @Test("Store/Load arrays", arguments: [
        [1, 2, 3, 5, 6],
        Array(repeating: 0, count: 100),
        [1999, 2000, 2001, 2002, 2003, 2004, 2005],
    ])
    func storeLoadEncryptedArrayValues(value: [Int]) async throws {
        try await assertStoreLoad(value: value)
    }

    @Test("Store/Load Bool values", arguments: [true, false])
    func storeLoadBoolValues(value: Bool) async throws {
        try await assertStoreLoad(value: value)
    }

    @Test("Store/Load custom Codable struct")
    func storeLoadCodableStruct() async throws {
        struct Card: Codable, Equatable, Sendable {
            let number: String
            let expiry: String
            let balance: Double
        }

        try await assertStoreLoad(value: Card(
            number: "4440 1234 6732 1345",
            expiry: "07/09/2030",
            balance: 1200.00
        ))
    }
}

// MARK: - Helpers
private extension EncryptedCacheSourceTests {
    func assertStoreLoad<T: Codable & Equatable & Sendable>(value: T) async throws {
        cacheSource.save(value)
        try await Task.sleep(for: .milliseconds(100))
        let loaded: T? = cacheSource.load()
        #expect(loaded == value)
    }
}

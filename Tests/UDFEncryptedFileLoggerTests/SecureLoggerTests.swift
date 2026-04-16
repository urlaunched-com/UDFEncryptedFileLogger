//
//  SecureLoggerTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Foundation
import Testing
@testable import UDFEncryptedFileLogger

struct SecureLoggerTests {
    let maxSize = 256
    let base64Key: String
    var defaultStorage: MemoryStorage
    var initialCredentials: AESCipher.Credentials

    init() throws {
        let key = "WaWUTDr9ykQBdOJqJkhYSiSAQnVtYvYyqsVSwqqGbww="
        let iv = AESCipher.Credentials.randomIV()

        self.base64Key = key
        self.initialCredentials = try AESCipher.Credentials(base64Key: key, iv: iv)
        self.defaultStorage = MemoryStorage(maxSize: maxSize)
    }

    @Test("Log data to initial/empty storage")
    func logDataToInitializedStorage() throws {
        let cipher = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var logger = SecureLogger(cipher: cipher, storage: defaultStorage)

        let logs = [
            "Test Suite 'All tests' started at 2026-04-15 18:54:16.550.",
            "Test Suite 'Selected tests'",
            "Test Suite 'UDFFileLoggerTests.xctest'",
        ]
        let expectedResult = logs.joined()
        for log in logs {
            guard let logData = log.data(using: .utf8) else {
                continue
            }
            try logger.log(data: logData)
        }

        let encryptedData = defaultStorage.collectedData
        let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(
            data: encryptedData,
            key: initialCredentials.key,
            iv: initialCredentials.iv
        )

        let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()

        #expect(decryptedText == expectedResult, "decryptedData should match origin data")
    }

    @Test("Ensure logger correctly handles data exceeding maximum storage capacity")
    func storageOverflowBehavior() throws {
        let cipher = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var logger = SecureLogger(cipher: cipher, storage: defaultStorage, releaseFileRatio: 0.4)
        let logs = [
            "Test Suite 'Selected tests'",
            "Test Suite 'UDFFileLoggerTests.xctest'",
            "Suite AESEncriptionTests started",
            "Target Platform: arm64e-apple-macos14.0",
            "Test \"Log data to storage\" started",
            "Test \"Data storage collect new data\" started",
            "Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds",
            "Test Suite 'Selected tests' passed at 2026-04-15 15:57:17.320.",
        ]
        let expectedResult = "Test \"Data storage collect new data\" startedExecuted 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) secondsTest Suite 'Selected tests' passed at 2026-04-15 15:57:17.320."

        for log in logs {
            let logData = try #require(log.data(using: .utf8))
            try logger.log(data: logData)
        }

        var encryptedData = defaultStorage.collectedData

        // Read iv from storage
        let iv = encryptedData.prefix(AESCipher.Config.blockSize).byteArray
        encryptedData = encryptedData.subdata(in: AESCipher.Config.blockSize ..< encryptedData.count)

        let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(data: encryptedData, key: initialCredentials.key, iv: iv)
        let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
        #expect(decryptedText == expectedResult, "decryptedData should match origin data")
    }

    @Test("Ensure logs are correctly encrypted and stored under normal conditions, with iv sotred in the storage")
    func standardLoggingFlow() throws {
        let memoryStorage = MemoryStorage(maxSize: ByteSize.mb(10))
        let cipher = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var logger = SecureLogger(cipher: cipher, storage: memoryStorage, releaseFileRatio: 0.2)

        // Simulate real storage stage: [iv] + [encrypted data]
        try memoryStorage.append(data: Data(initialCredentials.iv))
        let logs = [
            "✔ Suite AESEncriptionTests passed after 0.004 seconds.",
            "✔ Suite SecureLoggerTests passed after 0.004 seconds.",
            "✔ Test \"Initialize credentials with IV\" with 7 test cases passed after 0.002 seconds.",
            "✔ Test \"Initialize credentials with key\" with 7 test cases passed after 0.002 seconds.",
            "✔ Suite AESCredentialsTests passed after 0.004 seconds.",
            "✔ Test \"When collected data exceeds maximum size, batcher flushes data to delegate\" passed after 0.517 seconds.",
            "✔ Test \"When interval is reached, batcher flushes collected data\" passed after 1.138 seconds.",
            "✔ Suite BatcherTests passed after 1.141 seconds.",
            "✔ Test run with 14 tests in 5 suites passed after 1.142 seconds.",
            "Program ended with exit code: 0",
        ]

        let expectedResult = logs.joined(separator: "\n")
        for log in logs {
            let logData = try #require(log.appending("\n").data(using: .utf8))
            try logger.log(data: logData)
        }

        var encryptedData = memoryStorage.collectedData
        let iv = encryptedData.prefix(AESCipher.Config.blockSize).byteArray
        encryptedData = encryptedData.subdata(in: AESCipher.Config.blockSize ..< encryptedData.count)
        let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(data: encryptedData, key: initialCredentials.key, iv: iv)
        let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(decryptedText == expectedResult, "decryptedData should match origin data")
    }

    @Test("Ensure logger correctly appends data to storage that already contains content")
    func loggerWithNonEmptyStorage() throws {
        // Previous session
        let initialIV = AESCipher.Credentials.randomIV()
        let storedLogs = [
            "✔ Suite AESEncriptionTests passed after 0.004 seconds.",
            "✔ Suite SecureLoggerTests passed after 0.004 seconds.",
            "✔ Test \"Initialize credentials with IV\" with 7 test cases passed after 0.002 seconds.\n",
        ].joined(separator: "\n")
        let storage = try prepareStorage(initialIV: initialIV, logs: storedLogs)

        // New session
        let iv = storage.collectedData.subdata(in: storage.collectedData.count - AESCipher.Config.blockSize ..< storage.collectedData.count)
        var credentials = try AESCipher.Credentials(base64Key: base64Key, iv: iv.byteArray)
        let cipher = try AESCipher.CBCStreamProcessor(credentials: credentials)
        var logger = SecureLogger(cipher: cipher, storage: storage, releaseFileRatio: 0.2)
        let logs = [
            "✔ Test \"Initialize credentials with key\" with 7 test cases passed after 0.002 seconds.",
            "✔ Suite AESCredentialsTests passed after 0.004 seconds.",
            "✔ Test \"When collected data exceeds maximum size, batcher flushes data to delegate\" passed after 0.517 seconds.",
            "✔ Test \"When interval is reached, batcher flushes collected data\" passed after 1.138 seconds.",
            "✔ Suite BatcherTests passed after 1.141 seconds.",
            "✔ Test run with 14 tests in 5 suites passed after 1.142 seconds.",
            "Program ended with exit code: 0",
        ]

        let expectedResult = storedLogs + logs.joined(separator: "\n")
        for log in logs {
            let logData = try #require(log.appending("\n").data(using: .utf8))
            try logger.log(data: logData)
        }

        credentials = try AESCipher.Credentials(base64Key: base64Key, iv: initialIV)
        let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(
            data: storage.collectedData.subdata(in: AESCipher.Config.blockSize ..< storage.collectedData.count),
            key: credentials.key,
            iv: credentials.iv
        )
        let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        print(decryptedText)
        #expect(decryptedText == expectedResult, "decryptedData should match origin data")
    }
}

// MARK: - Helper
private extension SecureLoggerTests {
    func prepareStorage(initialIV: [UInt8], logs: String) throws -> MemoryStorage {
        let credentials = try AESCipher.Credentials(base64Key: base64Key, iv: initialIV)
        let memoryStorage = MemoryStorage(maxSize: ByteSize.mb(10))
        let cipher = try AESCipher.CBCStreamProcessor(credentials: credentials)
        let storedData = try #require(logs.data(using: .utf8))
        var encryptedStoredData = try cipher.encrypt(data: storedData)
        try encryptedStoredData.append(cipher.finish())

        try memoryStorage.rewrite(data: initialIV + encryptedStoredData)
        return memoryStorage
    }
}

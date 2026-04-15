//
//  SecureLoggerTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Testing
@testable import UDFEncryptedFileLogger
import Foundation

struct SecureLoggerTests {
  let maxSize = 256
  var memoryStorage: MemoryStorage
  var initialCredentials: AESCipher.Credentials
  
  init() throws {
    let key = "12345678901234567890123456789012"
    let iv =  "abcdef9876543210"
    
    self.initialCredentials = try AESCipher.Credentials(base64Key: key, iv: iv.bytes)
    self.memoryStorage = MemoryStorage(maxSize: maxSize)
  }
  
  @Test("Log data to initial/empty storage")
  func testLogDataToInitializedStorage() async throws {
    let chiper = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
    var logger = SecureLogger(cipher: chiper, storage: memoryStorage)
    
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
    
    let encryptedData = memoryStorage.collectedData
    let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(data: encryptedData, key: initialCredentials.key, iv: initialCredentials.iv)
    
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
    
    #expect(decryptedText == expectedResult, "decryptedData should match origin data")
  }
  
  @Test("Ensure logger correctly handles data exceeding maximum storage capacity")
  func testStorageOverflowBehavior() async throws {
    let chiper = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
    var logger = SecureLogger(cipher: chiper, storage: memoryStorage, releaseFileRatio: 0.4)
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
    
    var encryptedData = memoryStorage.collectedData
    
    // Read iv from storage
    let iv = encryptedData.prefix(AESCipher.Config.blockSize).byteArray
    encryptedData = encryptedData.subdata(in: AESCipher.Config.blockSize..<encryptedData.count)
    
    let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(data: encryptedData, key: initialCredentials.key, iv: iv)
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
    #expect(decryptedText == expectedResult, "decryptedData should match origin data")
  }
  
  @Test("Ensure logs are correctly encrypted and stored under normal conditions, with iv sotred in the storage")
  func testStandardLoggingFlow() throws {
    let memoryStorage = MemoryStorage(maxSize: 10 * 1024 * 1024)
    let chiper = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
    var logger = SecureLogger(cipher: chiper, storage: memoryStorage, releaseFileRatio: 0.2)
    
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
    encryptedData = encryptedData.subdata(in: AESCipher.Config.blockSize..<encryptedData.count)
    let decryptedData = try AESCipher.CBCStreamProcessor.decrypt(data: encryptedData, key: initialCredentials.key, iv: iv)
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding().trimmingCharacters(in: .whitespacesAndNewlines)
    #expect(decryptedText == expectedResult, "decryptedData should match origin data")
  }
}

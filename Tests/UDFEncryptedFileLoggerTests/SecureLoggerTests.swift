//
//  SecureLoggerTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Testing
@testable import UDFEncryptedFileLogger
import Foundation

@Suite
struct SecureLoggerTests {
  var logger: SecureLogger
  var memoryStorage: MemoryStorage
  let maxSize = 128
  let key: String
  
  init() throws {
    let key = "032f75b3ca02a393"
    let iv =  "6b7f33821a2c060e"
    let credentials = try AESCipher.Credentials(key, iv: iv.bytes)
    let chiper = try AESCipher.CBCStreamProcessor(credentials: credentials)
    let memoryStorage = MemoryStorage(maxSize: maxSize)
    
    self.key = key
    self.memoryStorage = memoryStorage
    logger = SecureLogger(cipher: chiper, storage: memoryStorage)
  }
  
  @Test("Log data to empty storage")
  mutating func testLogDataToInitializedStorage() async throws {
    let logs = [
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
    let decryptedData = try logger.cipher.decode(data: encryptedData)
    
    let decryptedText = (String(data: decryptedData, encoding: .ascii) ?? "").removeNullPadding()
    
    #expect(decryptedText == expectedResult, "should match encrypted and decrypted text")
  }
  
  @Test("Log data to storage that overload max size")
  mutating func testLogDataToExistedStorage() async throws {
    let logs = [
      "Test Suite 'Selected tests'",
      "Test Suite 'UDFFileLoggerTests.xctest'",
      "Suite AESEncriptionTests started",
      "Target Platform: arm64e-apple-macos14.0",
      "Test \"Log data to storage\" started",
      "Test \"Data storage collect new data\" started",
    ]
    let expectedResult = "cos14.0Test \"Log data to storage\" startedTest \"Data storage collect new data\" started"
    
    for log in logs {
      guard let logData = log.data(using: .utf8) else {
        continue
      }
      try logger.log(data: logData)
    }
    
    let decoder = try newDecoder()
    let encryptedData = memoryStorage.collectedData
    let decryptedData = try decoder.decode(data: encryptedData)
    
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
    #expect(decryptedText == expectedResult, "should match encrypted and decrypted text")
  }
}

// MARK: - Helpers
private extension SecureLoggerTests {
  func newDecoder() throws -> AESCipher.CBCStreamProcessor {
    var encryptedData = memoryStorage.collectedData
    // load iv for correct initialize & decrypt data credential
    let iv = encryptedData.prefix(AESCipher.Credentials.keySize).byteArray
    let credentials = try AESCipher.Credentials(key, iv: iv)
    // Remove iv data from storage
    encryptedData = encryptedData.subdata(in: AESCipher.Credentials.keySize..<encryptedData.count)
    try memoryStorage.rewrite(data: encryptedData)
    
    return try AESCipher.CBCStreamProcessor(credentials: credentials)
  }
}

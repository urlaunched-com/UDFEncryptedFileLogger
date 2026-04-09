//
//  Encription.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//

import Testing
@testable import UDFFileLogger
import Foundation
import CryptoSwift

struct AESEncriptionTests {
  @Test("Verify AES-CBC stream encryption and decryption maintains data integrity")
  func testStreamDataIntegrity() throws {
    let key = "0123456789abcdef"
    let iv =  "abcdef9876543210"
    
    let stream = try AESCipher.CBCStreamProcessor(password: key, iv: iv)
    let logs = [
      "Test Suite 'Selected tests' started at 2026-04-08 23:02:38.358.",
      "Test Suite 'UDFFileLoggerTests.xctest' started at 2026-04-08 23:02:38.359.",
      "Test Suite 'UDFFileLoggerTests.xctest' passed at 2026-04-08 23:02:38.359.",
    ]
    let expectedResult = logs.joined()
    
    var encryptedData = Data()
    for log in logs {
      let data = Data(log.utf8)
      encryptedData.append(try stream.encode(data: data))
      encryptedData.append(try stream.finish())
    }
    
    var decryptedData = Data()
    for i in stride(from: 0, to: encryptedData.count, by: AES.blockSize) {
      let block = encryptedData[i..<i+AES.blockSize]
      decryptedData.append(try stream.decode(data: block))
    }
    
    let decodedText = (String(data: decryptedData, encoding: .utf8) ?? "")
      // Remove padding for successful string comparison
      .replacingOccurrences(of: "\0", with: "")
    #expect(decodedText == expectedResult, "should match encoded and decoded text")
  }
}

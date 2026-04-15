//
//  AESCredentialsTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import Testing
@testable import UDFEncryptedFileLogger
import Foundation

struct AESCredentialsTests {
  @Test(
    "Initialize credentials with key",
    arguments: [
      ("", false),
      ("short", false),
      (String(repeating: "a", count: 16), false),
      (String(repeating: "a", count: 32), true),
      ("01234567890123456789012345678901", true),
      (String(repeating: "a", count: 64), false),
      ("¡¢áéóú¡¿ÜÑáéóú¿¿", true)
    ]
  )
  func testInitializeAESKey(key: String, isValid: Bool) throws {
    let validIV = String(repeating: "a", count: AESCipher.Credentials.blockSize)
    if isValid {
      _ = try AESCipher.Credentials(key, iv: validIV.bytes)
      return
    }
    
    #expect(throws: CredentialsError.invalidKeySize) {
      try AESCipher.Credentials(key, iv: validIV.bytes)
    }
  }
  
  @Test(
    "Initialize credentials with IV",
    arguments: [
      ("", false),
      ("short", false),
      (String(repeating: "a", count: 15), false),
      (String(repeating: "a", count: 64), false),
      ("0123456789abcdef", true),
      ("abcdferfcatiroed", true),
      ("фиацвррвгцваршар", false)
    ]
  )
  func testInitializeAESIV(iv: String, isValid: Bool) throws {
    let validKey = String(repeating: "a", count: 32)
    if isValid {
      _ = try AESCipher.Credentials(validKey, iv: iv.bytes)
      return
    }
    #expect(throws: CredentialsError.invalidIVSize) {
      try AESCipher.Credentials(validKey, iv: iv.bytes)
    }
  }
  
}

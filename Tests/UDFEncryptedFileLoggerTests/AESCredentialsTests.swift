//
//  AESCredentialsTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import Testing
@testable import UDFEncryptedFileLogger
import Foundation

@Suite
struct AESCredentialsTests {
  
  @Test(
    "Initialize credentials with key",
    arguments: [
      ("", false),
      ("short", false),
      (String(repeating: "a", count: 15), false),
      (String(repeating: "a", count: 64), false),
      ("0123456789abcdef", true),
      ("abcdferfcatiroed", true),
      ("¡¢áéóú¡¿ÜÑáéóú¿¿", false)
    ]
  )
  func testInitializeAESKey(key: String, isValid: Bool) throws {
    if isValid {
      _ = try AESCipher.Credentials(key, iv: key.bytes)
      return
    }
    #expect(throws: CredentialsError.invalidKeySize) {
      try AESCipher.Credentials(key, iv: key.bytes)
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
    let validKey = "abcdferfcatiroed"
    if isValid {
      _ = try AESCipher.Credentials(validKey, iv: iv.bytes)
      return
    }
    #expect(throws: CredentialsError.invalidIVSize) {
      try AESCipher.Credentials(validKey, iv: iv.bytes)
    }
  }
  
}

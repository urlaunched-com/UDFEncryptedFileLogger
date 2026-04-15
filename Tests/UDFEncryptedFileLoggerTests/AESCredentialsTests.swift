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
    "Initialize credentials with valid/invalid key size",
    arguments: [
      ("", false),
      (String(repeating: "a", count: 16), false),
      (String(repeating: "a", count: 32), true),
      ("EXnZXdJ3DzwvkYdsEpn+4exoerM1uoM32VsIYEFztaU=", true),
      ("WaWUTDr9ykQBdOJqJkhYSiSAQnVtYvYyqsVSwqqGbww=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC8=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC89", false),
      ("4vUVP4SBr1Jc01eXRb", false),
      ("VGk5WaLFUoQPER79EaVHvMumNUfmf8gXd1C1gkGSvMg=4vUVP4SBr1Jc01eXRb", false),
      (String(repeating: "a", count: 64), false)
    ]
  )
  func testKeyWithInvalidKeySize(key: String, isValid: Bool) throws {
    let validIV = String(repeating: "a", count: AESCipher.Config.blockSize)
    if isValid {
      _ = try AESCipher.Credentials(base64Key: key, iv: validIV.bytes)
      return
    }
    
    #expect(throws: CredentialsError.invalidKeySize) {
      try AESCipher.Credentials(base64Key: key, iv: validIV.bytes)
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
      _ = try AESCipher.Credentials(base64Key: validKey, iv: iv.bytes)
      return
    }
    #expect(throws: CredentialsError.invalidIVSize) {
      try AESCipher.Credentials(base64Key: validKey, iv: iv.bytes)
    }
  }
  
}

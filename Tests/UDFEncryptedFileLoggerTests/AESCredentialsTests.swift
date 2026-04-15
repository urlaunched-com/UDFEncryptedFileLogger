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
      ("EXnZXdJ3DzwvkYdsEpn+4exoerM1uoM32VsIYEFztaU=", true),
      ("WaWUTDr9ykQBdOJqJkhYSiSAQnVtYvYyqsVSwqqGbww=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC8=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC89", false),
    ]
  )
  func testKeyWithKeySize(key: String, isValid: Bool) throws {
    let validIV = AESCipher.Credentials.randomIV()
    if isValid {
      #expect(throws: Never.self) {
        try AESCipher.Credentials(base64Key: key, iv: validIV)
      }
      return
    }
    
    #expect(throws: CredentialsError.invalidKeySize) {
      try AESCipher.Credentials(base64Key: key, iv: validIV)
    }
  }
  
  @Test(
    "Initialize credentials with valid/invalid base64 key",
    arguments: [
      ("EXnZXdJ3DzwvkYdsEpn+4exoerM1uoM32VsIYEFztaU=", true),
      ("WaWUTDr9ykQBdOJqJkhYSiSAQnVtYvYyqsVSwqqGbww=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC8=", true),
      ("8/zidRzGzMV6SRnMCSisufwJ1CCmivn0QUdl2+g5dC~d", false),
    ]
  )
  func testKeyWithBase64Text(key: String, isValid: Bool) throws {
    let validIV = AESCipher.Credentials.randomIV()
    
    if isValid {
      #expect(throws: Never.self) {
        try AESCipher.Credentials(base64Key: key, iv: validIV)
      }
      return
    }
    
    #expect(throws: CredentialsError.decodingBase64Failed) {
        try AESCipher.Credentials(base64Key: key, iv: validIV)
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
    let validKey = "EXnZXdJ3DzwvkYdsEpn+4exoerM1uoM32VsIYEFztaU="
    if isValid {
      #expect(throws: Never.self) {
        try AESCipher.Credentials(base64Key: validKey, iv: iv.bytes)
      }
      return
    }
    #expect(throws: CredentialsError.invalidIVSize) {
      try AESCipher.Credentials(base64Key: validKey, iv: iv.bytes)
    }
  }
  
}

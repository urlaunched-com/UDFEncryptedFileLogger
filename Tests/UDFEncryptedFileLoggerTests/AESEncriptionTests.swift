//
//  AESEncriptionTests.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//

import Testing
@testable import UDFEncryptedFileLogger
import Foundation
import CryptoSwift

@Suite
struct AESEncriptionTests {
  let chiper: AESCipher.CBCStreamProcessor
  
  init() throws {
    let key = "0123456789abcdef"
    let iv =  "abcdef9876543210"
    let credentials = try AESCipher.Credentials(key, iv: iv.bytes)
    
    chiper = try AESCipher.CBCStreamProcessor(credentials: credentials)
  }
  
  @Test("Test encryption and decryption using AES-CBC method")
  func testAESEncriptionData() throws {
    let logs = [
      "Reduce     DidHandleDeepLinkOpening() from DeepLinkMiddleware.swift - observe(state:) at line 42",
      "Reduce     LoadPage(id: AnyHashable(UDF.Flows.Id(value: \"QuestionnairesFlow\")), pageNumber: 1) from Common+ParticipantNavigation.swift - handleParticipantNavigation(with:) at line 28",
      "Reduce     NavigateResetStack(to: [VoiceCollection.WelcomeRouter.Route.questionnaires]) from Common+ParticipantNavigation.swift - handleParticipantNavigation(with:) at line 29",
      "Reduce     LoadPage(id: AnyHashable(UDF.Flows.Id(value: \"QuestionnairesFlow\")), pageNumber: 1) from QuestionnairesContainer.swift - onContainerDidLoad(store:) at line 25",
    ]
    let text = logs.joined()
    let data = try #require(logs.joined().data(using: .utf8))
    
    var encryptedData = try chiper.encode(data: data)
    encryptedData.append(try chiper.finish())
    let decryptedData = try chiper.decode(data: encryptedData)
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "")
      // Remove padding for successful string comparison
      .replacingOccurrences(of: "\0", with: "")
    
    #expect(decryptedText == text, "should match encoded and decoded text")
  }
  
  @Test("Verify AES-CBC stream encryption and decryption maintains data integrity")
  func testStreamDataIntegrity() throws {
    let logs = [
      "Test Suite 'Selected tests' started at 2026-04-08 23:02:38.358.",
      "Test Suite 'UDFFileLoggerTests.xctest' started at 2026-04-08 23:02:38.359.",
      "Test Suite 'UDFFileLoggerTests.xctest' passed at 2026-04-08 23:02:38.359.",
    ]
    let expectedResult = logs.joined()
    
    var encryptedData = Data()
    for log in logs {
      let data = Data(log.utf8)
      encryptedData.append(try chiper.encode(data: data))
      encryptedData.append(try chiper.finish())
    }
    
    var decryptedData = Data()
    for i in stride(from: 0, to: encryptedData.count, by: AES.blockSize) {
      let block = encryptedData[i..<i+AES.blockSize]
      decryptedData.append(try chiper.decode(data: block))
    }
    
    let decodedText = (String(data: decryptedData, encoding: .utf8) ?? "")
      // Remove padding for successful string comparison
      .replacingOccurrences(of: "\0", with: "")
    #expect(decodedText == expectedResult, "should match encoded and decoded text")
  }
}

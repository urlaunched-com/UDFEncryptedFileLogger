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
      .removeNullPadding()
    
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
      .removeNullPadding()
    #expect(decodedText == expectedResult, "should match decrypted text with expected text")
  }
  
  @Test("Decrypt text")
  func testDecryptText() throws {
    let key = "751ac96384cd9327"
    var encryptedData = Data(hex: "f2b6df6cf77f7da1304263ba511407276be2e041d951626c22426da460429efedf4601bc9bdf87cfed7b6bb7fe0db3ffc4f4aef45282f1fa1e1a9fa39bb88ed20784b6b3d1ffc91775d2b12033faf894f8368684723a6169bcf3ceaaf89ce71f531d06eb60810384213f45f5c6030eec86961450c6565391bd190c9a377d154aa84086c018c2d962572aecd02d1a7d3aa6b971c1b684958fe614b5f3f1870fb8ca54e73a90523ae185564c04ac17288e6f566d9814c86489c01565927bacb10aefc34d28fd4b10549f8b821bad2f1774327312593b14afc2dcd6b524db7972097f96b81fd041a9a5180097e81e50455ab1b6e95b7262552ba5b7adc4f0b9c11235e3e56c7b2bee52ea0d959dc09ff42bc307c8936be78e74fd58053cebe0082b01b0e790c9b773d8d1e70d549c5788bde3d397f67a14e51220bfd592867b9cb44ab642f961f0b4a7d436520706ca6dd21d102e5a70cc24c7852b3b05e35918177a455443615838a1dc5d36014d13347629f99d040195bd65c2d831420e3657b73c4a541f177836fb98f25084478cabb42cd21ea00560adab6084da26dfd1c4bb3fcb18821217cf8c6e909cb783db504321914575ce879cac454829589132ddbb15375425cade4a06d54b2f9fe2fa3bad412d175276bef9bc94f85d5265d581061965a319cfca822e6071c9541c50ccaad82a9f05a250e3e7551260ed5bcefacfffcf1ed65b10ae9ba4856bd6aea2d62f13aeaa4ca5b2c18cf87012b9aef94e7e22e84bfe682fef2bf427ee18defcf7b60395b9809a71bfad7031fc345648103294d7103ef610a4421ffe4c0218ddd639d0f8d7c2f91d2ce29686a0e33bdc4bc2cad2499365cc2d9140d9922f9b01411e95caa2abc8389e522885f38cc42d2e64bf3a53d8409ccb442f8414c100371d22e5d44e32389190ae83fd8720a39c51894c000737092cf8475a7adf946fd925e06862fa186f96cafc37f8f2b2070f1a9943ac9dcf6ccf67549dce88458fa9db3f1a9c45c8193c3e3d361d63c84f2f19d8e68fb471a15c5759742d23236ddc30aaecd19c6bff6d20a7149906c72704ef7a474453a55800a2ae4b4d89b069cd01f013fb19991a0248798c15cf8b1bad3d6b367d50459b02cb8036eaa80513db745aa7ad133c6a54b1d74c492514b8ca93bb6df7fd92a07a4fc798efe4520943d4c7b88004f05cbebb573c656bd6f4cbe8eabcd96d8c4b168bd155f7b57972b8427fcfa63c92d3138fdf53715bdf498bfbc3ea5392aa8b4e493daf0f58dca347168af42273cac6df75877937a6c4069f8bbec3ef369c4f5da7b59854314a588b5e33248f320a53e6d0daa27b4a8af298b04f849377929c98e7b967885d39263ca5d5c2b1132da3b56ec96a15a044eab599f4b77d1a122c0a451e40c170eb2898d9611dedbe6ee54b181a2043a74b841bbaafc337f9e1a73c9eec1ff62547296a6976eaaf56e6b24289e532375659a127d4f0ee6a087455d3467de6186fb3cec64a8b73af099368800fce41d919196ebb60b5759616e3fd889e6a85faadaed016a87c76f964b69c5d4ec140ef4065138634a8f98ac81e0035ce57eafcd70edd91415ad63027d8d5b0f7b14b09502814a2674bf7c068e4e870fd74b96d5ed794b5a6c6692a3f73752446964373b1af8177a994f9d29a07378a22c6d6f7ec5f2c2c66c327db130daea1d4be3ef279cc7dfed610e82d209484a7a0fe7a5c1a835c2181d3a42b2688afdccce1fc13fc947489679dba0cb2f9b4f608781c8c89b3cfd14e92478082b973ce5fc7b0ae297ff6a8a34feecb3515f61d89a6d5721ead8f13acc74b14fb19c8cd70c28973548f60cb97398f26cb459fb1552bae73bc80f4217c5621106de83bb9857b2ddb0d3f87d9054171bab7802bb1adfcabe18b761b85b06853791eeba2354b612dc7320a7188e331f9654c13617a4e4c55949f15fa998f510afb4e63abd4e85930851f4f736fbd3377e28b5075bf6f14196dba173a0693313238ef07931b084923ccba70a620f4f45eb3155831f35d7ffd63757c42c7a0d24b564e5a7a28ecde85898b586595a64bf86c69423519a509480a7cae6308824d76bab1d5d176fd7885c0eacd4ec7c80e3f0f270b690857d96060812942adf371067c55b11c40940f38845862e015f5273555f78a441c6904fff18ca13240be3b1d2c427ffa2c4b604d1a67ef1da85b54e4affe11f7a669e7385994cc3f15799ecca1b034341006844e3a9b83b85f119916833902aa708d62d4036bd8f469654133121c04af8a077343d25f8ed9ad5bb52fa492868df2bceb9c536bc30f61aaad9a07253e47213ee733f19a0fab0ebd23f7a40d45eedbc725b7a8516fed697dc39b01745b3b8055e2ea2539961b312d4cc1d390e2da444544a67b53c33b8e61e2486ca1608353a3efe963d753dd620fb76e7bd592a40c35420df9cc188e1054eecf0519b80892b8b888e2fe6b1509591c6957c307de284a40883555d0d005e760fdffee217be0a62d45ea41b7dd55a843d4c8ed673e1228e0f7fb8945bc6333f257d59c321136f4ce7ee0c68209055330248f289de20a1451ebbe0c608c8ea684eef8aa1f2aa73a26a6d9bb55035cf15f7369759c461ac347518cce57c4a31b0b5dd7c041ef6239617fa9c2cc7823f67e0c63de40085c983a888f6560f111a52cfb5cccae4b69c8e626f36678c0a223eab7df9d1cf33495ddb2172071d29dac06a3127019fb871ae6261ae644872a81c1")
    let expectedResult = "tion.QuestionnaireTask.ID(value: 5), VoiceCollection.QuestionnaireSubtask.ID(value: 12)), VoiceCollection.QuestionnaireStep.imageSubtask(VoiceCollection.QuestionnaireTask.ID(value: 6), VoiceCollection.QuestionnaireSubtask.ID(value: 13)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 7), VoiceCollection.QuestionnaireSubtask.ID(value: 14)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 7), VoiceCollection.QuestionnaireSubtask.ID(value: 15)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 7), VoiceCollection.QuestionnaireSubtask.ID(value: 16)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 7), VoiceCollection.QuestionnaireSubtask.ID(value: 17)), VoiceCollection.QuestionnaireStep.imageCarouselSubtask(VoiceCollection.QuestionnaireTask.ID(value: 8), VoiceCollection.QuestionnaireSubtask.ID(value: 18)), VoiceCollection.QuestionnaireStep.previewTask(VoiceCollection.QuestionnaireTask.ID(value: 9)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 9), VoiceCollection.QuestionnaireSubtask.ID(value: 19)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 9), VoiceCollection.QuestionnaireSubtask.ID(value: 20)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 10), VoiceCollection.QuestionnaireSubtask.ID(value: 21)), VoiceCollection.QuestionnaireStep.textSubtask(VoiceCollection.QuestionnaireTask.ID(value: 10), VoiceCollection.QuestionnaireSubtask.ID(value: 22))], id: AnyHashable(UDF.Flows.Id(value: \"QuestionnairesFlow\"))) from QuestionnairesMiddleware.swift - observe(state:) at line 87Navigate(to: [VoiceCollection.QuestionnairesRouter.Route.complete]) from QuestionnairesMiddleware.swift - observe(state:) at line 94"
    let iv = encryptedData.prefix(AESCipher.Credentials.keySize).byteArray
    let credentials = try AESCipher.Credentials(key, iv: iv)
    encryptedData = encryptedData.subdata(in: AESCipher.Credentials.keySize..<encryptedData.count)
    
    let decrypter = try AESCipher.CBCStreamProcessor(credentials: credentials)
    let decryptedData = try decrypter.decode(data: encryptedData)
    
    let decryptedText = (String(data: decryptedData, encoding: .utf8) ?? "").removeNullPadding()
    #expect(decryptedText == expectedResult, "should match decrypted text with expected text")
  }
}

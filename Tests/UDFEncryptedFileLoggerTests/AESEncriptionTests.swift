//
//  AESEncriptionTests.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//

import Foundation
import Testing
@testable import UDFEncryptedFileLogger

struct AESEncriptionTests {
    var initialCredentials: AESCipher.Credentials

    init() throws {
        let key = "qeQ2xcG1ICJN4tBemRT6zdb4zQ/W6g8vvw4FycRx3Lw="
        let iv = "abcdef9876543210"

        self.initialCredentials = try AESCipher.Credentials(base64Key: key, iv: iv.bytes)
    }

    @Test("Test encryption and decryption using AES-CBC method")
    func aesEncryptionData() throws {
        let logs = [
            "Reduce     DidHandleDeepLinkOpening() from DeepLinkMiddleware.swift - observe(state:) at line 42",
            "Reduce     LoadPage(id: AnyHashable(UDF.Flows.Id(value: \"QuestionnairesFlow\")), pageNumber: 1) from Common+ParticipantNavigation.swift - handleParticipantNavigation(with:) at line 28",
            "Reduce     NavigateResetStack(to: [VoiceCollection.WelcomeRouter.Route.questionnaires]) from Common+ParticipantNavigation.swift - handleParticipantNavigation(with:) at line 29",
            "Reduce     LoadPage(id: AnyHashable(UDF.Flows.Id(value: \"QuestionnairesFlow\")), pageNumber: 1) from QuestionnairesContainer.swift - onContainerDidLoad(store:) at line 25",
        ]

        let text = logs.joined()
        let data = try #require(text.data(using: .utf8))

        let encryptionProcessor = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var encryptedData = try encryptionProcessor.encrypt(data: data)
        try encryptedData.append(encryptionProcessor.finish())

        let decryptedData = try AESCipher.AESCryptor.decrypt(
            data: encryptedData,
            key: initialCredentials.key,
            iv: initialCredentials.iv
        )
        let decryptedText = String(data: decryptedData, encoding: .utf8)?.removeNullPadding()
        #expect(decryptedText == text)
    }

    @Test("Verify AES-CBC stream encryption and decryption maintains data integrity")
    func streamDataIntegrity() throws {
        let logs = [
            "Test Suite 'Selected tests'",
            "Test Suite 'UDFFileLoggerTests.xctest'",
            "Suite AESEncriptionTests started!",
            "Test Suite 'Selected tests' passed at 2026-04-15 18:02:24.759. Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.001) seconds",
            "Test Suite 'UDFEncryptedFileLoggerTests.xctest' passed at 2026-04-15 18:02:24.759. Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.000) seconds",
            "Test Suite 'Selected tests' passed at 2026-04-15 18:02:24.759. Executed 0 tests, with 0 failures (0 unexpected) in 0.000 (0.001) seconds",
            "◇ Test run started.",
        ]
        let expectedResult = logs.joined()

        let encryptionProcessor = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var encryptedData = Data()
        for log in logs {
            let data = Data(log.utf8)
            try encryptedData.append(encryptionProcessor.encrypt(data: data))
            try encryptedData.append(encryptionProcessor.finish())
        }

        let decryptedData = try AESCipher.AESCryptor.decrypt(
            data: encryptedData,
            key: initialCredentials.key,
            iv: initialCredentials.iv
        )

        let decodedText = (String(data: decryptedData, encoding: .utf8) ?? "")
            // Remove padding for successful string comparison
            .removeNullPadding()

        #expect(decodedText == expectedResult, "should match decrypted text with expected text")
    }

    @Test("Ensure data can be decrypted correctly while the stream is still active")
    func decryptDataFromMidEncryptedData() throws {
        let logs = [
            "◇ Test \"Verify AES-CBC stream encryption and decryption maintains data integrity\" started.",
            "◇ Test \"Test encryption and decryption using AES-CBC method\" started.",
            "✔ Test \"Verify AES-CBC stream encryption and decryption maintains data integrity\" passed after 0.001 seconds.",
            "✔ Test \"Test encryption and decryption using AES-CBC method\" passed after 0.001 seconds.",
            "✔ Suite AESEncriptionTests passed after 0.001 seconds.",
            "✔ Test run with 2 tests in 1 suite passed after 0.001 seconds.",
            "Program ended with exit code: 0",
        ]

        let expectedResult = "tarted.✔ Test \"Verify AES-CBC stream encryption and decryption maintains data integrity\" passed after 0.001 seconds.✔ Test \"Test encryption and decryption using AES-CBC method\" passed after 0.001 seconds.✔ Suite AESEncriptionTests passed after 0.001 seconds.✔ Test run with 2 tests in 1 suite passed after 0.001 seconds.Program ended with exit code: 0"
        let encryptionProcessor = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var encryptedData = Data()
        for log in logs {
            let data = Data(log.utf8)
            try encryptedData.append(encryptionProcessor.encrypt(data: data))
            try encryptedData.append(encryptionProcessor.finish())
        }

        // Start decrypting data from a middle encrypted block boundary
        let offset = encryptionProcessor.blockSize * 10
        let iv = encryptedData.subdata(in: offset - encryptionProcessor.blockSize ..< offset)
        encryptedData = Data(encryptedData.suffix(from: offset))
        let decryptedData = try AESCipher.AESCryptor.decrypt(data: encryptedData, key: initialCredentials.key, iv: iv.byteArray)

        let decodedText = (String(data: decryptedData, encoding: .utf8) ?? "")
            // Remove padding for successful string comparison
            .removeNullPadding()

        #expect(decodedText == expectedResult, "should match decrypted text with expected text")
    }

    @Test("Try to encrypt empty data")
    func encryptAndDecryptEmptyData() throws {
        let data = Data()
        let encryptionProcessor = try AESCipher.CBCStreamProcessor(credentials: initialCredentials)
        var encryptedData = try encryptionProcessor.encrypt(data: data)
        encryptedData = try encryptionProcessor.finish()
        let decryptedData = try AESCipher.AESCryptor.decrypt(
            data: encryptedData,
            key: initialCredentials.key,
            iv: initialCredentials.iv
        )
        #expect(decryptedData == data, "decrypted data should be empty, like original data")
    }
}

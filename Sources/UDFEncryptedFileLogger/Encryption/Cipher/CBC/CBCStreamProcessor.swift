//
//  CBCStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import CommonCrypto
import Foundation

extension AESCipher {
    final class CBCStreamProcessor: StreamCipherable {
        var credentials: Credentials
        private var remainderData = Data()

        var blockSize: Int {
            Config.blockSize
        }

        init(credentials: Credentials) throws {
            self.credentials = credentials
        }

        func encrypt(data: Data) throws -> Data {
            var workingData = remainderData
            workingData.append(data)

            let fullBlockLength = (workingData.count / blockSize) * blockSize

            let dataToEncrypt = workingData.prefix(fullBlockLength)
            remainderData = workingData.suffix(workingData.count - fullBlockLength)

            let encryptedData = try encrypt(data: dataToEncrypt, credentials: credentials, padding: .none)
            if encryptedData.count >= blockSize {
                credentials.iv = encryptedData.suffix(blockSize)
            }
            return Data(encryptedData)
        }

        func finish() throws -> Data {
            guard !remainderData.isEmpty else {
                return Data()
            }

            let encryptedData = try encrypt(
                data: remainderData,
                credentials: credentials,
                padding: .zero
            )

            if encryptedData.count >= blockSize {
                credentials.iv = encryptedData.suffix(blockSize)
            }

            remainderData.removeAll()
            return encryptedData
        }
    }
}

private extension AESCipher.CBCStreamProcessor {
    func encrypt(data: Data, credentials: AESCipher.Credentials, padding: AESCipher.AESCryptor.Padding = .none) throws -> Data {
        try AESCipher.AESCryptor(credentials: credentials, padding: padding).encrypt(data: data)
    }
}

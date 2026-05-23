//
//  AESCryptor.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 22.05.2026.
//

import CommonCrypto
import Foundation

extension AESCipher {
    final class AESCryptor: Cryptable {
        private let credentials: Credentials
        private let padding: Padding
        private let blockSize = kCCBlockSizeAES128

        enum Padding {
            case none
            case zero
        }

        init(credentials: AESCipher.Credentials, padding: Padding = .none) {
            self.credentials = credentials
            self.padding = padding
        }

        func decrypt(data: Data) throws -> Data {
            guard !data.isEmpty else {
                return Data()
            }

            var outputBuffer = [UInt8](repeating: 0, count: data.count)
            var numBytesDecrypted = 0

            let status = CCCrypt(
                CCOperation(kCCDecrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(0),
                credentials.key,
                kCCKeySizeAES256,
                credentials.iv,
                Array(data),
                data.count,
                &outputBuffer,
                outputBuffer.count,
                &numBytesDecrypted
            )

            guard status == kCCSuccess else {
                throw CipherError.decryptionFailed
            }

            let decryptedBytes = outputBuffer.prefix(numBytesDecrypted)

            switch padding {
            case .none:
                return Data(decryptedBytes)
            case .zero:
                return Data(decryptedBytes.reversed().drop(while: { $0 == 0 }).reversed())
            }
        }

        func encrypt(data: Data) throws -> Data {
            guard !data.isEmpty else {
                return Data()
            }

            var paddedData = data

            switch padding {
            case .none:
                break
            case .zero:
                let remainder = paddedData.count % blockSize
                if remainder > 0 {
                    let paddingSize = blockSize - remainder
                    paddedData.append(
                        contentsOf: [UInt8](
                            repeating: 0,
                            count: paddingSize
                        )
                    )
                }
            }

            var outputBuffer = [UInt8](repeating: 0, count: paddedData.count)
            var numBytesEncrypted = 0

            let status = CCCrypt(
                CCOperation(kCCEncrypt),
                CCAlgorithm(kCCAlgorithmAES),
                CCOptions(0),
                Array(credentials.key),
                kCCKeySizeAES256,
                Array(credentials.iv),
                Array(paddedData),
                paddedData.count,
                &outputBuffer,
                outputBuffer.count,
                &numBytesEncrypted
            )
            guard status == kCCSuccess else {
                throw CipherError.encryptionFailed
            }

            let outputBytes = outputBuffer.prefix(numBytesEncrypted)
            return Data(outputBytes)
        }

        static func decrypt(data: Data, key: [UInt8], iv: [UInt8]) throws -> Data {
            try AESCryptor(credentials: Credentials(key: key, iv: iv)).decrypt(data: data)
        }
    }
}

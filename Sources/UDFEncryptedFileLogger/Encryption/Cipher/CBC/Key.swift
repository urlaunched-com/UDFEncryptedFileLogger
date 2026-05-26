//
//  Key.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import CommonCrypto
import Foundation

extension AESCipher {
    struct Credentials: KeyValidatable {
        let key: [UInt8]
        var iv: [UInt8]

        init(base64Key value: String, iv: [UInt8] = Self.randomIV()) throws {
            let key = try Self.validate(base64Key: value)
            try Self.validateIV(iv)

            self.key = key.byteArray
            self.iv = iv
        }

        init(key: [UInt8], iv: [UInt8] = Self.randomIV()) throws {
            try Self.validate(key: key)
            self.key = key
            self.iv = iv
        }

        // MARK: - KeyValidatable
        static func validate(base64Key: String) throws -> Data {
            guard let keyData = Data(base64Encoded: base64Key) else {
                throw CredentialsError.decodingBase64Failed
            }

            guard keyData.count == AESCipher.Config.keySize else {
                throw CredentialsError.invalidKeySize
            }

            return keyData
        }

        static func validate(key: [UInt8]) throws {
            guard key.count == AESCipher.Config.keySize else {
                throw CredentialsError.invalidKeySize
            }
        }

        // MARK: - Internal
        static func randomIV(_ count: Int = AESCipher.Config.blockSize) -> [UInt8] {
            (0 ..< count).map { _ in UInt8.random(in: 0 ... UInt8.max) }
        }
    }
}

// MARK: - Private
private extension AESCipher.Credentials {
    static func validateIV(_ iv: [UInt8]) throws {
        if iv.count != AESCipher.Config.blockSize {
            throw CredentialsError.invalidIVSize
        }
    }
}

extension AESCipher {
    enum Config {
        static let blockSize = 16
        static let keySize = kCCKeySizeAES256
    }
}

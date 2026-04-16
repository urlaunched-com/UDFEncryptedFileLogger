//
//  CipherFactory.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

enum CipherFactory {
    static func make(
        for method: EncryptionMethod,
        fileURL: URL,
        key: String? = nil
    ) throws -> StreamCipherable {
        switch method {
        case .plaintext:
            return AESCipher.PassthroughStreamProcessor()
        case let .aesCBC(key):
            let iv = try resolveIV(for: fileURL)
            let credentials = try AESCipher.Credentials(base64Key: key, iv: iv)
            if try FileManager.default.isFileEmpty(fileURL) {
                try Data(iv).write(to: fileURL)
            }

            return try AESCipher.CBCStreamProcessor(credentials: credentials)
        }
    }

    private static func resolveIV(for url: URL) throws -> [UInt8] {
        let blockSize = AESCipher.Config.blockSize
        if let existingIV = try? FileManager.default.read(at: url, upToCount: blockSize), existingIV.count == blockSize {
            return existingIV.byteArray
        }

        return AESCipher.Credentials.randomIV()
    }
}

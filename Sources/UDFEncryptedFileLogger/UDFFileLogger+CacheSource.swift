//
//  UDFFileLogger+CacheSource.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 20.05.2026.
//
import CryptoKit
import Foundation
import UDF

extension UDFFileLogger: CacheSource {
    static let maxFileSizeInMB = ByteSize.mb(10)
    static let directoryName: String = "SecureLoggerDirectory"

    var fileStorage: FileStorage? {
        guard
            let logger = self.logger as? SecureLogger,
            let fileStorage = logger.storage as? FileStorage
        else {
            return nil
        }

        return fileStorage
    }

    // MARK: - CacheSource
    public convenience init(key: String) {
        do {
            let cacheFileURL = try FileManager.createCacheFileIfNeeded(key: key)
            let storage = try StorageFactory.fileStorage(fileURL: cacheFileURL, maxFileSizeInMB: Self.maxFileSizeInMB)
            let aesKey = Self.makeValidAESKey(from: key)
            let cipher = try CipherFactory.make(for: .aesCBC(key: aesKey), fileURL: cacheFileURL)
            let logger = SecureLogger(cipher: cipher, storage: storage)
            try self.init(logger: logger)
        } catch {
            fatalError("UDFFileLogger init(key: String) failed: \(error)")
        }
    }

    public func save(_ value: some Sendable & Encodable) {
        dispatchQueue.async(flags: .barrier) { [weak self] in
            guard let data = try? JSONEncoder().encode(value), let url = self?.fileStorage?.fileURL else {
                return
            }
            do {
                let fileHandle = try FileHandle(forUpdating: url)
                try fileHandle.truncate(atOffset: UInt64(AESCipher.Config.keySize))
                try self?.logger.log(data: data)
            } catch {
                print(error)
            }
        }
    }

    public func load<T: Decodable>() -> T? {
        dispatchQueue.sync {
            guard
                let url = fileStorage?.fileURL,
                let logger = self.logger as? SecureLogger,
                let cipher = logger.cipher as? Decryptable,
                let data = try? Data(contentsOf: url), !data.isEmpty,
                let decryptedData = try? cipher.decrypt(data: data)
            else {
                return nil
            }

            return try? JSONDecoder().decode(T.self, from: decryptedData)
        }
    }

    public func remove() {
        dispatchQueue.async(flags: .barrier) { [fileStorage] in
            guard let fileStorage else {
                return
            }
            try? FileManager.clearFile(at: fileStorage.fileURL)
        }
    }
}

private extension UDFFileLogger {
    static func makeValidAESKey(from string: String) -> String {
        let data = Data(string.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash.prefix(AESCipher.Config.keySize)).base64EncodedString()
    }
}

//
//  EncryptedCacheSource.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 22.05.2026.
//
import CryptoKit
import Foundation
import UDF

public final class EncryptedCacheSource: @unchecked Sendable {
    private let key: String
    private let queue: DispatchQueue
    private var dataStorable: DataStorable?
    private let cryptor: Cryptable?

    public required convenience init(key: String) {
        var cryptor: Cryptable?
        var fileStorage: FileStorage?
        do {
            let credentials = try AESCipher.Credentials(
                key: Self.makeValidAESKey(from: key),
                iv: Self.makeValidIV(from: key)
            )
            cryptor = AESCipher.AESCryptor(credentials: credentials, padding: .zero)
            if let fileURL = Self.url(for: key, directoryName: "encrypted_data") {
                fileStorage = try FileStorage(fileURL: fileURL, maxFileSize: ByteSize.mb(10))
            }
        } catch {
            print("EncryptedCacheSource: failed to initialize for key '\(key)': \(error)")
        }

        self.init(key: key, cryptor: cryptor, dataStorable: fileStorage)
    }

    init(key: String, cryptor: Cryptable?, dataStorable: DataStorable?) {
        self.key = key
        self.queue = DispatchQueue(
            label: "EncryptedCacheSource.queue.\(key)",
            qos: .userInitiated,
            attributes: .concurrent,
            autoreleaseFrequency: .workItem
        )
        self.dataStorable = dataStorable
        self.cryptor = cryptor
    }
}

// MARK: - CacheSource
extension EncryptedCacheSource: CacheSource {
    public func save(_ value: some Sendable & Encodable) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self, let cryptor else {
                return
            }
            do {
                let valueData = try JSONEncoder().encode(value)
                let encryptedData = try cryptor.encrypt(data: valueData)
                try self.dataStorable?.rewrite(data: encryptedData)
            } catch {
                print("EncryptedCacheSource: failed to save value for key '\(self.key)': \(error)")
            }
        }
    }

    public func load<T: Decodable>() -> T? {
        queue.sync { [dataStorable, cryptor] in
            guard let dataStorable, let cryptor else {
                return nil
            }
            do {
                let encryptedData = try dataStorable.read()
                let decryptedData = try cryptor.decrypt(data: encryptedData)
                return try JSONDecoder().decode(T.self, from: decryptedData)
            } catch {
                print("EncryptedCacheSource: failed to load value for key '\(self.key)': \(error)")
            }
            return nil
        }
    }

    public func remove() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else {
                return
            }
            do {
                try self.dataStorable?.rewrite(data: Data())
            } catch {
                print("EncryptedCacheSource: failed to remove value for key '\(self.key)': \(error)")
            }
        }
    }
}

// MARK: - Helpers
private extension EncryptedCacheSource {
    static func url(for key: String, directoryName: String) -> URL? {
        FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(directoryName)
            .appendingPathComponent(key)
            .appendingPathExtension("bin")
    }

    static func makeValidAESKey(from string: String) -> [UInt8] {
        let data = Data((string + "key").utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash.prefix(AESCipher.Config.keySize)).byteArray
    }

    static func makeValidIV(from string: String) -> [UInt8] {
        let data = Data((string + "iv").utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash.prefix(AESCipher.Config.blockSize)).byteArray
    }
}

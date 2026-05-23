//
//  UDFFileLogger+Init.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation
import UDF

public extension ActionLogger where Self == UDFFileLogger {
    static var empty: UDFFileLogger {
        UDFFileLogger()
    }

    static func fileLogger(
        fileURL: URL,
        maxFileSizeInMB: Int = 50,
        encryptionMethod: EncryptionMethod = .plaintext,
        extraFilters: [ActionFilter] = []
    ) -> ActionLogger? {
        do {
            try FileManager.createFileIfNeeded(at: fileURL, permission: 0o600)
            let storage = try StorageFactory.fileStorage(fileURL: fileURL, maxFileSizeInMB: maxFileSizeInMB)
            let cipher = try CipherFactory.make(for: encryptionMethod, fileURL: fileURL)
            return try UDFFileLogger(
                intervalToSync: 1,
                logger: SecureLogger(cipher: cipher, storage: storage),
                filters: [.default] + extraFilters
            )
        } catch {
            print("[UDFFileLogger] Failed to initialize logger: \(error.localizedDescription)")
            return nil
        }
    }

    static func file(
        fileURL: URL,
        maxFileSizeInMB: Int = 50,
        encryptionMethod: EncryptionMethod = .plaintext,
        extraFilters: [ActionFilter] = []
    ) -> ActionLogger {
        .fileLogger(
            fileURL: fileURL,
            maxFileSizeInMB: maxFileSizeInMB,
            encryptionMethod: encryptionMethod,
            extraFilters: extraFilters
        ) ?? .empty
    }
}

//
//  CipherError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//
import Foundation

enum CipherError: Error, LocalizedError {
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            "Encryption failed"
        case .decryptionFailed:
            "Decryption failed"
        }
    }
}

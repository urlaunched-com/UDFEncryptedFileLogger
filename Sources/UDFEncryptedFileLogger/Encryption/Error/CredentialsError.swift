//
//  CredentialsError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Foundation

enum CredentialsError: Error, LocalizedError {
    case invalidKeySize
    case decodingBase64Failed
    case invalidIVSize
    case initializationIVFailed

    var errorDescription: String? {
        switch self {
        case .invalidKeySize:
            "Invalid key size, expected 16 bytes"
        case .decodingBase64Failed:
            "Failed to decode base64 string"
        case .invalidIVSize:
            "Invalid IV size, expected 16 bytes"
        case .initializationIVFailed:
            "Failed to initialize IV"
        }
    }
}

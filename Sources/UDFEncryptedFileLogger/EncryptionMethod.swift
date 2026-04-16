//
//  EncryptionMethod.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

public enum EncryptionMethod {
    case plaintext
    /// Requires a 32-byte key (AES-256) encoded in Base64
    case aesCBC(key: String)
}

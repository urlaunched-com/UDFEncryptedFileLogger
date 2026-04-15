//
//  ChiperError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//
import Foundation

enum ChiperError: Error, LocalizedError {
  case missingParameters
  case encryptionFailed
  case decryptionFailed
  
  var errorDescription: String? {
    switch self {
    case .missingParameters:
      return "Missing required cipher parameters"
    case .encryptionFailed:
      return "Encryption failed"
    case .decryptionFailed:
      return "Decryption failed"
    }
  }
}

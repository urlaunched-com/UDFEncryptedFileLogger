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
      return "Invalid key size, expected 16 bytes"
    case .decodingBase64Failed:
      return "Failed to decode base64 string"
    case .invalidIVSize:
      return "Invalid IV size, expected 16 bytes"
    case .initializationIVFailed:
      return "Failed to initialize IV"
    }
  }
}

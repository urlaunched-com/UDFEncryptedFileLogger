//
//  CredentialsError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Foundation

enum CredentialsError: Error, LocalizedError {
  case invalidKeySize
  case invalidIVSize
  case initializationIVFailed

  var errorDescription: String? {
    switch self {
    case .invalidKeySize:
      return "Invalid key size, expected 16 bytes"
    case .invalidIVSize:
      return "Invalid IV size, expected 16 bytes"
    case .initializationIVFailed:
      return "Failed to initialize IV"
    }
  }
}

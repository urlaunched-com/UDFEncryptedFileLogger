//
//  StorageError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

enum StorageError: Error, LocalizedError {
  case sizeOverflow
  case initializationFailed
  case invalidSizeParameter

  var errorDescription: String? {
    switch self {
    case .sizeOverflow:
      return "Storage size limit exceeded"
    case .initializationFailed:
      return "Storage initialization failed"
    case .invalidSizeParameter:
      return "Invalid size parameter provided"
    }
  }
}

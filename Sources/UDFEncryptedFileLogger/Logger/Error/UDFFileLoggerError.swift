//
//  FileError.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//

import Foundation

public enum UDFFileLoggerError: Error, Equatable, LocalizedError, Sendable {
  case isNotFile(url: URL)
  case invalidPermission(at: URL, filePermission: String)
  case creatingDirectoryFailed(at: URL)
  case creatingFileFailed(at: URL)
  case openingForWritingFailed(at: URL)
  case readFailed(at: URL)
  case deleteFailed(at: URL)
  case missingParameters
  case internalFailure
  
  public var errorDescription: String? {
    switch self {
      case .isNotFile(url: let url):
        return "\(url) is not a file"
      case .invalidPermission(at: let url, filePermission: let filePermission):
        return "invalid file permission. file: \(url), permission: \(filePermission)"
      case .creatingDirectoryFailed(at: let url):
        return "failed to create a directory: \(url)"
      case .creatingFileFailed(at: let url):
        return "failed to create a file: \(url)"
      case .openingForWritingFailed(at: let url):
        return "failed to open a file for writing: \(url)"
      case .deleteFailed(at: let url):
        return "failed to delete a file: \(url)"
      case .internalFailure:
        return "internal error"
      case .missingParameters:
        return "missing required parameters"
      default:
        return "file operation failed"
    }
  }
}

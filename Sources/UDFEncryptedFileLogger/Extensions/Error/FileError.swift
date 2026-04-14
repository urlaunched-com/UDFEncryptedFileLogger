//
//  FileError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//
import Foundation

enum FileError: LocalizedError {
  case creationFailed(URL)
  
  var errorDescription: String? {
    switch self {
    case .creationFailed(let url):
      return "Failed to create file at: \(url.path)"
    }
  }
}

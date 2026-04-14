//
//  ChiperError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//
import Foundation

enum ChiperError: Error, LocalizedError {
  case missingParameters
  
  var errorDescription: String? {
    switch self {
    case .missingParameters:
      return "Missing required cipher parameters"
    }
  }
}

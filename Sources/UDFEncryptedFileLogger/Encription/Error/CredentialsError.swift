//
//  CredentialsError.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Foundation

enum CredentialsError: Error {
  case invalidKeySize
  case initializationFailed
}

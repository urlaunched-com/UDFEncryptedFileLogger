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
        case let .creationFailed(url):
            "Failed to create file at: \(url.path)"
        }
    }
}

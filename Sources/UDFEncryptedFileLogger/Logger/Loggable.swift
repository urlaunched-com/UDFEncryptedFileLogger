//
//  Loggable.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//
import Foundation

protocol Loggable {
  mutating func log(data: Data) throws
}

//
//  SecureLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

struct SecureLogger: Loggable {
  private let cipher: StreamCipherable
  private var storage: DataStorable
  let releaseFileRatio: Double = 0.2
  
  init(
    cipher: StreamCipherable,
    storage: DataStorable,
  ) {
    self.cipher = cipher
    self.storage = storage
  }
  
  mutating func log(data: Data) throws {
    let encodedData = try cipher.encode(data: data)
    
    do {
      try storage.append(data: encodedData)
    } catch StorageError.sizeOverflow {
      let releaseByteSize = Int(Double(storage.size) * releaseFileRatio)
      try storage.reduce(size: releaseByteSize)
      try storage.append(data: encodedData)
    }
  }
}

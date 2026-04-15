//
//  SecureLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

struct SecureLogger: Loggable {
  let cipher: StreamCipherable
  var storage: DataStorable
  let writeMode: WriteMode
  let releaseFileRatio: Double
  
  init(
    cipher: StreamCipherable,
    storage: DataStorable,
    writeMode: WriteMode = .bin,
    releaseFileRatio: Double = 0.4
  ) {
    self.cipher = cipher
    self.storage = storage
    self.writeMode = writeMode
    self.releaseFileRatio = min(1, max(0, releaseFileRatio))
  }
  
  mutating func log(data: Data) throws {
    var encryptedData = try cipher.encode(data: data)
    encryptedData.append(try cipher.finish())
    let transformedData = try writeMode.encode(encryptedData)
    
    do {
      try storage.append(data: transformedData)
    } catch StorageError.sizeOverflow {
      var releaseByteSize = Int(Double(storage.size) * releaseFileRatio)
      
      let scaleBlock = writeMode == .hex ? 2 : 1
      let blockSize = cipher.blockSize * scaleBlock
      releaseByteSize -= releaseByteSize % blockSize
      
      try storage.reduce(size: releaseByteSize)
      try storage.append(data: transformedData)
    }
  }
}

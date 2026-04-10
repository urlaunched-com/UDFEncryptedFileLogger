//
//  MemoryStorage.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

/// Usage for testing purpose
struct MemoryStorage: DataStorable {
  private(set) var collectedData: Data
  let maxSize: UInt64
  
  init(maxSize: UInt64, data: Data = Data()) {
    self.maxSize = maxSize
    self.collectedData = data
  }
  
  var size: Int {
    collectedData.count
  }
}

// MARK: - DataStorable
extension MemoryStorage: DataWritable {
  mutating func append(data: Data) throws {
    if UInt64(size + data.count) > maxSize {
      throw StorageError.sizeOverflow
    }
    
    collectedData.append(data)
  }
  
  mutating func rewrite(data: Data) throws {
    collectedData = data
  }
}

// MARK: - DataCloseable
extension MemoryStorage: DataCloseable {
  mutating func close() throws {
    collectedData = Data()
  }
}

// MARK: - DataCompactor
extension MemoryStorage: DataCompactor {
  mutating func reduce(size releaseByteSize: Int) throws {
    let newData = collectedData.subdata(in: releaseByteSize..<collectedData.count)
    
    try rewrite(data: newData)
  }
}

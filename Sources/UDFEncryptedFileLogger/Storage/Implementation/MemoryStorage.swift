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
  let maxSize: Int
  
  init(maxSize: Int, data: Data = Data()) {
    self.maxSize = maxSize
    self.collectedData = data.prefix(maxSize)
  }
  
  var size: Int {
    collectedData.count
  }
}

// MARK: - DataStorable
extension MemoryStorage: DataWritable {
  mutating func append(data: Data) throws {
    guard size + data.count <= maxSize else {
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
    guard releaseByteSize >= 0 else {
      throw StorageError.invalidSizeParameter
    }
    guard !collectedData.isEmpty else {
      return
    }
    
    let startPosition = max(0, min(releaseByteSize, collectedData.count - 1))
    let newData = collectedData.subdata(in: startPosition..<collectedData.count)
    try rewrite(data: newData)
  }
}

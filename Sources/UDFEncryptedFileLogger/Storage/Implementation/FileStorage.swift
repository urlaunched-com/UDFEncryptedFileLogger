//
//  FileStorage.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Foundation

struct FileStorage: DataStorable {
  var fileHandle: FileHandle
  var fileURL: URL
  var maxFileSize: Int
  
  var size: Int {
    let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
    return attributes?[.size] as? Int ?? .zero
  }
  
  init(fileURL: URL, maxFileSize: Int) throws {
    self.fileURL = fileURL
    self.maxFileSize = maxFileSize
    
    do {
      self.fileHandle = try FileHandle(forWritingTo: fileURL)
    } catch {
      throw StorageError.initializationFailed
    }
  }
}

// MARK: - DataStorable
extension FileStorage: DataWritable {
  /// Data should be appended to end of file.
  /// Throws `StorageError.sizeOverrun` if appending would exceed `maxFileSize`.
  func append(data: Data) throws {
    if size + data.count > maxFileSize {
      throw StorageError.sizeOverflow
    }
    
    try fileHandle.seekToEnd()
    try fileHandle.write(contentsOf: data)
  }
  
  func rewrite(data: Data) throws {
    try fileHandle.seek(toOffset: 0)
    try fileHandle.truncate(atOffset: 0)
    try fileHandle.write(contentsOf: data)
  }
  
}

// MARK: - DataCloseable
extension FileStorage: DataCloseable {
  func close() throws {
    try fileHandle.close()
  }
}

// MARK: - DataCompactor
extension FileStorage: DataCompactor {
  func reduce(size releaseByteSize: Int) throws {
    guard size > 0 else {
      return
    }
    guard releaseByteSize >= 0 else {
      throw StorageError.invalidSizeParameter
    }
    let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    let newData = data.subdata(in: releaseByteSize..<data.count)
    try rewrite(data: newData)
  }
}

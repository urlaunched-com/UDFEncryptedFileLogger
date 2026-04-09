//
//  FileLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import Foundation

/// An abstract base class providing a foundation for file-based logging
class FileLogger: @unchecked Sendable, FileWritable, FileCompactor {
  var fileHandle: FileHandle
  var fileURL: URL
  var maxFileSize: UInt64
  var releaseFileRatio: Double = 0.2
  
  init(fileURL: URL, maxFileSize: UInt64) throws {
    self.fileURL = fileURL
    self.maxFileSize = maxFileSize
    if try FileManager.createFileIfNeeded(at: fileURL) {
      self.fileHandle = try FileHandle(forWritingTo: fileURL)
    } else {
      throw UDFFileLoggerError.internalFailure
    }
  }
  
  deinit {
    try? fileHandle.close()
  }
  
  // MARK: - FileWritable
  
  func append(data: Data) throws {
    if let fileSize, fileSize > maxFileSize {
      let trimBytes = UInt64(Double(fileSize) * releaseFileRatio)
      try reduce(size: trimBytes)
    }
    
    try fileHandle.write(contentsOf: data)
  }
  
  func rewrite(data: Data) throws {
    try fileHandle.seek(toOffset: 0)
    try fileHandle.truncate(atOffset: 0)
    try fileHandle.write(contentsOf: data)
  }
  
  // MARK: - FileCompactor
  
  func reduce(size releaseByteSize: UInt64) throws { }
}

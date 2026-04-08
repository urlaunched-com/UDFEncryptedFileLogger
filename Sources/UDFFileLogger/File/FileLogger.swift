//
//  FileLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import Foundation

class FileLogger: FileWritable, @unchecked Sendable {
  var fileHandle: FileHandle
  var fileURL: URL
  var maxFileSize: UInt64
  
  init(fileURL: URL, maxFileSize: UInt64) throws {
    self.fileURL = fileURL
    self.maxFileSize = maxFileSize
    if try Self.ensureFileExists(url: fileURL) {
      self.fileHandle = try FileHandle(forWritingTo: fileURL)
    } else {
      throw FileError.internalFail
    }
  }
  
  deinit {
    try? fileHandle.close()
  }
  
  func append(string: String) throws {
    guard let data = (string + "\n").data(using: .utf8) else {
      throw FileError.internalFail
    }
    
    if let fileSize, fileSize > maxFileSize {
      let trimBytes = Int(Double(fileSize) * 0.2)
      try trimFontFile(sizeBytes: trimBytes)
    }
    
    try fileHandle.write(contentsOf: data)
  }
  
  func rewrite(data: Data) throws {
    try fileHandle.seek(toOffset: 0)
    try fileHandle.truncate(atOffset: 0)
    try fileHandle.write(contentsOf: data)
  }
}

private extension FileLogger {
  func trimFontFile(sizeBytes: Int) throws {
    guard let newLine = "\n".data(using: .utf8) else {
      throw FileError.internalFail
    }
    
    let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    
    var processedBytes = 0
    var position = 0
    while processedBytes < sizeBytes {
      let searchRange = position..<data.count
      
      if let range = data.range(of: newLine, options: [], in: searchRange) {
        processedBytes += data.subdata(in: position..<range.upperBound).count
        position = range.upperBound
      } else {
        break
      }
    }
    
    var newData = data.subdata(in: position..<data.count)
    try rewrite(data: newData)
  }
  
  static func ensureFileExists(url: URL) throws -> Bool {
    let fileManager = FileManager.default
    
    let directory = url.deletingLastPathComponent()
    if !fileManager.fileExists(atPath: directory.path) {
      try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    if !fileManager.fileExists(atPath: url.path) {
      fileManager.createFile(atPath: url.path, contents: nil)
    }
    
    return fileManager.fileExists(atPath: url.path)
  }
}

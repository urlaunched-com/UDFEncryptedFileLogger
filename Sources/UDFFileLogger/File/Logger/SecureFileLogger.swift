//
//  SecureFileLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

class SecureFileLogger: FileLogger, @unchecked Sendable {
  private let processor: StreamCipherable
  
  init(fileURL: URL, maxFileSize: UInt64, processor: StreamCipherable) throws {
    self.processor = processor
    
    try super.init(fileURL: fileURL, maxFileSize: maxFileSize)
  }
  
  override func append(data: Data) throws {
    let encodedData = try processor.encode(data: data)
    try append(data: encodedData)
    
    try super.append(data: data)
  }
  
  override func reduce(size releaseByteSize: UInt64) throws {
    try trimFontFile(sizeBytes: releaseByteSize)
  }
}

private extension SecureFileLogger {
  func trimFontFile(sizeBytes: UInt64) throws {
    let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
    let position = sizeBytes - sizeBytes % processor.blockSize
    
    let newData = data.subdata(in: Data.Index(position)..<data.count)
    try rewrite(data: newData)
  }
}

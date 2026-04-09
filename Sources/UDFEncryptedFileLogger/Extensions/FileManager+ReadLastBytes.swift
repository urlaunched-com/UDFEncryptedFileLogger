//
//  FileManager+ReadLastBytes.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

extension FileManager {
  func read(at url: URL, upToCount: Int) throws -> Data? {
    let fileHandle = try FileHandle(forReadingFrom: url)
    defer {
      try? fileHandle.close()
    }
    
    let fileSize = try fileHandle.seekToEnd()
    let bytesToRead = min(UInt64(upToCount), fileSize)
    try fileHandle.seek(toOffset: fileSize - bytesToRead)
    return try fileHandle.read(upToCount: Int(bytesToRead))
  }
}

//
//  FileWritable.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//

import Foundation

protocol FileWritable: Sendable {
  var fileURL: URL { get }
  
  func append(data: Data) throws
  func rewrite(data: Data) throws
}

extension FileWritable {
  var fileSize: UInt64? {
    let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path)
    return attributes?[.size] as? UInt64
  }
}

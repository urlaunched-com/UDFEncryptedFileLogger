//
//  EmptyLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

class EmptyLogger: @unchecked Sendable, FileWritable {
  var fileURL: URL
  
  init() {
    self.fileURL = URL(fileURLWithPath: "/dev/null")
  }
  
  func append(data: Data) throws {}
  func rewrite(data: Data) throws {}
}

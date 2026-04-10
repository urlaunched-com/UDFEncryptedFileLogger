//
//  EmptyLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

/// For testing purpose
struct EmptyLogger: Loggable {
  init() {}
  
  func log(data: Data) throws {}
}

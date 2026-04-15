//
//  NopLogger.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

import Foundation

/// For testing purpose
struct NopLogger: Loggable {
  init() {}
  
  func log(data: Data) throws {}
}

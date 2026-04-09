// The Swift Programming Language
// https://docs.swift.org/swift-book

import UDF
import Foundation
import UDFMacros

public class UDFFileLogger: ActionLogger, @unchecked Sendable {
  public var actionFilters: [ActionFilter]
  public var actionDescriptor: ActionDescriptor
  
  private let dispatchQueue = DispatchQueue(label: "udf.file.logger")
  private var batcher: Batcher?
  private var fileLogger: FileWritable
  
  init(
    intervalToSync: TimeInterval = 1,
    fileLogger: FileWritable,
    filters: [ActionFilter] = [],
    actionDescriptor: ActionDescriptor = StringDescribingActionDescriptor()
  ) throws {
    self.batcher = Batcher(
      interval: intervalToSync,
      maxSize: 2 * 1024 * 1024,
      on: dispatchQueue
    )
    self.actionFilters = filters
    self.actionDescriptor = actionDescriptor
    self.fileLogger = fileLogger
    
    self.batcher?.delegate = self
  }
  
  public func log(_ action: LoggingAction, description: String) {
    var descrition = description
    if let sensitiveAction = action.value as? SensitiveDataRepresentable {
      descrition = sensitiveAction.plainDescription
    }
    
    if let data = descrition.data(using: .utf8) {
      batcher?.collect(data)
    }
  }
  
  init() {
    self.actionFilters = []
    self.actionDescriptor = StringDescribingActionDescriptor()
    self.fileLogger = EmptyLogger()
  }
}

// MARK: - BatcherDelegate
extension UDFFileLogger: BatcherDelegate {
  func batcher(_ batcher: Batcher, didFlush data: Data) {
    try? fileLogger.append(data: data)
  }
}

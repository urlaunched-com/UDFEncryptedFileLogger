// The Swift Programming Language
// https://docs.swift.org/swift-book

import UDF
import Foundation
import UDFMacros

public final class UDFFileLogger: ActionLogger, @unchecked Sendable {
  
  // MARK: - ActionLogger
  public var actionFilters: [ActionFilter]
  public var actionDescriptor: ActionDescriptor
  
  // MARK: - Private properties
  private let dispatchQueue = DispatchQueue(label: "udf.file.logger")
  private var batcher: Batcher?
  private var logger: Loggable
  
  init(
    intervalToSync: TimeInterval = 1,
    logger: Loggable,
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
    self.logger = logger
    
    self.batcher?.delegate = self
  }
  
  public func log(_ action: LoggingAction, description: String) {
    var descrition = description
    if let sensitiveAction = action.value as? SensitiveDataRepresentable {
      descrition = sensitiveAction.plainDescription
    }
    
    if let data = descrition.appending("\n").data(using: .utf8) {
      batcher?.collect(data)
    }
  }
  
  init() {
    self.actionFilters = []
    self.actionDescriptor = StringDescribingActionDescriptor()
    self.logger = NopLogger()
  }
}

// MARK: - BatcherDelegate
extension UDFFileLogger: BatcherDelegate {
  func batcher(_ batcher: Batcher, didFlush data: Data) {
    do {
      try logger.log(data: data)
    } catch {
      print("[UDFFileLogger] Log failed: \(error.localizedDescription)")
    }
  }
}

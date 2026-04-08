// The Swift Programming Language
// https://docs.swift.org/swift-book

import UDF
import Foundation
import UDFMacros

public class UDFFileLogger: ActionLogger, @unchecked Sendable {
  public var actionFilters: [ActionFilter]
  public var actionDescriptor: ActionDescriptor
  
  private let dispatchQueue = DispatchQueue(label: "udf.file.logger")
  private var debouncer: Debouncer<String>?
  private var fileLogger: FileLogger
  
  public init(
    fileURL: URL,
    maxFileSizeInMB: UInt,
    intervalToSync: TimeInterval = 1,
    filters: [ActionFilter],
    actionDescriptor: ActionDescriptor = StringDescribingActionDescriptor()
  ) throws {
    let maxFileSizeInBytes = UInt64(maxFileSizeInMB) * 1024 * 1024
    
    self.debouncer = Debouncer<String>(intervalToSync, on: dispatchQueue)
    self.actionFilters = filters
    self.actionDescriptor = actionDescriptor
    self.fileLogger = try FileLogger(fileURL: fileURL, maxFileSize: 1024)
    
    debouncer?.on { [weak self] strings in
      let string = strings.joined(separator: "\n")
      try? self?.fileLogger.append(string: string)
      
      self?.debouncer?.clear()
    }
  }
  
  public func log(_ action: LoggingAction, description: String) {
    var descrition = description
    if let sensitiveAction = action.value as? SensitiveDataRepresentable {
      descrition = sensitiveAction.plainDescription
    }
    
    debouncer?.insert(descrition)
  }
}

public extension ActionLogger where Self == UDFFileLogger {
  static func fileLogger(
    fileURL: URL,
    maxFileSizeInMB: UInt,
    extraFilters: [ActionFilter] = []
  ) -> ActionLogger? {
    try? UDFFileLogger(
      fileURL: fileURL,
      maxFileSizeInMB: maxFileSizeInMB,
      filters: [.debugOnly] + extraFilters
    )
  }
}

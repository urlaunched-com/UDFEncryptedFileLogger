//
//  Debouncer.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import Foundation

protocol BatcherDelegate: AnyObject {
  func batcher(_ batcher: Batcher, didFlush data: Data)
}

final class Batcher: @unchecked Sendable {
  private var collectedData = Data()
  private var interval: TimeInterval
  private var maxSize: Int
  private var queue: DispatchQueue
  private var debounceWorkItem: DispatchWorkItem = DispatchWorkItem {}
  private let lock = NSLock()
  weak var delegate: BatcherDelegate?
  
  init(
    interval: TimeInterval,
    maxSize: Int,
    on queue: DispatchQueue = .main,
    delegate: BatcherDelegate? = nil
  ) {
    self.interval = interval
    self.queue = queue
    self.maxSize = maxSize
    self.delegate = delegate
  }
  
  func collect(_ data: Data) {
    let shouldFlush = lock.withLock {
      collectedData.append(data)
      return collectedData.count > maxSize
    }
    
    if shouldFlush {
      queue.async { [weak self] in
        self?.onFlush()
      }
      return
    }
    dispatchDebounce()
  }
}

// MARK: - Helper Methods
private extension Batcher {
  func dispatchDebounce() {
    self.debounceWorkItem.cancel()
    self.debounceWorkItem = DispatchWorkItem { [weak self] in
      self?.onFlush()
    }
    queue.asyncAfter(deadline: .now() + interval, execute: debounceWorkItem)
  }
  
  func onFlush() {
    let data = lock.withLock {
      return collectedData
    }
    
    delegate?.batcher(self, didFlush: data)
    lock.withLock {
      collectedData = Data()
    }
  }
}

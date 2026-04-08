//
//  Debouncer.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 08.04.2026.
//
import Foundation

final class Debouncer<C>: @unchecked Sendable {
  /// The latest received value.
  private var queuedValues: [C] = []
  
  /// Timestamp of the latest value received.
  private var valueTimestamp: Date = .init()
  
  /// The debounce interval.
  private var interval: TimeInterval
  
  /// The queue on which debounce operations are performed.
  private var queue: DispatchQueue
  
  /// Callbacks to be executed when the debounce interval passes.
  private var callbacks: (([C]) -> Void)?
  
  /// The work item used to manage debounce delays.
  private var debounceWorkItem: DispatchWorkItem = DispatchWorkItem {}
  
  /// Initializes a new `Debouncer` with the specified interval and dispatch queue.
  ///
  /// - Parameters:
  ///   - interval: The debounce interval in seconds.
  ///   - queue: The dispatch queue on which to perform debounce operations. Default is `.main`.
  init(_ interval: TimeInterval, on queue: DispatchQueue = .main) {
    self.interval = interval
    self.queue = queue
  }
  
  /// Receives a new value and resets the debounce timer.
  ///
  /// - Parameter value: The value to be debounced.
  func insert(_ value: C) {
    queuedValues.append(value)
    dispatchDebounce()
  }
  
  func clear() {
    queuedValues = []
  }
  
  /// Adds a callback to be executed when the debounce interval passes.
  ///
  /// - Parameter throttled: The callback to execute with the debounced value.
  func on(throttled: @escaping ([C]) -> Void) {
    self.callbacks = throttled
  }
}

// MARK: - Helper Methods
private extension Debouncer {
  /// Dispatches the debounce work item to run after the specified interval.
  func dispatchDebounce() {
    self.valueTimestamp = Date()
    self.debounceWorkItem.cancel()
    self.debounceWorkItem = DispatchWorkItem { [weak self] in
      self?.onDebounce()
    }
    queue.asyncAfter(deadline: .now() + interval, execute: debounceWorkItem)
  }
  
  /// Called when the debounce interval has passed, executing the stored callbacks.
  func onDebounce() {
    if Date().timeIntervalSince(self.valueTimestamp) > interval {
      sendValue()
    }
  }
  
  /// Executes all callbacks with the debounced value.
  func sendValue() {
    if !queuedValues.isEmpty {
      callbacks?(queuedValues)
    }
  }
}

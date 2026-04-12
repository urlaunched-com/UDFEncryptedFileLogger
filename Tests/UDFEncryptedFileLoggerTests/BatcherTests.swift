//
//  BatcherTests.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

import Testing
@testable import UDFEncryptedFileLogger
import Foundation
import CryptoSwift

@Suite
struct BatcherTests {
  let batcher: Batcher
  fileprivate let batcherDelegateWrapper: BatcherDelegateWrapper
  let maxSize = 128
  let interval: TimeInterval = 1
  
  init() {
    batcher = Batcher(interval: interval, maxSize: maxSize)
    batcherDelegateWrapper = BatcherDelegateWrapper()
    batcher.delegate = batcherDelegateWrapper
  }
  
  @Test("When collected data exceeds maximum size, batcher flushes data to delegate")
  func flushesDataWhenBatcherReachesMaximumSize() async throws  {
    let data = Data(repeating: 0x00, count: maxSize)
    batcher.collect(data)
    
    let appendedData = Data(repeating: 0x11, count: maxSize)
    batcher.collect(appendedData)
    
    let expectedData = data + appendedData
      
    try await Task.sleep(for: .milliseconds(500))
    
    #expect(
      batcherDelegateWrapper.collectedData == expectedData,
      "collected data should be flushed when batcher reaches maximum size"
    )
  }
  
  @Test("When interval is reached, batcher flushes collected data")
  func flushesDataWhenIntervalIsReached() async throws {
    let data = Data(repeating: 0x00, count: maxSize)
    
    #expect(
      batcherDelegateWrapper.collectedData == Data(),
      "collected data should be empty before emitting new data to batcher"
    )
    
    batcher.collect(data)
    // add delay before collecting data in batcher
    try await Task.sleep(for: .seconds(1.1 * interval))
    
    #expect(
      batcherDelegateWrapper.collectedData == data,
      "collected data should be flushed when batcher is inactive during the interval"
    )
  }
}

// MARK: - Helped/Mocked classes
private extension BatcherTests {
  class BatcherDelegateWrapper: BatcherDelegate {
    var collectedData = Data()
    
    func batcher(_ batcher: UDFEncryptedFileLogger.Batcher, didFlush data: Data) {
      collectedData.append(data)
    }
  }
}

//
//  CBCStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation
import CommonCrypto

extension AESCipher {
  final class CBCStreamProcessor: StreamCipherable {
    private var credentials: Credentials
    private var remainderData = Data()
    
    var blockSize: Int {
      kCCBlockSizeAES128
    }
    
    init(credentials: Credentials) throws {
      self.credentials = credentials
    }
    
    func encode(data: Data) throws -> Data {
      var workingData = remainderData
      workingData.append(data)
      
      let fullBlockLength = (workingData.count / blockSize) * blockSize
      
      let dataToEncrypt = workingData.prefix(fullBlockLength)
      remainderData = workingData.suffix(workingData.count - fullBlockLength)
      
      let encryptedData = try encrypt(data: dataToEncrypt, key: credentials.key, iv: credentials.iv, padding: .none)
      
      if encryptedData.count >= blockSize {
        credentials.iv = encryptedData.suffix(blockSize)
      }
      return Data(encryptedData)
    }
    
    func finish() throws -> Data {
      guard !remainderData.isEmpty else {
        return Data()
      }
      
      let encryptedData = try encrypt(
        data: remainderData,
        key: credentials.key,
        iv: credentials.iv,
        padding: .zero
      )
      
      if encryptedData.count >= blockSize {
        credentials.iv = encryptedData.suffix(blockSize)
      }
      remainderData.removeAll()
      return encryptedData
    }
    
    static func decode(data: Data, key: Array<UInt8>, iv: Array<UInt8>) throws -> Data {
      guard !data.isEmpty else {
        return Data()
      }
      
      var outputBuffer = [UInt8](repeating: 0, count: data.count)
      var numBytesDecrypted = 0
      
      let status = CCCrypt(
        CCOperation(kCCDecrypt),
        CCAlgorithm(kCCAlgorithmAES),
        CCOptions(0),
        key,
        kCCKeySizeAES256,
        iv,
        Array(data),
        data.count,
        &outputBuffer,
        outputBuffer.count,
        &numBytesDecrypted
      )
      
      guard status == kCCSuccess else {
        throw ChiperError.decryptionFailed
      }
      
      return Data(outputBuffer.prefix(numBytesDecrypted))
    }
  }
}

private extension AESCipher.CBCStreamProcessor {
  enum Padding {
    case none
    case zero
  }
  
  func encrypt(data: Data, key: Array<UInt8>, iv: Array<UInt8>, padding: Padding = .none) throws -> Data {
    guard !data.isEmpty else {
      return Data()
    }
    
    var paddedData = data
    
    switch padding {
    case .none:
      break
    case .zero:
      let remainder = paddedData.count % blockSize
      if remainder > 0 {
        let paddingSize = blockSize - remainder
        paddedData.append(
          contentsOf: [UInt8](
            repeating: 0,
            count: paddingSize
          )
        )
      }
    }
    
    var outputBuffer = Array<UInt8>(repeating: 0, count: paddedData.count)
    var numBytesEncrypted = 0
    
    let status = CCCrypt(
      CCOperation(kCCEncrypt),
      CCAlgorithm(kCCAlgorithmAES),
      CCOptions(0),
      Array(key),
      kCCKeySizeAES256,
      Array(iv),
      Array(paddedData),
      paddedData.count,
      &outputBuffer,
      outputBuffer.count,
      &numBytesEncrypted
    )
    guard status == kCCSuccess else {
      throw ChiperError.encryptionFailed
    }
    
    let outputBytes = outputBuffer.prefix(numBytesEncrypted)
    return Data(outputBytes)
  }
}

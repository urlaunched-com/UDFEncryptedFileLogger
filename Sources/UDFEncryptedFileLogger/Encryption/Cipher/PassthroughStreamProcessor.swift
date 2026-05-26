//
//  PassthroughStreamProcessor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

extension AESCipher {
    final class PassthroughStreamProcessor: StreamCipherable {
        var blockSize: Int {
            1
        }

        func encrypt(data: Data) throws -> Data {
            data
        }

        func finish() throws -> Data {
            Data()
        }
    }
}

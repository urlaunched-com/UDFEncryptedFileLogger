//
//  FileCompactor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

protocol FileCompactor {
  func reduce(size releaseByteSize: UInt64) throws
}

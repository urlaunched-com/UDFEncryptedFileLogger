//
//  DataCompactor.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

protocol DataCompactor {
  mutating func reduce(size releaseByteSize: Int) throws
}

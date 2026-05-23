//
//  DataStorable.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 10.04.2026.
//

protocol DataStorable: DataWritable, DataCompactor, DataCloseable, DataReadable {
    var size: Int { get }
}

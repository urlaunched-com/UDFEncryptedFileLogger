//
//  EncryptionMethod.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//

public enum EncryptionMethod {
  case plaintext
  case aesCBC(key: String)
}

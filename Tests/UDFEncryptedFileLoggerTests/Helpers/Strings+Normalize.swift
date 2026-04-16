//
//  Strings+Normalize.swift
//  UDFEncryptedFileLogger
//
//  Created by Bogdan Petkanych on 14.04.2026.
//

import Foundation

extension String {
    func removeNullPadding() -> Self {
        replacingOccurrences(of: "\0", with: "")
    }
}

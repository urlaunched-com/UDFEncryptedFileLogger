//
//  FileManager+CreateFile.swift
//  UDFFileLogger
//
//  Created by Bogdan Petkanych on 09.04.2026.
//
import Foundation

extension FileManager {
    @discardableResult
    static func createFileIfNeeded(at url: URL, permission: Int = 0o600) throws -> Bool {
        let fm = FileManager.default

        let directory = url.deletingLastPathComponent()
        if !fm.fileExists(atPath: directory.path) {
            try fm.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        if !fm.fileExists(atPath: url.path) {
            let attributes: [FileAttributeKey: Any] = [
                .posixPermissions: permission,
                .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication,
            ]
            let created = fm.createFile(atPath: url.path, contents: nil, attributes: attributes)
            if !created {
                throw FileError.creationFailed(url)
            }
        }

        return fm.fileExists(atPath: url.path)
    }
}

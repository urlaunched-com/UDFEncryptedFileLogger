# UDFEncryptedFileLogger

Lightweight encrypted file logger for UDF applications

UDFEncryptedFileLogger allows to persist application events into a file with optional encryption support.

## Features

1. Optional AES-CBC encryption
2. Automatic file size management
3. Efficient I/O usage optimized for frequent logging

## Usage

Example showing encrypted file logging inside a typical UDF setup:

```swift
let encryptedFileURL = applicationSupportDirectory
  .appending(path: "udf_encrypted_logger")
  .appendingPathExtension("txt")

let secureKey = "751ac96384cd9327"

store = EnvironmentStore(
  initial: AppState(),
  loggers: [
    .consoleDebug,
    .fileLoggerOrEmpty(
      fileURL: encryptedFileURL,
      maxFileSizeInMB: 100,
      encryptionMethod: .aesCBC(key: secureKey)
    ),
  ]
)

# UDFEncryptedFileLogger

## Overview

A lightweight file logger for **SwiftUDF** applications with encryption support. Designed for fast and simple integration into existing **SwiftUDF** projects. With just a few lines of code, you can start logging data to a file, either encrypted or unencrypted.

## Features

1. Supports AES encryption in CBC mode using a native SDK implementation for reliable and efficient performance.
2. Supports logging data without encryption.
3. Automatic file size management with configurable maximum file size.
4. Optimized I/O performance for high-frequency logging
5. Supports decrypting data with third-party tools: [AAX](https://github.com/eneko/axx)
6. Designed to be simple and easy to use

## Usage

The library can be added via Swift Package Manager:

```swift 
.package(url: "https://github.com/urlaunched-com/UDFEncryptedFileLogger", from: "1.0.0")
```

It is recommended to integrate the library in the main application entry point, together with initialization UDF components. 

Example showing initialization logger inside a typical **SwiftUDF** setup:

```swift
let encryptedFileURL = applicationSupportDirectory.appending(path: "logger").appendingPathExtension("enc")
store = EnvironmentStore(
    initial: AppState(),
    loggers: [
      .defaultFileLogger(
        fileURL: encryptedFileURL,
        maxFileSizeInMB: 150,
        encryptionMethod: .aesCBC(key: base64SecretKey)
      ),
    ]
)
```

You need to provide a private key. The key must be in Base64 format and have a size of 256 bits. You can use the AAX utility to simplify integration with the library.

```bash
$ brew install eneko/tap/axx
```
This CLI tool helps generate a key:

```bash
$ axx k > ./.key.pem
```

With the command below, you can copy the key:

```bash
$ cat ./.key.pem | sed -n '2p' | pbcopy
```

It is recommended to store the key in an .xcconfig file and load it in the main application entry point to configure the logger.

Data can be decrypted at any time using the private key:

```bash
 axx d -i ./.key.pem logger.enc
```
This will produce logger.enc.plain with the decrypted content.

## Logger Design

AES-CBC encrypted data is structured as **[IV][Encrypted Data]**. This is a common format for storing data encrypted with this method. When the logger exceeds the maximum file size, it removes the oldest logs by deleting the first **20%** of the file to ensure space for new content. For a better logging experience, it is recommended to set the maximum file size to **100–200 MB**. The logger introduces a delay before writing data to a file and writes data in chunks, allowing I/O operations to be used more efficiently.

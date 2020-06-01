//
//  WiltonIOUtils.swift
//  ios
//
//  Created by Alexey Liverty on 5/31/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

private let HEX_SYMBOLS = "0123456789abcdef".unicodeScalars.map { $0 }

let wiltonFilesDir: URL = Bundle.main.url(forResource: "index", withExtension: "js", subdirectory: "app")!.deletingLastPathComponent();

let wiltonAppDir: URL = wiltonFilesDir.appendingPathComponent("app")

func wiltonRelPath(_ path: String) -> String {
     let dir = wiltonFilesDir.absoluteString
     if !path.hasPrefix(dir) {
         return path;
     }
     let range = path.index(after: dir.endIndex) ..< path.endIndex
     return String(path[range])
 }

func readFileToByteArray(_ file: URL) throws -> [UInt8] {
    guard let data = NSData(contentsOf: file) else {
        throw WiltonException("Error reading file, path: [\(file)]")
    }
    var buffer = [UInt8](repeating: 0, count: data.length)
    data.getBytes(&buffer, length: data.length)
    return buffer
}

func readFileToString(_ file: URL) throws -> String {
    let data = try readFileToByteArray(file)
    return String(bytes: data, encoding: .utf8)!
}

func encodeHex(_ data: [UInt8]) -> String {
    return String(data.reduce(into: "".unicodeScalars, { (result, value) in
        result.append(HEX_SYMBOLS[Int(value / 16)])
        result.append(HEX_SYMBOLS[Int(value % 16)])
    }))
}


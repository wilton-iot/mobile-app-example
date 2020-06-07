//
//  WiltonIOUtils.swift
//  ios
//
//  Created by Alexey Liverty on 5/31/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

let WILTON_ZIP_PROTO = "zip://"
let WILTON_FILE_PROTO = "file://"

private let HEX_SYMBOLS = "0123456789abcdef".unicodeScalars.map { $0 }

let wiltonFilesDir: URL = Bundle.main.url(forResource: "index", withExtension: "js", subdirectory: "app")!.deletingLastPathComponent().deletingLastPathComponent()

let wiltonAppDir: URL = wiltonFilesDir.appendingPathComponent("app")

func wiltonRelPath(_ path: String) -> String {
    let dir = wiltonFilesDir.absoluteString
    if !path.hasPrefix(dir) {
        return path;
    }
    let range = dir.endIndex ..< path.endIndex
    return String(path[range])
}

func wiltonFullPath(_ path: String) -> URL {
      var fullPath = path
      if !fullPath.hasPrefix(WILTON_FILE_PROTO) {
          fullPath = WILTON_FILE_PROTO + path
      }
      return URL(string: fullPath) ?? URL(string: "INVALID_PATH")!
}

func readFileToBytes(_ path: String) throws -> Data {
    do {
        let url = wiltonFullPath(path)
        return try Data(contentsOf: url)
    } catch {
        throw WiltonException("WiltonIOUtils: Error reading file, path: [\(path)], message: [\(error)]")
    }
}

func readFileToString(_ path: String) throws -> String {
    let data = try readFileToBytes(path)
    return String(bytes: data, encoding: .utf8)!
}

func writeBytesToFile(_ path: String, _ bytes: Data) throws {
    do {
        let url = wiltonFullPath(path)
        try bytes.write(to: url)
    } catch {
        throw WiltonException("WiltonIOUtils: Error writing binary file, path: [\(path)], message: [\(error)]")
    }
}

func writeStringToFile(_ path: String, _ str: String) throws {
    do {
        let url = wiltonFullPath(path)
        try str.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        throw WiltonException("WiltonIOUtils: Error writing file, path: [\(path)], message: [\(error)]")
    }
}

func encodeHex(_ bytes: Data) -> String {
    return String(bytes.reduce(into: "".unicodeScalars, { (result, value) in
        result.append(HEX_SYMBOLS[Int(value / 16)])
        result.append(HEX_SYMBOLS[Int(value % 16)])
    }))
}

func decodeHex(_ str: String) -> Data {
    let hex = str.dropFirst(str.hasPrefix("0x") ? 2 : 0)
    let len = hex.count / 2
    var data = Data(capacity: len)
    for i in 0..<len {
        let j = hex.index(hex.startIndex, offsetBy: i*2)
        let k = hex.index(j, offsetBy: 2)
        let bytes = hex[j..<k]
        if var num = UInt8(bytes, radix: 16) {
            data.append(&num, count: 1)
        } else {
            return Data()
        }
    }
    return data
}

func wiltonIsDirectory(_ path: String) -> Bool {
    do {
        let url = wiltonFullPath(path)
        let values = try url.resourceValues(forKeys: [.isDirectoryKey])
        return values.isDirectory ?? false
    } catch {
        return false
    }
}

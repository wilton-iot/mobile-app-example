//
//  WriteFile.swift
//  ios
//
//  Created by Alexey Liverty on 6/7/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WriteFile : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let path = opts.path else {
            throw WiltonException("Fs/WriteFile: Required parameter 'path' not specified")
        }
        guard let data = opts.data else {
            throw WiltonException("Fs/WriteFile: Required parameter 'data' not specified")
        }
        do {
            if opts.hex {
                let bytes = decodeHex(data)
                try writeBytesToFile(path, bytes)
            } else {
                try writeStringToFile(path, data)
            }
        return ""
        } catch {
            throw WiltonException("Fs/ReadDir: Error writing file, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
        var data: String?
        var hex: Bool = false
    }
}

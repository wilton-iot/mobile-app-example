//
//  ReadFile.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class ReadFile : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let path = opts.path else {
            throw WiltonException("Fs/ReadFile: Required parameter 'path' not specified")
        }
        if (opts.hex) {
            let bytes = try readFileToByteArray(path);
            return encodeHex(bytes);
        } else {
            return try readFileToString(path);
        }
    }
    
    class Options : Codable {
        var path: String?
        var hex: Bool = false
    }
}

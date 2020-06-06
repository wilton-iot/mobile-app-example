//
//  MkDir.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class MkDir : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard var path = opts.path else {
            throw WiltonException("Fs/MkDir: Required parameter 'path' not specified")
        }
        if !path.hasPrefix(WILTON_FILE_PROTO) {
            path = URL(string: path)!.relativePath
        }
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            return ""
        } catch {
            throw WiltonException("Fs/MkDir: Error creating directory, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
    }
}

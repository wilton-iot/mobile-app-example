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
        guard let path = opts.path else {
            throw WiltonException("Fs/MkDir: Required parameter 'path' not specified")
        }
        do {
            let url = URL(string: path) ?? URL(string: "INVALID_PATH")!
            try FileManager.default.createDirectory(atPath: url.relativePath, withIntermediateDirectories: false, attributes: nil)
            return ""
        } catch {
            throw WiltonException("Fs/MkDir: Error creating directory, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
    }
}

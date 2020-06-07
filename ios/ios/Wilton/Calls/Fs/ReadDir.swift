//
//  ReadDir.swift
//  ios
//
//  Created by Alexey Liverty on 6/7/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class ReadDir : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let path = opts.path else {
            throw WiltonException("Fs/ReadDir: Required parameter 'path' not specified")
        }
        do {
            let url = URL(string: path) ?? URL(string: "INVALID_PATH")!
            let list = try FileManager.default.contentsOfDirectory(atPath: url.relativePath)
            return wiltonToJson(list)
        } catch {
             throw WiltonException("Fs/ReadDir: Error creating directory, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
    }
}

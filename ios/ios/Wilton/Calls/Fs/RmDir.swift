//
//  RmDir.swift
//  ios
//
//  Created by Alexey Liverty on 6/7/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class RmDir : Call {
    
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let path = opts.path else {
            throw WiltonException("Fs/RmDir: Required parameter 'path' not specified")
        }
        if !wiltonIsDirectory(path) {
            throw WiltonException("Fs/RmDir: Specified path is not directory, path: [\(path)]")
        }
        do {
            let url = URL(string: path) ?? URL(string: "INVALID_PATH")!
            try FileManager.default.removeItem(atPath: url.relativePath)
            return ""
        } catch {
            throw WiltonException("Fs/RmDir: Error deleting directory, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
    }
}

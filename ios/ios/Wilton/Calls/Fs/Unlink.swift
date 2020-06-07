//
//  Unlink.swift
//  ios
//
//  Created by Alexey Liverty on 6/7/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class Unlink : Call {
    
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let path = opts.path else {
            throw WiltonException("Fs/Unlink: Required parameter 'path' not specified")
        }
        if wiltonIsDirectory(path) {
            throw WiltonException("Fs/Unlink: Specified path is a directory, path: [\(path)]")
        }
        do {
            let url = URL(string: path) ?? URL(string: "INVALID_PATH")!
            try FileManager.default.removeItem(atPath: url.relativePath)
            return ""
        } catch {
            throw WiltonException("Fs/Unlinl: Error deleting file, path: [\(path)], message: [\(error)]")
        }
    }
    
    class Options : Codable {
        var path: String?
    }
}

//
//  Exists.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class Exists : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard var path = opts.path else {
            throw WiltonException("Fs/Exists: Required parameter 'path' not specified")
        }
        if !path.hasPrefix(WILTON_FILE_PROTO) {
            path = WILTON_FILE_PROTO + path
        }
        let exists = FileManager.default.fileExists(atPath: path)
        let json = wiltonToJson(Result(exists))
        return json
    }
    
    class Options : Codable {
        var path: String?
    }

    class Result : Codable {
        let exists: Bool

        init(_ exists: Bool) {
            self.exists = exists;
        }
    }
    
}

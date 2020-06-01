//
//  LoadModuleResource.swift
//  ios
//
//  Created by Alexey Liverty on 6/1/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

fileprivate let ZIP_PROTO = "zip://"
fileprivate let FILE_PROTO = "file://"

class LoadModuleResource : Call {

    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let url = opts.url else {
            throw WiltonException("Required parameter 'url' not specified")
        }
        if (url.hasPrefix(ZIP_PROTO)) {
            throw WiltonException("Invalid protocol specified:" +
                    " '\(ZIP_PROTO)' URLs are not supported in wilton-mobile," +
                    " url: [\(url)]");
        }
        var path = url
        if (path.hasPrefix(FILE_PROTO)) {
            path = String(path[path.index(after: FILE_PROTO.endIndex) ..< path.endIndex])
        }
        let file = URL(string: path)!
        if (opts.hex) {
            let bytes = try readFileToByteArray(file);
            return encodeHex(bytes);
        } else {
            return try readFileToString(file);
        }
    }
    
    class Options : Codable {
        var url: String?
        var hex: Bool = false
    }
}

//
//  LoadModuleResource.swift
//  ios
//
//  Created by Alexey Liverty on 6/1/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class LoadModuleResource : Call {

    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard let url = opts.url else {
            throw WiltonException("Compat/LoadModuleResource: Required parameter 'url' not specified")
        }
        if (url.hasPrefix(WILTON_ZIP_PROTO)) {
            throw WiltonException("Compat/LoadModuleResource: Invalid protocol specified:" +
                    " '\(WILTON_ZIP_PROTO)' URLs are not supported in wilton-mobile," +
                    " url: [\(url)]");
        }
        var path = url
        if (!path.hasPrefix(WILTON_FILE_PROTO)) {
            path = WILTON_FILE_PROTO + path
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

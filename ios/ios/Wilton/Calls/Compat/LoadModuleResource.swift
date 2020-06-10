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
        guard let path = opts.url else {
            throw WiltonException("Compat/LoadModuleResource: Required parameter 'url' not specified")
        }
        if path.hasPrefix(WILTON_ZIP_PROTO) {
            throw WiltonException("Compat/LoadModuleResource: Invalid protocol specified:" +
                    " '\(WILTON_ZIP_PROTO)' URLs are not supported in wilton-mobile," +
                    " url: [\(path)]");
        }
        if opts.hex ?? false {
            let bytes = try readFileToBytes(path)
            return encodeHex(bytes)
        } else {
            return try readFileToString(path)
        }
    }
    
    class Options : Codable {
        var url: String?
        var hex: Bool?
    }
}

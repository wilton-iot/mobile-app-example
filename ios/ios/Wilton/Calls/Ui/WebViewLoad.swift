//
//  WebViewLoad.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WebViewLoad : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, Options.self)
        guard var url = opts.url else {
            throw WiltonException("Fs/ReadFile: Required parameter 'path' not specified")
        }
        print("Ui/WebViewLoad: NOT IMPLEMENTED")
        // TODO
        return ""
    }
    
    class Options : Codable {
        var url: String?
    }
}

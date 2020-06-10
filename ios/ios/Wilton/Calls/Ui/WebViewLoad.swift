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
        guard let url = opts.url else {
            throw WiltonException("Fs/ReadFile: Required parameter 'path' not specified")
        }
        DispatchQueue.main.async {
            viewContext.webViewUrl = url
            viewContext.webViewShow.toggle()
        }
        return ""
    }
    
    class Options : Codable {
        var url: String?
    }
}

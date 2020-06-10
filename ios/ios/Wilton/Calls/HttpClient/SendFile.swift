//
//  SendFile.swift
//  ios
//
//  Created by Alexey Liverty on 6/10/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class SendFile : Call {
    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, ClientOptions.self)
        guard let filePath = opts.filePath else {
            throw WiltonException("HttpClient/SendRequest: Required parameter 'filePath' not specified")
        }
        let bytes = try readFileToBytes(filePath)
        return try clientSendBytes(opts, bytes)
    }
}

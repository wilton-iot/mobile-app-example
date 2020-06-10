//
//  SendRequest.swift
//  ios
//
//  Created by Alexey Liverty on 6/10/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class SendRequest : Call {

    func call(_ data: String) throws -> String {
        let opts = try wiltonFromJson(data, ClientOptions.self)
        var bytes: Data? = nil
        if let data = opts.data {
            bytes = data.data(using: .utf8)
        }
        return try clientSendBytes(opts, bytes)
    }
}


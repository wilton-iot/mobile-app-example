//
//  Options.swift
//  ios
//
//  Created by Alexey Liverty on 6/10/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class ClientOptions : Codable {
    var url: String?
    var data: String?
    var filePath: String?
    var metadata: Meta?

    class Meta : Codable {
        var headers: [String: String]?
        var method: String?
        var abortOnResponseError: Bool?
        var connecttimeoutMillis: Int?
        var timeoutMillis: Int?
        var responseDataFilePath: String?
    }
}

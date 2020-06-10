//
//  Result.swift
//  ios
//
//  Created by Alexey Liverty on 6/10/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class ClientResult : Codable {
    let responseCode: Int
    let data: String
    let headers: [String: String]
    
    init(_ responseCode: Int, _ data: String, _ headers: [String: String]) {
        self.responseCode = responseCode
        self.data = data
        self.headers = headers
    }
}

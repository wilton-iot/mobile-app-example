//
//  JSCoreScript.swift
//  ios
//
//  Created by Alexey Liverty on 5/26/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class JSCoreScript : Codable {
    private var module: String
    private var func_: String?
    private var args: Array<String>?
    
    init(_ module: String, _ func_: String?, _ args: [String]) {
        self.module = module
        self.func_ = func_
        self.args = args
    }
    
    private enum CodingKeys : String, CodingKey {
        case module, args
        case func_ = "func"
    }
}

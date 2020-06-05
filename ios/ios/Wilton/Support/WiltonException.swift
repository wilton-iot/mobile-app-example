//
//  WiltonException.swift
//  ios
//
//  Created by Alexey Liverty on 5/26/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WiltonException: Error, CustomStringConvertible {
    var description: String
    
    init(_ message: String) {
        self.description = "WiltonException: " + message
    }
}

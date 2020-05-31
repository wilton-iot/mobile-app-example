//
//  WiltonException.swift
//  ios
//
//  Created by Alexey Liverty on 5/26/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WiltonException: Error {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

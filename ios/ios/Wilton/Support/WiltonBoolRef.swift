//
//  WiltonBoolRef.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WiltonBoolRef {
    private var value: Bool
    
    init(_ value: Bool) {
        self.value = value
    }
    
    func get() -> Bool {
        return value
    }
    
    func set(_ value: Bool) {
        self.value = value
    }
}

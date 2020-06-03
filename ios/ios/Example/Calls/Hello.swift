//
//  Hello.swift
//  ios
//
//  Created by Alexey Liverty on 6/3/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class Hello : Call {
    func call(_ data: String) throws -> String {
        print("Hello \(data)!")
        return ""
    }
}

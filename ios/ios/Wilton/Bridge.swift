//
//  Bridge.swift
//  ios
//
//  Created by Alexey Liverty on 5/9/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol BridgeExport: JSExport {
    
    func loadScript(_ path: String)
    
    func print_(_ msg: String)
    
    func wiltoncall(_ data: String) -> String
}

class Bridge: NSObject, BridgeExport {
    fileprivate static var INSTANCE: Bridge = Bridge()
    
    func addAppCalls() {
        
    }
    
    public func loadScript(_ path: String) {
        jscoreRunner().load(path)
    }
    
    public func print_(_ msg: String) {
        print(msg)
    }
    
    public func wiltoncall(_ data: String) -> String {
        return ""
    }
}

func wiltonBridge() -> Bridge {
    return Bridge.INSTANCE
}

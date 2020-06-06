//
//  StartServer.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class StartServer : Call {
    private let holder: ServerHolder
    
    init(_ holder: ServerHolder) {
        self.holder = holder
    }
    
    func call(_ data: String) throws -> String {
        print("Server/StartServer: NOT IMPLEMENTED")
        // TODO
        return ""
    }
}

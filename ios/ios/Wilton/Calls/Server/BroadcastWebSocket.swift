//
//  BroadcastWebSocket.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class BroadcastWebSocket : Call {
    private let holder: ServerHolder
    
    init(_ holder: ServerHolder) {
        self.holder = holder
    }
    
    func call(_ data: String) throws -> String {
        if let server = holder.get() {
            server.broadcastWebSocket(data)
        }
        return ""
    }
}

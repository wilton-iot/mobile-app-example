//
//  Server.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class Server {
    
    init(_ hostname: String, _ port: Int, _ droots: [DocumentRoot],
         _ callbacks: WebSocketCallbacks, _ httpPostHandler: JSCoreScript?) throws {
        print("Server/Server: NOT IMPLEMENTED")
    }
    
    func broadcastWebSocket(_ message: String) {
        // TODO
    }
    
    func getListeningPort() -> Int {
        // TODO
        return 8080
    }
    
    func stop() {
        
    }
    
}

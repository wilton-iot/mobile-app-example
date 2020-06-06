//
//  GetTcpPort.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class GetTcpPort : Call {
    private let holder: ServerHolder
        
    init(_ holder: ServerHolder) {
        self.holder = holder
    }
        
    func call(_ data: String) throws -> String {
        print("Server/GetTcpPort: NOT IMPLEMENTED")
        // TODO
        let json = wiltonToJson(Result(8080))
        return json
    }
    
    class Result : Codable {
        let tcpPort: Int

        init(_ tcpPort: Int) {
            self.tcpPort = tcpPort
        }
    }
}

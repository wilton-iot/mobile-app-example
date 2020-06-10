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
        let opts = try wiltonFromJson(data, Options.self)
        //guard let path = opts.path else {
        //    throw WiltonException("Server/Start: Required parameter 'path' not specified")
        //}
        // single threaded usage here
        if let _ = holder.get() {
            throw WiltonException("Server/Start: Server is already running")
        }
        let server = try Server(opts.ipAddress ?? "127.0.0.1", opts.tcpPort ?? 0,
                opts.documentRoots ?? [DocumentRoot](),
                opts.websocket ?? WebSocketCallbacks(), opts.httpPostHandler);
        holder.put(server);
        return ""
    }
    
    private class Options : Codable {
        var ipAddress: String?
        var tcpPort: Int?
        var documentRoots: [DocumentRoot]? = [DocumentRoot]()
        var websocket: WebSocketCallbacks? = WebSocketCallbacks()
        var httpPostHandler: JSCoreScript?
    }
}

//
//  ServerHolder.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class ServerHolder {

    private var server: Server? = nil

    func get() -> Server? {
        return server
    }

    func put(_ instance: Server?) {
        if nil != server && nil != instance {
            print("Server/Holder: Invalid state: server is already running")
            return
        }
        self.server = instance;
    }
}

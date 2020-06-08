//
//  WsChanRegistry.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import NIO

class WebSocketRegistry {
    private let mutex: DispatchSemaphore
    private var wsChans: [Int: Channel] = [Int: Channel]()
    
    init(_ mutex: DispatchSemaphore) {
        self.mutex = mutex
    }
    
    func addChannel(_ chan: Channel) {
        let port = chan.remoteAddress?.port ?? 0
        if 0 == port {
            return
        }
        withExtendedLifetime(WiltonDispatchGuard(mutex)) {
            _ = wsChans.updateValue(chan, forKey: port)
        }
    }
    
    func removeChannel(_ chan: Channel) {
        let port = chan.remoteAddress?.port ?? 0
        if 0 == port {
            return
        }
        withExtendedLifetime(WiltonDispatchGuard(mutex)) {
            _ = wsChans.removeValue(forKey: port)
        }
    }
    
    func channels() -> [Channel] {
        return Array(wsChans.values)
    }
}

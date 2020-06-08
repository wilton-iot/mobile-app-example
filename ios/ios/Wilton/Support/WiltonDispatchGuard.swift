//
//  WiltonConcurrencyUtils.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class WiltonDispatchGuard {
    private let mtx: DispatchSemaphore
    
    init(_ mutex: DispatchSemaphore) {
        mtx = mutex
        mtx.wait()
    }
    
    deinit {
        mtx.signal()
    }
}

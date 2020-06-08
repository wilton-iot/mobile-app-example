//
//  WebSocketCallbacks.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

public class WebSocketCallbacks : Codable {
    var onOpen: JSCoreScript?
    var onMessage: JSCoreScript?
    var onClose: JSCoreScript?
}

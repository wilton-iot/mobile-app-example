//
//  JSCoreQueue.swift
//  ios
//
//  Created by Alexey Liverty on 5/26/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class JSCoreQueue {
    fileprivate static let QUEUE: DispatchQueue = createQueue()
    fileprivate static let KEY: DispatchSpecificKey<String> = DispatchSpecificKey<String>()
     
    private static func createQueue() -> DispatchQueue {
        let res = DispatchQueue(label: "jscore")
        res.setSpecific(key: KEY, value: "jscore")
        return res
    }
}

func runOnJsThread(_ fun: @escaping () -> ()) {
    JSCoreQueue.QUEUE.async {
        fun()
    }
}

func runOnJsThread(_ script: JSCoreScript) {
    JSCoreQueue.QUEUE.async {
        do {
            _ = try jscoreRunner().run(script)
        } catch {
            print("JS async exec error, message: [\(error)]")
        }
    }
}

func runOnJsThreadSync(_ script: JSCoreScript) -> String {
    return JSCoreQueue.QUEUE.sync {
        do {
            return try jscoreRunner().run(script)
        } catch {
            print("JS sync exec error, message: [\(error)]")
            return ""
        }
    }
}

func jscoreDispatchSpecificKey() -> DispatchSpecificKey<String> {
    return JSCoreQueue.KEY
}

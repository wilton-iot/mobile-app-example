//
//  Launch.swift
//  ios
//
//  Created by Alexey Liverty on 6/3/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

func launchApplication() {
    do {
        wiltonBridge().addAppCalls(appCalls())
        let script = JSCoreScript("example/index", "main", ["--ios-launch"])
        try jscoreRunner().run(script)
    } catch {
        fatalError("App launch error, message: [\(error)]")
    }
}

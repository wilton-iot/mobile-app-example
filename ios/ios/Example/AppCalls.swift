//
//  AppCalls.swift
//  ios
//
//  Created by Alexey Liverty on 6/3/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

func appCalls() -> [String: Call] {
    do {
        return [
            "example_hello": Hello()
        ]
    } catch {
        fatalError("App calls initialization error, message: [\(error)]")
    }
}

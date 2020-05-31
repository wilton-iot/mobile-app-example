//
//  WiltonIOUtils.swift
//  ios
//
//  Created by Alexey Liverty on 5/31/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

let wiltonFilesDir: URL = Bundle.main.url(forResource: "index", withExtension: "js", subdirectory: "app")!.deletingLastPathComponent();

let wiltonAppDir: URL = wiltonFilesDir.appendingPathComponent("app")

func wiltonRelPath(_ path: String) -> String {
     let dir = wiltonFilesDir.absoluteString
     if !path.hasPrefix(dir) {
         return path;
     }
     let range = path.index(after: dir.endIndex) ..< path.endIndex
     return String(path[range])
 }

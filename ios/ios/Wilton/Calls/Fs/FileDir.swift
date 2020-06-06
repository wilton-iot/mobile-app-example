//
//  FsFileDir.swift
//  ios
//
//  Created by Alexey Liverty on 6/6/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class FilesDir : Call {
    func call(_ data: String) throws -> String {
        return wiltonFilesDir.absoluteString
    }
}

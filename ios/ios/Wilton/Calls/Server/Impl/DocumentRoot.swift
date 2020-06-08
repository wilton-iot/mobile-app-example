//
//  DocumentRoot.swift
//  ios
//
//  Created by Alexey Liverty on 6/8/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

class DocumentRoot : Codable {
    var resource: String?
    var dirPath: String?
    var mimeTypes: [String: String] = [String: String]()
}

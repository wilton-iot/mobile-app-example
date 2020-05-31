//
//  WiltonJson.swift
//  ios
//
//  Created by Alexey Liverty on 5/31/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

fileprivate class WiltonJson {
    fileprivate static let ENCODER: JSONEncoder = createEncoder()
    
    private static func createEncoder() -> JSONEncoder {
        let res = JSONEncoder()
        res.outputFormatting = .prettyPrinted
        return res
    }
}

func wiltonToJson<T : Encodable>(_ src: T) -> String {
    do {
        let json = try WiltonJson.ENCODER.encode(src)
        return String(data: json, encoding: .utf8) ?? "{}"
    } catch {
        print("JSON encoding error, message: [\(error)]")
        return "{}";
    }
}

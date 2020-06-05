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
    fileprivate static let DECODER: JSONDecoder = JSONDecoder()
    
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
        print("WiltonJson: Encoding error, message: [\(error)]")
        return "{}";
    }
}

func wiltonFromJson<T>(_ str: String, _ type: T.Type) throws -> T where T : Decodable {
    do {
        let data = str.data(using: .utf8)!
        return try WiltonJson.DECODER.decode(type, from: data)
    } catch {
        throw WiltonException("WiltonJson: Decoding error, message: [\(error)], input: [\(str)]")
    }
}

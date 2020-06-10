//
//  SendBytes.swift
//  ios
//
//  Created by Alexey Liverty on 6/10/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation

fileprivate let semaphore = DispatchSemaphore(value: 0)
fileprivate let defaultConf = { () -> URLSessionConfiguration in
    let conf = URLSessionConfiguration.ephemeral
    conf.waitsForConnectivity = true
    conf.timeoutIntervalForRequest = 15
    return conf
}()
fileprivate var session = URLSession(configuration: defaultConf)
    
func clientSendBytes(_ opts: ClientOptions, _ bytes: Data?) throws -> String {
    guard let surl = opts.url else {
        throw WiltonException("HttpClient/SendRequest: Required parameter 'url' not specified")
    }
        
    let connecttimeoutMillis = opts.metadata?.connecttimeoutMillis ?? 10000
    let waitsForConnectivity = connecttimeoutMillis > 100
    let timeoutMillis = opts.metadata?.timeoutMillis ?? 15000
    let timeoutSeconds = timeoutMillis / 1000
    let abortOnResponseError = opts.metadata?.abortOnResponseError ?? false
    let currentWaits = session.configuration.waitsForConnectivity
    let currentTimeoutSeconds = Int(session.configuration.timeoutIntervalForRequest.truncatingRemainder(dividingBy: 1))

    if currentWaits != waitsForConnectivity || currentTimeoutSeconds != timeoutSeconds {
        let conf = URLSessionConfiguration.ephemeral
        conf.waitsForConnectivity = waitsForConnectivity
        conf.timeoutIntervalForRequest = Double(timeoutSeconds)
        session = URLSession(configuration: conf)
    }
            
    let url = URL(string: surl) ?? URL(string: "INVALID_URL")!
    var req = URLRequest(url: url)
    if let headers = opts.metadata?.headers {
        for (key, val) in headers {
            req.setValue(val, forHTTPHeaderField: key)
        }
    }
    if let method = opts.metadata?.method {
        req.httpMethod = method
    }
    if let bytes = bytes {
        req.httpBody = bytes
        if nil == opts.metadata?.method {
            req.httpMethod = "POST"
        }
    }
                
    var res = ""
    var statusCode: Int = 0
    var headers: [String: String] = [:]
    var err = ""
    let task = session.dataTask(with: req, completionHandler: {(data, resp, error) in
        if nil == resp {
            err = error?.localizedDescription ?? ""
        } else {
            if let resp = resp as? HTTPURLResponse {
                statusCode = resp.statusCode
                headers = resp.allHeaderFields as? [String: String] ?? [:]
            }
            if abortOnResponseError && statusCode >= 400 {
                err = error?.localizedDescription ?? ""
            } else {
                if let data = data {
                    res = String(data: data, encoding: .utf8) ?? "{}"
                }
            }
        }
        semaphore.signal()
    })
    task.resume()
    semaphore.wait()

    if !err.isEmpty {
        throw WiltonException("HttpClient/clientSendBytes: request error, url: [\(surl)], message: [\(err)]")
    }
            
    if let fp = opts.metadata?.responseDataFilePath {
        try writeStringToFile(fp, res)
        let fpObj = ResponseDataFilePath(fp)
        res = wiltonToJson(fpObj)
    }
            
    let cr = ClientResult(statusCode, res, headers)
    return wiltonToJson(cr)
}

fileprivate class ResponseDataFilePath : Codable {
    let responseDataFilePath: String
        
    init(_ responseDataFilePath: String) {
        self.responseDataFilePath = responseDataFilePath
    }
}

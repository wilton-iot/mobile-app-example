//
//  JSCoreRunner.swift
//  ios
//
//  Created by Alexey Liverty on 5/9/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import JavaScriptCore

class JSCoreRunner {
    fileprivate static var INSTANCE: JSCoreRunner!
    
    private let ctx: JSContext
    
    init() throws {
        do {
            ctx = JSContext()
            ctx.exceptionHandler = jsExceptionHandler
            ctx.setObject(wiltonBridge(), forKeyedSubscript: "WILTONMOBILE_iosBridge" as (NSCopying & NSObjectProtocol))
        } catch {
            throw WiltonException("JSCoreRunner: Context initialization error, message: \(error)");
        }
    }
    
    func load(_ path: String) {
        let relPath = wiltonRelPath(path)
        let infoHandler = ctx.exceptionHandler
        ctx.exceptionHandler = { (_: JSContext?, val: JSValue?) -> Void in
            let exc = val ?? JSValue(object: "Error loading script, path: [\(relPath)]", in: self.ctx)
            self.ctx.exception = exc
        }
        let err = runScript(path)
        ctx.exceptionHandler = infoHandler
        if !err.isEmpty {
            ctx.exception = JSValue(object: err, in: ctx)
        }
    }

    func run(_ script: JSCoreScript) throws -> String {
        guard let _ = DispatchQueue.getSpecific(key: jscoreDispatchSpecificKey()) else {
            throw WiltonException("JSCoreRunner: Attempt to run JS on an invalid queue")
        }
        let args = wiltonToJson(script)
        ctx.setObject(args, forKeyedSubscript: "WILTON_runArg" as (NSCopying & NSObjectProtocol))
        let code = "WILTON_run(WILTON_runArg)"
        let res = ctx.evaluateScript(code, withSourceURL: URL(string: "WILTON_run"))
        ctx.setObject(nil, forKeyedSubscript: "WILTON_runArg" as (NSCopying & NSObjectProtocol))
        if let exc = ctx.exception {
            let err = stringifyException(exc)
            ctx.exception = nil
            throw WiltonException("JSCoreRunner: \(args)\n\(err)")
        }
        if let val = res {
            if val.isString {
                return val.toString()
            }
        }
        return ""
    }
    
    func setException(_ exc: String) {
        // note: exception chaining may be necessary here
        self.ctx.exception = JSValue(object: exc, in: self.ctx)
    }
    
    fileprivate func runInitScript() throws {
        let path = wiltonFilesDir.appendingPathComponent("init.js").absoluteString
        let err = runScript(path)
        if !err.isEmpty {
            throw WiltonException("JSCoreRunner: Initialization error, message: \(err)")
        }
    }

    private func runScript(_ path: String) -> String {
        let label = wiltonRelPath(path)
        do {
            let rpath = URL(string: path)!.relativePath
            let code = try String(contentsOfFile: rpath, encoding: String.Encoding.utf8)
            let opt = ctx.evaluateScript(code, withSourceURL: URL(string: label)!)
            if let exc = ctx.exception {
                let err = stringifyException(exc)
                ctx.exception = nil
                throw WiltonException("JSCoreRunner, path: [\(label)]: \(err)")
            }
            //if nil == opt {
            //    return "Error evaluating script, path: [\(label)]"
            //}
            return ""
        } catch {
            return "Error evaluating script, path: [\(label)], error: [\(error)]"
        }
    }
    
    private func jsExceptionHandler(_ ctx: JSContext?, _ exc: JSValue?) -> Void {
        if let exc = exc {
            self.ctx.exception = exc
        }
    }
    
    private func stringifyException(_ exc: JSValue) -> String {
        let dict = exc.toDictionary() ?? [AnyHashable: Any]()
        let file = dict["sourceURL"] ?? "[]"
        let line = dict["line"] ?? "-1"
        let column = dict["column"] ?? "-1"
        let stack = dict["stack"] ?? ""
        return "JS Error: \(exc): \(file):\(line):\(column) \n\(stack)"
    }
}

func jscoreRunner() -> JSCoreRunner {
    guard let inst = JSCoreRunner.INSTANCE else {
        do {
            try JSCoreRunner.INSTANCE = JSCoreRunner()
            try JSCoreRunner.INSTANCE.runInitScript()
        } catch {
            fatalError("Failed to initialize JSCoreRunner: \(error)")
        }
        return JSCoreRunner.INSTANCE
    }
    return inst;
}

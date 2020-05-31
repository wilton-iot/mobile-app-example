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
            throw WiltonException("Rhino initialization error, message: \(error)");
        }
    }
    
    public func load(_ path: String) {
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

    public func run(_ script: JSCoreScript) throws -> String {
        guard let _ = DispatchQueue.getSpecific(key: jscoreDispatchSpecificKey()) else {
            throw WiltonException("Attempt to run JS on invalid queue")
        }
        let args = wiltonToJson(script)
        ctx.setObject(args, forKeyedSubscript: "WILTON_runArg" as (NSCopying & NSObjectProtocol))
        let code = "WILTON_run(WILTON_runArg)"
        let res = ctx.evaluateScript(code)
        ctx.setObject(nil, forKeyedSubscript: "WILTON_runArg" as (NSCopying & NSObjectProtocol))
        if let val = res {
            if val.isString {
                return val.toString()
            }
        }
        return ""
    }

    private func runScript(_ path: String) -> String {
        let label = wiltonRelPath(path)
        do {
            let rpath = URL(string: path)!.relativePath
            let code = try String(contentsOfFile: rpath, encoding: String.Encoding.utf8)
            let opt = ctx.evaluateScript(code, withSourceURL: URL(string: label)!)
            if nil == opt {
                return "Error evaluating script, path: [\(label)]"
            }
            return ""
        } catch {
            return "Error evaluating script, path: [\(label)], error: [\(error)]"
        }
    }

    fileprivate static func runInitScript() throws {
        let path = wiltonFilesDir.appendingPathComponent("init.js").absoluteString
        _ = INSTANCE.runScript(path)
    }
    
    private func jsExceptionHandler(_ ctx: JSContext?, _ exc: JSValue?) -> Void {
        if let exc = exc {
            print("JS Error, msg: [\(exc)], details: [\(exc.toDictionary()?.description ?? "")]")
        }
    }
}

func jscoreRunner() -> JSCoreRunner {
    guard let inst = JSCoreRunner.INSTANCE else {
        do {
            try JSCoreRunner.INSTANCE = JSCoreRunner()
            try JSCoreRunner.runInitScript()
        } catch {
            fatalError("Failed to initialize JSCoreRunner: \(error)")
        }
        return JSCoreRunner.INSTANCE
    }
    return inst;
}

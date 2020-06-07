//
//  Bridge.swift
//  ios
//
//  Created by Alexey Liverty on 5/9/20.
//  Copyright © 2020 alex. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol BridgeExport: JSExport {
    
    func loadScript(_ path: String)
    
    func print_(_ msg: String)
    
    func wiltoncall(_ name: String, _ params: String) -> String
}

class Bridge: NSObject, BridgeExport {
    fileprivate static var INSTANCE: Bridge = Bridge()
    private var calls: [String: Call] = [String: Call]()
    
    override init() {
        do {
            // compat
            calls["get_wiltoncall_config"] = try GetWiltoncallConfig()
            calls["load_module_resource"] = LoadModuleResource()
            // fs
            calls["fs_exists"] = Exists()
            calls["fs_files_dir"] = FilesDir()
            calls["fs_mkdir"] = MkDir()
            calls["fs_readdir"] = ReadDir()
            calls["fs_read_file"] = ReadFile()
            calls["fs_rmdir"] = RmDir()
            calls["fs_unlink"] = Unlink()
            calls["fs_write_file"] = WriteFile()
            /*
            // httpclient
            calls.put("httpclient_send_request", new SendRequest());
            calls.put("httpclient_send_file", new SendFile());
             */
            // server
            let holder = ServerHolder()
            calls["server_start"] = StartServer(holder)
            //calls.put("server_stop", new StopServer(holder));
            calls["server_get_tcp_port"] = GetTcpPort(holder)
            //calls.put("server_broadcast_web_socket", new BroadcastWebSocket(holder));
            // thread
            //calls.put("thread_sleep_millis", new SleepMillis());
            // ui
            //calls.put("ui_show_message", new ShowMessage());
            calls["ui_webview_load"] = WebViewLoad()
            //calls.put("ui_splash_hide", new HideSplash());
        } catch {
            fatalError("JS Bridge initialization error, message: [\(error)]")
        }
    }
    
    func addAppCalls(_ appCalls: [String: Call]) {
        for (key, val) in appCalls {
            calls[key] = val
        }
    }
    
    public func loadScript(_ path: String) {
        jscoreRunner().load(path)
    }
    
    public func print_(_ msg: String) {
        print(msg)
    }
    
    public func wiltoncall(_ name: String, _ params: String) -> String {
        if name.isEmpty {
            jscoreRunner().setException("Invalid empty 'wiltoncall' name specified")
            return ""
        }
        guard let call = calls[name] else {
            jscoreRunner().setException("Invalid unknown 'wiltoncall' name specified: [\(name)]")
            return ""
        }
        do {
            return try call.call(params);
        } catch {
            var dataLog = params
            if params.count > 1024 {
                let range = params.index(params.startIndex, offsetBy: 1024)
                dataLog = String(params.prefix(upTo: range))
            }
            jscoreRunner().setException("\n'wiltoncall' error for name: [\(name)]," +
                    " data: [\(dataLog)], message: [\(error)]")
            return ""
        }
    }
}

func wiltonBridge() -> Bridge {
    return Bridge.INSTANCE
}

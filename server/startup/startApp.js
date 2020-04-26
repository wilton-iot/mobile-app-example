/*
 * Copyright 2020, alex at staticlibs.net
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

define([
    // deps
    "module",
    "wilton-mobile/isDev",
    "wilton-mobile/Logger",
    "wilton-mobile/wiltoncall",
    "wilton-mobile/events/addEventListener",
    // server
    "wilton-mobile/server/broadcastWebSocket",
    "wilton-mobile/server/serverTcpPort",
    "wilton-mobile/server/startServer",
    // ui
    "wilton-mobile/ui/showMessage"
], function(
        module, isDev, Logger, wiltoncall, addEventListener, // deps
        broadcastWebSocket, serverTcpPort, startServer, //server
        showMessage // ui
) {
    "use strict";
    var logger = new Logger(module.id);

    function stdlibDocRoot(conf) {
        if (isDev) {
            return {
                resource: "/stdlib",
                zipPath: conf.wiltonConfig.wiltonHome + "std.wlib",
                cacheMaxAgeSeconds: 0
            };
        } else {
            return {
                resource: "/stdlib",
                dirPath: conf.appdir.replace(/[^/]+[/]+$/, "") + "stdlib"
            };
        }
    }

    return function(conf) {
        // server
        startServer({
            ipAddress: conf.server.ipAddress,
            tcpPort: conf.server.tcpPort,
            documentRoots: [{
                resource: "/web",
                dirPath: conf.appdir + "web"
            }, stdlibDocRoot(conf)],
            websocket: {
                onMessage: {
                    module: "wilton-mobile/backendcall"
                }
            }
        });
        var port = serverTcpPort();
        logger.info("Server started on port: [" + port + "]");

        // webview
        wiltoncall("ui_webview_load", {
            url: "http://127.0.0.1:" + port + "/web/index.html"
        });

        // events
        [
            "onBackPressed",
            "onDestroy",
            "onLowMemory",
            "onPause",
            "onRestart",
            "onResume",
            "onStart",
            "onStop"
        ].forEach(function(event) {
            addEventListener({
                name: event,
                event: event,
                func: function() {
                    logger.info("Event received, name: [" + event + "]");
                    //showMessage(event);
                }
            });
        });

        // back button
        addEventListener({
            name: "onBackPressedBroadcast",
            event: "onBackPressed",
            func: function() {
                broadcastWebSocket({
                    broadcast: "back"
                });
            }
        });
    };
});

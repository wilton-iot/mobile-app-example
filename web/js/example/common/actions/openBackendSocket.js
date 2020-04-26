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
    "vue-require/websocket/withSock",
    "example/common/utils/formatError",
    "example/common/utils/isEmptyObject"
], function(withSock, formatError, isEmptyObject) {
    "use strict";

    return function(context, onOpen) {
        var hname = window.location.hostname;
        if ("[::1]" === hname) {
            // iOS: WebSocket network error: The operation couldn’t be completed. (kCFErrorDomainCFNetwork error 1.)
            hname = "localhost";
        }
        var url = "ws://" + hname + ":" + window.location.port + "/websocket";
        withSock(null, {
            url: url,
            logger: function(obj) {
                var msg = JSON.stringify(obj, null, 4);
                console.log(msg);
            },
            onError: function(err) {
                var msg = err;
                if ("object" === typeof (msg) &&
                        "undefined" !== msg.stack && "undefined" !== msg.message) {
                    msg = formatError(msg);
                } else {
                    msg = JSON.stringify(err, null, 4);
                    if (isEmptyObject(JSON.parse(msg))) {
                        msg = String(err);
                    }
                }
                console.error(msg);
            }
        });
        if ("function" === typeof(onOpen)) {
            onOpen();
        }
    };
});

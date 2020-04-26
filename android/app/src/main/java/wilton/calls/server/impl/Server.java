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

package wilton.calls.server.impl;

import org.nanohttpd.protocols.http.IHTTPSession;
import org.nanohttpd.protocols.websockets.NanoWSD;
import org.nanohttpd.protocols.websockets.WebSocket;

import java.io.IOException;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

import wilton.rhino.RhinoScript;

public class Server extends NanoWSD {

    private final WebSocketCallbacks callbacks;
    private final ConcurrentHashMap<WebSocket, Boolean> wsRegistry = new ConcurrentHashMap<>();

    public Server(String hostname, int port, ArrayList<DocumentRoot> droots,
                  WebSocketCallbacks callbacks, RhinoScript httpPostHandler) throws IOException {
        super(hostname, port);
        this.callbacks = callbacks;
        setHTTPHandler(new HTTPHandler(droots, httpPostHandler));
        start(0, true);
    }

    @Override
    protected WebSocket openWebSocket(IHTTPSession handshake) {
        return new WebSocketHandler(handshake, callbacks, wsRegistry);
    }

    public void broadcastWebSocket(String message) {
        for (WebSocket ws : wsRegistry.keySet()) {
            try {
                ws.send(message);
            } catch (Exception e) {
                // ignore
            }
        }
    }
}

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

import android.util.Log;

import org.nanohttpd.protocols.http.IHTTPSession;
import org.nanohttpd.protocols.websockets.CloseCode;
import org.nanohttpd.protocols.websockets.WebSocket;
import org.nanohttpd.protocols.websockets.WebSocketFrame;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

import wilton.rhino.RhinoScript;

import static mobile.example.MainActivity.activity;
import static wilton.rhino.RhinoExecutor.runOnJsThreadSync;

class WebSocketHandler extends WebSocket {

    private final WebSocketCallbacks callbacks;
    private final ConcurrentHashMap<WebSocket, Boolean> registry;

    WebSocketHandler(IHTTPSession handshakeRequest, WebSocketCallbacks callbacks,
                     ConcurrentHashMap<WebSocket, Boolean> registry) {
        super(handshakeRequest);
        this.callbacks = callbacks;
        this.registry = registry;
    }

    @Override
    protected void onOpen() {
        registry.put(this, true);
        RhinoScript cb = callbacks.getOnOpen();
        if (null != cb) {
            String resp = runOnJsThreadSync(cb);
            sendResponse(resp);
        }
    }

    @Override
    protected void onClose(CloseCode code, String reason, boolean initiatedByRemote) {
        registry.remove(this);
        RhinoScript cb = callbacks.getOnClose();
        if (null != cb) {
            String resp = runOnJsThreadSync(cb);
            sendResponse(resp);
        }
    }

    @Override
    protected void onMessage(WebSocketFrame message) {
        if (null != callbacks.getOnMessage()) {
            RhinoScript om = callbacks.getOnMessage();
            RhinoScript cb = new RhinoScript(om.getModule(), om.getFunc(), message.getTextPayload());
            String resp = runOnJsThreadSync(cb);
            sendResponse(resp);
        }
    }

    @Override
    protected void onPong(WebSocketFrame pong) {
        // no-op
    }

    @Override
    protected void onException(IOException exception) {
        final String msg = Log.getStackTraceString(exception);
        Log.e(activity().getClass().getPackage().getName(), msg);
    }

    private void sendResponse(String resp) {
        try {
            if (null != resp) {
                send(resp);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

}

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

package wilton.calls.server;

import java.util.ArrayList;

import wilton.calls.server.impl.DocumentRoot;
import wilton.calls.server.impl.Server;
import wilton.calls.server.impl.ServerHolder;
import wilton.calls.server.impl.WebSocketCallbacks;
import wilton.rhino.RhinoScript;
import wilton.Call;
import wilton.support.WiltonException;

import static wilton.support.WiltonJson.wiltonFromJson;

public class StartServer implements Call {

    private final ServerHolder holder;

    public StartServer(ServerHolder holder) {
        this.holder = holder;
    }

    @Override
    public String call(String data) throws Exception {
        Options opts = wiltonFromJson(data, Options.class);
        // single threaded usage here
        if (null != holder.get()) {
            throw new WiltonException("Server is already running");
        }
        Server server = new Server(opts.ipAddress, opts.tcpPort, opts.documentRoots,
                opts.websocket, opts.httpPostHandler);
        holder.put(server);
        return null;
    }

    static class Options {
        String ipAddress;
        int tcpPort;
        ArrayList<DocumentRoot> documentRoots;
        WebSocketCallbacks websocket;
        RhinoScript httpPostHandler;
    }
}

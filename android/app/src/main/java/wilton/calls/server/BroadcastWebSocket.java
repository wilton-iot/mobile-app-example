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

import wilton.calls.server.impl.Server;
import wilton.calls.server.impl.ServerHolder;
import wilton.Call;

public class BroadcastWebSocket implements Call {

    private final ServerHolder holder;

    public BroadcastWebSocket(ServerHolder holder) {
        this.holder = holder;
    }

    @Override
    public String call(String data) throws Exception {
        Server server = holder.get();
        if (null != server) {
            server.broadcastWebSocket(data);
        }
        return null;
    }
}
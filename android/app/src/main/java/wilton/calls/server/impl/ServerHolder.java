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

import wilton.WiltonException;

public class ServerHolder {

    private Server server = null;

    public Server get() {
        return server;
    }

    public void put(Server instance) {
        if (null != instance && null != server) {
            throw new WiltonException("Server is already running");
        }
        this.server = instance;
    }
}

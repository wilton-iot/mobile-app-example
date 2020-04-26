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

package mobile.example;

import java.io.IOException;
import java.util.LinkedHashMap;

import wilton.calls.ui.HideSplash;
import wilton.calls.ui.WebViewLoad;
import wilton.calls.compat.LoadModuleResource;
import wilton.calls.fs.Exists;
import wilton.calls.fs.MkDir;
import wilton.calls.fs.ReadDir;
import wilton.calls.fs.ReadFile;
import wilton.calls.compat.GetWiltoncallConfig;
import wilton.calls.fs.FilesDir;
import wilton.calls.fs.RmDir;
import wilton.calls.fs.Unlink;
import wilton.calls.fs.WriteFile;
import wilton.calls.httpclient.SendFile;
import wilton.calls.httpclient.SendRequest;
import wilton.calls.server.BroadcastWebSocket;
import wilton.calls.server.GetTcpPort;
import wilton.calls.server.StartServer;
import wilton.calls.server.StopServer;
import wilton.calls.server.impl.ServerHolder;
import wilton.calls.thread.SleepMillis;
import wilton.calls.ui.ShowMessage;
import wilton.Call;
import wilton.WiltonException;

public class Bridge {

    private final LinkedHashMap<String, Call> calls;

    public Bridge() throws IOException {
        this.calls = new LinkedHashMap<>();

        // wilton
        // compat
        calls.put("get_wiltoncall_config", new GetWiltoncallConfig());
        calls.put("load_module_resource", new LoadModuleResource());
        // fs
        calls.put("fs_exists", new Exists());
        calls.put("fs_files_dir", new FilesDir());
        calls.put("fs_mkdir", new MkDir());
        calls.put("fs_readdir", new ReadDir());
        calls.put("fs_read_file", new ReadFile());
        calls.put("fs_rmdir", new RmDir());
        calls.put("fs_unlink", new Unlink());
        calls.put("fs_write_file", new WriteFile());
        // httpclient
        calls.put("httpclient_send_request", new SendRequest());
        calls.put("httpclient_send_file", new SendFile());
        // server
        ServerHolder holder = new ServerHolder();
        calls.put("server_start", new StartServer(holder));
        calls.put("server_stop", new StopServer(holder));
        calls.put("server_get_tcp_port", new GetTcpPort(holder));
        calls.put("server_broadcast_web_socket", new BroadcastWebSocket(holder));
        // thread
        calls.put("thread_sleep_millis", new SleepMillis());
        // ui
        calls.put("ui_show_message", new ShowMessage());
        calls.put("ui_webview_load", new WebViewLoad());
        calls.put("ui_splash_hide", new HideSplash());

        // app
    }

    public String wiltoncall(String name, String params) throws WiltonException {
        if (name.isEmpty()) {
            throw new WiltonException("Invalid empty 'wiltoncall' name specified");
        }
        Call call = calls.get(name);
        if (null == call) {
            throw new WiltonException("Invalid unknown 'wiltoncall' name specified: [" + name + "]");
        }
        try {
            return call.call(params);
        } catch (Exception e) {
            String dataLog = "";
            if (null != params) {
                dataLog = params.length() > 1024 ? params.substring(0, 1024) : params;
            }
            throw new WiltonException(e.getClass().getName() + ": " + e.getMessage() +
                    "\n'wiltoncall' error for name: [" + name + "]," +
                    " data: [" + dataLog + "]", e);
        }
    }
}
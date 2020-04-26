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

package wilton.calls.httpclient;

import java.io.FileInputStream;
import java.io.InputStream;

import wilton.Call;

import static org.apache.commons.io.IOUtils.closeQuietly;
import static wilton.calls.httpclient.SendStream.sendStream;
import static mobile.example.utils.JsonUtils.GSON;

public class SendFile implements Call {
    @Override
    public String call(String data) throws Exception {
        Options opts = GSON.fromJson(data, Options.class);
        String path = opts.getFilePath();
        if (!(null != path && path.length() > 0)) {
            throw new Error("Invalid 'filePath' specified: [" + path + "]");
        }
        InputStream fis = null;
        try {
            // no need for buffered stream here
            // buffered in sendStream
            fis = new FileInputStream(path);
            Result res = sendStream(opts, fis);
            return GSON.toJson(res);
        } finally {
            closeQuietly(fis);
        }
    }
}

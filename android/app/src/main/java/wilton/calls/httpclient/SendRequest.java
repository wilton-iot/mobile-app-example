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

import java.io.ByteArrayInputStream;

import wilton.Call;

import static wilton.calls.httpclient.SendStream.sendStream;
import static wilton.support.WiltonJson.wiltonFromJson;
import static wilton.support.WiltonJson.wiltonToJson;

public class SendRequest implements Call {
    @Override
    public String call(String data) throws Exception {
        Options opts = wiltonFromJson(data, Options.class);
        String reqdata = null != opts.getData() ? opts.getData() : "";
        byte[] bytes = reqdata.getBytes("UTF-8");
        ByteArrayInputStream bais = new ByteArrayInputStream(bytes);
        Result res = sendStream(opts, bais);
        return wiltonToJson(res);
    }
}

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

package wilton.calls.compat;

import java.io.File;

import wilton.Call;
import wilton.support.WiltonException;

import static org.apache.commons.codec.binary.Hex.encodeHex;
import static org.apache.commons.io.FileUtils.readFileToByteArray;
import static org.apache.commons.io.FileUtils.readFileToString;
import static wilton.support.WiltonJson.wiltonFromJson;

public class LoadModuleResource implements Call {
    private static final String ZIP_PROTO = "zip://";
    private static final String FILE_PROTO = "file://";


    @Override
    public String call(String data) throws Exception {
        Options opts = wiltonFromJson(data, Options.class);
        if (null == opts.url || opts.url.isEmpty()) {
            throw new WiltonException("Required parameter 'url' not specified");
        }
        if (opts.url.startsWith(ZIP_PROTO)) {
            throw new WiltonException("Invalid protocol specified:" +
                    " '" + ZIP_PROTO + "' URLs are not supported in wilton-mobile," +
                    " url: [" + opts.url + "]");
        }
        String path = opts.url;
        if (opts.url.startsWith(FILE_PROTO)) {
            path = opts.url.substring(FILE_PROTO.length());
        }
        File file = new File(path);
        if (opts.hex) {
            byte[] bytes = readFileToByteArray(file);
            return new String(encodeHex(bytes));
        } else {
            return readFileToString(file, "UTF-8");
        }
    }

    private static class Options {
        String url;
        boolean hex = false;
    }
}

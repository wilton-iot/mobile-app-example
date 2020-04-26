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

package wilton.calls.fs;

import java.io.File;

import wilton.Call;

import static org.apache.commons.codec.binary.Hex.encodeHex;
import static org.apache.commons.io.FileUtils.readFileToByteArray;
import static org.apache.commons.io.FileUtils.readFileToString;
import static mobile.example.utils.JsonUtils.GSON;

public class ReadFile implements Call {

    @Override
    public String call(String data) throws Exception {
        Options opts = GSON.fromJson(data, Options.class);
        File file = new File(opts.path);
        if (opts.hex) {
            byte[] bytes = readFileToByteArray(file);
            return new String(encodeHex(bytes));
        } else {
            return readFileToString(file, "UTF-8");
        }
    }

    private static class Options {
        String path;
        boolean hex = false;
    }
}

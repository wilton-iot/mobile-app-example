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

import static org.apache.commons.codec.binary.Hex.decodeHex;
import static org.apache.commons.io.FileUtils.writeByteArrayToFile;
import static org.apache.commons.io.FileUtils.writeStringToFile;
import static mobile.example.utils.JsonUtils.GSON;

public class WriteFile implements Call {
    @Override
    public String call(String data) throws Exception {
        Options opts = GSON.fromJson(data, Options.class);
        File file = new File(opts.path);
        if (opts.hex) {
            byte[] bytes = decodeHex(data.toCharArray());
            writeByteArrayToFile(file, bytes);
        } else {
            writeStringToFile(file, opts.data, "UTF-8");
        }
        return null;
    }

    private static class Options {
        String path;
        String data;
        boolean hex = false;
    }
}

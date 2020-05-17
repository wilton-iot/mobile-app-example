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
import wilton.support.WiltonException;

import static wilton.support.WiltonJson.wiltonFromJson;

public class MkDir implements Call {
    @Override
    public String call(String data) throws Exception {
        Options opts = wiltonFromJson(data, Options.class);
        boolean success = new File(opts.path).mkdir();
        if (!success) {
            throw new WiltonException("Cannot create directory, path: [" + opts.path + "]");
        }
        return null;
    }

    private static class Options {
        String path;
    }
}

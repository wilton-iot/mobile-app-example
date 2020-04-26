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
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import wilton.Call;
import wilton.Config;

import static org.apache.commons.io.FileUtils.readFileToString;
import static mobile.example.MainActivity.activity;
import static mobile.example.utils.JsonUtils.GSON;

public class GetWiltoncallConfig implements Call {

    private final Config config;

    public GetWiltoncallConfig() throws IOException {
        File filesDir = activity().getExternalFilesDir(null);
        String baseUrl = new File(filesDir, "stdlib").getAbsolutePath();
        LinkedHashMap<String, String> paths = new LinkedHashMap<>();
        File packagesFile = new File(filesDir, "stdlib/wilton-requirejs/wilton-packages.json");
        String text = readFileToString(packagesFile, "UTF-8");
        paths.put("example", new File(filesDir, "app").getAbsolutePath());
        ArrayList<Config.RequireJS.Package> packages = GSON.fromJson(text, Config.RequireJS.PACKAGES_JSON_TYPE);
        this.config = new Config(baseUrl, paths, packages);
    }

    public String call(final String data) throws Exception {
        return GSON.toJson(this.config);
    }

}
